///|
typealias @span.Span
typealias @span.Spanned

///|
typealias Array[Spanned[Chunk]] as Chunks

///|
pub(all) enum Chunk {
  Normal(String)
  Verbatim(String)
  Math(String)
} derive(Eq, Show)

///|
pub fn Chunk::get(self : Chunk) -> String {
  match self {
    Normal(s) => s
    Verbatim(s) => s
    Math(s) => s
  }
}

///|
fn Chunk::get_and_verb(self : Chunk) -> (String, Bool) {
  match self {
    Normal(s) => (s, false)
    Verbatim(s) => (s, true)
    Math(s) => (s, false)
  }
}

///|
fn Chunk::to_biblatex_string(self : Chunk, is_verbatim : Bool) -> String {
  let mut s : String = ""
  for c in self.get().iter() {
    if @utils.is_escapable(c, is_verbatim, false) {
      s += "\\"
    }
    s += c.to_string()
  }
  s
}

///|
pub trait ChunkExt {
  //  parse(Self)  todo
  format_sentence(Self) -> String
  format_verbatim(Self) -> String
  span(Self) -> Span
  to_biblatex_string(Self, is_verbatim : Bool) -> String
}

///|
pub impl ChunkExt for Array[Spanned[Chunk]] with format_sentence(self) {
  let mut out = ""
  let mut first = true
  let mut prev_was_whitespace = false
  for val in self {
    match val.v {
      Normal(s) =>
        for c in s.iter() {
          let mut char = c
          if c is ('\n' | '\r') {
            if prev_was_whitespace {
              continue
            } else {
              char = ' '
            }
          }
          if first {
            out += char.to_ascii_uppercase().to_string()
          } else {
            out += char.to_ascii_lowercase().to_string()
          }
          first = false
          prev_was_whitespace = char.is_whitespace()
        }
      Verbatim(s) => {
        out += s
        prev_was_whitespace = s
          .to_array()
          .last()
          .map(Char::is_whitespace)
          .unwrap_or(false)
      }
      Math(s) => out += "$\{s}$"
    }
    first = false
  }
  out
}

///|
pub impl ChunkExt for Array[Spanned[Chunk]] with format_verbatim(self) {
  let mut out = ""
  let mut prev_was_whitespace = false
  for val in self {
    match val.v {
      Normal(s) =>
        for c in s.iter() {
          let mut char = c
          if c is ('\n' | '\r') {
            if prev_was_whitespace {
              continue
            } else {
              char = ' '
            }
          }
          out += char.to_string()
          prev_was_whitespace = char.is_whitespace()
        }
      Verbatim(s) => {
        out += s
        prev_was_whitespace = s
          .to_array()
          .last()
          .map(Char::is_whitespace)
          .unwrap_or(false)
      }
      Math(s) => out += "$\{s}$"
    }
  }
  out
}

///|
pub impl ChunkExt for Array[Spanned[Chunk]] with span(self) {
  let start = self.get(0).map(c => c.span.start).unwrap_or(0)
  let end = self.last().map(c => c.span.end).unwrap_or(start)
  { start, end }
}

///|
pub impl ChunkExt for Array[Spanned[Chunk]] with to_biblatex_string(
  self,
  is_verbatim
) {
  let mut res = ""
  res += "{"
  let mut extra_brace = false
  for chunk in self.iter() {
    match chunk.v {
      Verbatim(_) if not(extra_brace) => {
        res += "{"
        extra_brace = true
      }
      Normal(_) if extra_brace => {
        res += "}"
        extra_brace = false
      }
      Math(_) => res += "$"
      _ => ()
    }
    res += chunk.v.to_biblatex_string(is_verbatim)
    if chunk.v is Math(_) {
      res += "$"
    }
  }
  let upper = if extra_brace { 2 } else { 1 }
  for _ in 0..=upper {
    res += "}"
  }
  res
}

///|
/// An iterator over the characters in each chunk, indicating whether they are
/// verbatim or not. Chunk types other than `Normal` or `Verbatim` are omitted.
pub fn chunk_chars(chunks : Chunks) -> Iter[(Char, Bool)] {
  chunks
  .iter()
  .flat_map(chunk => {
    let (s, verbatim) = chunk.v.get_and_verb()
    s.iter().map(c => (c, verbatim))
  })
}

///| Combines the chunks, interlacing with the separator.
pub fn join_chunk_list(chunks : Chunks, sep : String) -> Chunks {
  let res = []
  let mut first = true
  for chunk in chunks {
    if first {
      first = false
    } else {
      res.push(
        Spanned::new(Chunk::Normal(sep), {
          start: chunk.span.start,
          end: chunk.span.start,
        }),
      )
    }
    res.push(chunk)
  }
  res
}

///| Splits chunk vectors that are a token lists as defined per the
/// [BibLaTeX Manual][manual] p. 16 along occurrences of the keyword.
///
/// [manual]: http://ctan.ebinger.cc/tex-archive/macros/latex/contrib/biblatex/doc/biblatex.pdf
pub fn split_token_lists(vals : Chunks, keyword : String) -> Array[Chunks] {
  let out = []
  let latest = []
  for val in vals {
    if val.v is Normal(s) {
      let mut target = s
      let mut start = val.span.start
      let found = target.find(keyword)
      while found is Some(pos) {
        let first = target.substring(end=pos).trim_space_end()
        latest.push(
          Spanned::new(Chunk::Normal(first), { start, end: start + pos }),
        )
        out.push(latest)
        latest.clear()
        target = target
          .substring(start=pos + keyword.length())
          .trim_space_start()
        start += pos + keyword.length()
      }
      latest.push(
        Spanned::new(Chunk::Normal(target), { start, end: val.span.end }),
      )
    } else {
      latest.push(val)
    }
  }
  out.push(latest)
  out
}

///| Split the token list based on a keyword surrounded by whitespace
///
/// For Normal Chunks,
/// - The leading/trailing keyword is not considered as a valid split
///   (regardless of whether the keyword is preceded/followed by some
///   whitespace).
/// - If there are consecutive keywords, the characters between two consecutive
///   keywords (whether only whitespace or not) will be considered as a valid
///   split.
pub fn split_token_lists_with_kw(
  vals : Chunks,
  keyword : String
) -> Array[Chunks] {
  let out = []
  let latest = []
  let sanitize_latest = fn(latest : Array[Spanned[Chunk]]) {
    if latest.is_empty() {
      return
    }
    let mut diff = 0
    let mut span_start = latest[0].span.start
    let mut str = ""
    if latest[0].v is Normal(s) {
      str = s
      diff = str.length() - str.trim_space_start().length()
      let s_array = str.to_array()
      ignore(s_array.drain(0, diff))
      str = s_array.map(Char::to_string).join("")
    }
    if not(latest[0].is_detached()) {
      span_start += diff
    }
    if not(str.is_empty()) {
      latest[0] = Spanned::new(Normal(str), {
        start: span_start,
        end: latest[0].span.end,
      })
    }
    str = ""
    let mut new_len = 0
    let end = latest.length() - 1
    let mut span_end = latest[end].span.end
    if latest[end].v is Normal(s) {
      str = s
      new_len = s.trim_space_end().length()
      str = str.substring(end=new_len)
    }
    if not(latest[end].is_detached()) {
      span_end = latest[end].span.start + new_len
    }
    if not(str.is_empty()) {
      latest[end] = Spanned::new(Normal(str), {
        start: latest[end].span.start,
        end: span_end,
      })
    }
  }
  for chunk_idx, chunk in vals.iter2() {
    if chunk.v is Normal(s) {
      let mut start = chunk.span.start
      let s = if chunk_idx == 0 {
        let new_s = s.trim_space_start()
        if not(chunk.is_detached()) {
          start = chunk.span.start + s.length() - new_s.length()
        }
        new_s
      } else {
        s
      }
      let s = if chunk_idx == vals.length() - 1 {
        s.trim_space_end()
      } else {
        s
      }
      let splits = s.split(keyword).map(s => s.to_string())
      let mut prev = splits.head().unwrap()
      let mut cur = ""
      for split in splits {
        if prev.get_char(prev.length() - 1).unwrap().is_whitespace() &&
          prev.get_char(0).unwrap().is_whitespace() {
          cur += prev
          let end = if chunk.is_detached() {
            @int.max_value
          } else {
            start + cur.length()
          }
          latest.push(Spanned::new(Chunk::Normal(cur), { start, end }))
        }
        cur += prev
        cur += keyword
        prev = split
      }
    } else {
      latest.push(chunk)
    }
  }
  sanitize_latest(latest)
  out.push(latest)
  out
}

///| Splits a chunk vector into two at the first occurrence of the character `c`.
/// `omit` controls whether the output will contain `c`.
pub fn split_at_normal_char(
  src : Chunks,
  c : Char,
  omit : Bool
) -> (Chunks, Chunks) {
  let mut search_result = None
  for chunk_idx, val in src.iter2() {
    if val.v is Normal(s) {
      if s.find(c.to_string()) is Some(str_idx) {
        search_result = Some((chunk_idx, str_idx))
        break
      }
    }
  }
  if search_result is Some((chunk_idx, str_idx)) {
    let (v1, v2) = split_values(src, chunk_idx, str_idx)
    if omit {
      let mut chunk = v2[0].v
      if v2[0].v is Normal(s) {
        let str = s
          .iter()
          .drop(1)
          .map(Char::to_string)
          .join("")
          .trim_space_start()
        chunk = Normal(str)
      }
      v2[0] = Spanned::new(chunk, {
        start: v2[0].span.end - chunk.get().length(),
        end: v2[0].span.end,
      })
    }
    (v1, v2)
  } else {
    (src, [])
  }
}

///| Returns two chunk vectors with `src` split at some chunk index and
/// the string byte index `str_idx` within that chunk.
pub fn split_values(
  src : Chunks,
  chunk_idx : Int,
  str_idx : Int
) -> (Chunks, Chunks) {
  let new = []
  if chunk_idx >= src.length() {
    return (src, new)
  }
  if chunk_idx + 1 < src.length() {
    new.append(src.drain(chunk_idx + 1, src.length()))
  }
  let item = src.last().unwrap()
  let content = item.v.get()
  let (s1, s2) = content.split_at(str_idx)
  let boundary = item.span.start.saturating_add(str_idx)
  let new_span : Span = {
    start: boundary,
    end: boundary.saturating_add(s2.length()),
  }
  let s1 = s1.trim_space_end()
  let s2 = s2.trim_space_start()
  let chunk = match item.v {
    Verbatim(_) => Verbatim(s1)
    Normal(_) => Normal(s1)
    Math(_) => Math(s1)
  }
  src[src.length() - 1] = Spanned::new(chunk, {
    start: item.span.start,
    end: boundary,
  })
  match item.v {
    Verbatim(_) => new.insert(0, Spanned::new(Chunk::Verbatim(s2), new_span))
    Normal(_) => new.insert(0, Spanned::new(Chunk::Normal(s2), new_span))
    Math(_) => new.insert(0, Spanned::new(Chunk::Math(s2), new_span))
  }
  (src, new)
}

///| Returns the number of characters in the chunks.
pub fn count_num_char(chunks : Chunks, c : Char) -> Int {
  chunks
  .iter()
  .map(val => if val.v is Normal(s) {
    s.fold(init=0, (count, char) => if char == c { count + 1 } else { count })
  } else {
    0
  })
  .fold(init=0, (count, elem) => count + elem)
}
pub fn[T : Type] parse(chunks : Chunks) -> T raise TypeError{
  T::from_chunks(chunks)
}
fn String::split_at(self : String, index : Int) -> (String, String) {
  (self.substring(end=index), self.substring(start=index))
}
///|
fn String::trim_space_start(self : String) -> String {
  let s = StringBuilder::new()
  s.write_iter(self.iter().drop_while(c => c.is_whitespace()))
  s.to_string()
}

///|
fn String::trim_space_end(self : String) -> String {
  self.rev().trim_space_start().rev()
}

///|


///|
fn Int::saturating_add(self : Int, len : Int) -> Int {
  if @int.max_value - self < len {
    @int.max_value
  } else {
    self + len
  }
}

///|
fn n(s : String) -> Chunk {
  Normal(s)
}

///|
fn v(s : String) -> Chunk {
  Verbatim(s)
}

///|
fn[T] s(v : T, span : Span) -> Spanned[T] {
  Spanned::new(v, span)
}

///|
fn[T] d(v : T) -> Spanned[T] {
  Spanned::detached(v)
}

///|
test "test_trim_space" {
  let s = "\n Hello\tworld\t\n"
  assert_eq(s.trim_space_start(), "Hello\tworld\t\n")
  assert_eq(s.trim_space_end(), "\n Hello\tworld")
  let s = "  English  "
  assert_eq(s.trim_space_start().iter().head(), Some('E'))
  let s = "  עברית  "
  assert_eq(s.trim_space_start().iter().head(), Some('ע'))
}

///|
test "test_split_at" {
  let s = "Per Martin-Löf"
  let (first, last) = s.split_at(3)
  assert_eq("Per", first)
  assert_eq(" Martin-Löf", last)
}

///|
test "test_split" {
  let vls = [
    s(n("split "), { start: 1, end: 7 }),
    s(v("exac^tly"), { start: 9, end: 17 }),
    s(n("here"), { start: 19, end: 23 }),
  ]
  let ref1 = [
    s(n("split "), { start: 1, end: 7 }),
    s(v("exac^"), { start: 9, end: 14 }),
  ]
  let ref2 = [
    s(v("tly"), { start: 14, end: 17 }),
    s(n("here"), { start: 19, end: 23 }),
  ]
  let split = split_values(vls, 1, 5)
  assert_eq(split.0, ref1)
  assert_eq(split.1, ref2)
}

///|
test "test_split_at_normal_char" {
  let vls = [
    s(n("split "), { start: 1, end: 7 }),
    s(v("not, "), { start: 9, end: 14 }),
    s(n("but rather, here"), { start: 16, end: 32 }),
  ]
  let ref1 = [
    s(n("split "), { start: 1, end: 7 }),
    s(v("not, "), { start: 9, end: 14 }),
    s(n("but rather"), { start: 16, end: 26 }),
  ]
  let ref2 = [s(n("here"), { start: 28, end: 32 })]
  let split = split_at_normal_char(vls, ',', true)
  assert_eq(split.0, ref1)
  assert_eq(split.1, ref2)
}
