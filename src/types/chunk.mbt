///|
typealias @span.Span

///|
typealias @span.Spanned

///|
pub typealias Array[Spanned[Chunk]] as Chunks

///|
/// Represents one part of a field value.
pub(all) enum Chunk {
  /// Normal values within quotes or single braces subject to
  /// capitalization formatting.
  Normal(String)
  /// Values nested in braces that are to be printed like specified
  /// in the file. Escapes keywords.
  ///
  /// Example: `"Inside {NASA}"` or `{Memes are {gReAT}}`.
  Verbatim(String)
  /// Values nested in dollar signs.
  Math(String)
} derive(Eq, Show)

///|
/// Get the string contained in the chunk.
pub fn Chunk::get(self : Chunk) -> String {
  match self {
    Normal(s) => s
    Verbatim(s) => s
    Math(s) => s
  }
}

///|
/// Get the string contained in the chunk and whether it is verbatim.
fn Chunk::get_and_verb(self : Chunk) -> (String, Bool) {
  match self {
    Normal(s) => (s, false)
    Verbatim(s) => (s, true)
    Math(s) => (s, false)
  }
}

///|
/// /// Get the string contained in the chunk with the characters escaped.
///
/// There is no difference for BibTeX and BibLaTeX here, so there is only one function applicable to both.
///
/// The `is_verbatim` argument indicates whether this string is intended for
/// a verbatim field like `file` with limited escapes.
fn Chunk::to_biblatex_string(self : Chunk, is_verbatim : Bool) -> String {
  let mut s : String = ""
  for c in self.get().iter() {
    if is_escapable(c, is_verbatim, false) {
      s += "\\"
    }
    s += c.to_string()
  }
  s
}

///|
/// usage:
/// ```moonbit
/// let chunks : Chunks = [{v: Normal("Monroe, Brian Albert"), span: {start: 2147483647, end: 2147483647}}]
/// let s1 = ChunkExt::format_sentence(chunks)
/// let s2 = ChunkExt::format_verbatim(chunks)
/// let span = ChunkExt::span(chunks)
/// let s3 = ChunkExt::to_biblatex_string(chunks,false)
/// inspect(s1,content="Monroe, brian albert")
/// inspect(s2,content="Monroe, Brian Albert")
/// inspect(span,content="{start: 2147483647, end: 2147483647}")
/// inspect(s3,content="{Monroe, Brian Albert}")
/// ```
pub trait ChunkExt {
  /// Format the chunks in sentence case.
  format_sentence(Self) -> String
  /// Format the chunks verbatim.
  format_verbatim(Self) -> String
  /// Output a span for all chunks in the collection.
  span(Self) -> Span
  /// Serialize the chunks into a BibLaTeX string.
  ///
  /// There is no difference for BibTeX and BibLaTeX here, so there is only one function applicable to both.
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
  is_verbatim,
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
  let upper = if extra_brace { 1 } else { 0 }
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

///| Splits chunk arrays that are a token lists as defined per the
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
      let mut found = target.find(keyword)
      while found is Some(pos) {
        let first = target.substring(end=pos).trim_space_end()
        latest.push(
          Spanned::new(Chunk::Normal(first), { start, end: start + pos }),
        )
        out.push(latest.copy())
        latest.clear()
        target = target
          .substring(start=pos + keyword.length())
          .trim_space_start()
        start += pos + keyword.length()
        found = target.find(keyword)
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
  keyword : String,
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
      latest[0] = Spanned::new(Normal(str), {
        start: span_start,
        end: latest[0].span.end,
      })
    }
    if not(latest[0].is_detached()) {
      span_start += diff
    }
    let v = latest[0].v
    latest[0] = Spanned::new(v, { start: span_start, end: latest[0].span.end })
    str = ""
    let mut new_len = 0
    let end = latest.length() - 1
    let mut span_end = latest[end].span.end
    if latest[end].v is Normal(s) {
      str = s
      new_len = s.trim_space_end().length()
      str = str.substring(end=new_len)
      latest[end] = Spanned::new(Normal(str), {
        start: latest[end].span.start,
        end: span_end,
      })
    }
    if not(latest[end].is_detached()) {
      span_end = latest[end].span.start + new_len
    }
    let v = latest[end].v
    latest[end] = Spanned::new(v, {
      start: latest[end].span.start,
      end: span_end,
    })
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
      let splits = splits.drop(1)
      let mut cur = ""
      for split in splits {
        if prev.ends_with_whitespace() && split.starts_with_whitespace() {
          cur += prev
          let end = if chunk.is_detached() {
            @int.max_value
          } else {
            start + cur.length()
          }
          latest.push(Spanned::new(Chunk::Normal(cur), { start, end }))
          cur = ""
          sanitize_latest(latest)
          out.push(latest.copy())
          latest.clear()
          start = end
          prev = split
          continue
        }
        cur += prev
        cur += keyword
        prev = split
      }
      cur += prev
      let end = if chunk.is_detached() {
        @int.max_value
      } else {
        start + cur.length()
      }
      latest.push(Spanned::new(Chunk::Normal(cur), { start, end }))
      cur = ""
    } else {
      latest.push(chunk)
    }
  }
  sanitize_latest(latest)
  out.push(latest)
  out
}

///| Splits a chunk array into two at the first occurrence of the character `c`.
/// `omit` controls whether the output will contain `c`.
pub fn split_at_normal_char(
  src : Chunks,
  c : Char,
  omit : Bool,
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

///| Returns two chunk arrays with `src` split at some chunk index and
/// the string byte index `str_idx` within that chunk.
pub fn split_values(
  src : Chunks,
  chunk_idx : Int,
  str_idx : Int,
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

///|
/// This generic function parses a Chunks data structure into a value of type T, where T must implement the Type trait.
/// example : 
/// ```moonbit
/// let chunks : Chunks = [{v: Normal("Monroe, Brian Albert"), span: {start: 2147483647, end: 2147483647}}]
/// let res : ArrayPerson = parse_chunks(chunks)
/// inspect(res.0,content=("[Brian Albert Monroe]"))
/// ```
pub fn[T : Type] parse_chunks(chunks : Chunks) -> T raise TypeError {
  T::from_chunks(chunks)
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
  let split = split_values(vls, 4, 5)
  assert_eq(split.0, vls)
  assert_eq(split.1, [])
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

///|
test "test_math" {
  let chunk : Chunk = Math("a+b")
  let s = chunk.get()
  assert_eq(s, "a+b")
  let string_bool = chunk.get_and_verb()
  assert_eq(string_bool, ("a+b", false))
  let array = [Spanned::detached(chunk)]
  let s = ChunkExt::to_biblatex_string(array, false)
  assert_eq(s, "{$a+b$}")
  let chunk1 = Math("c+d")
  let array = [Spanned::detached(chunk), Spanned::detached(chunk1)]
  let spilt = split_values(array, 1, 2)
  assert_eq(spilt.0, [
    Spanned::detached(Math("a+b")),
    Spanned::detached(Math("c+")),
  ])
  assert_eq(spilt.1, [Spanned::detached(Math("d"))])
}

///|
test "test_format" {
  let normal = Spanned::detached(Normal("\n\rnormal string"))
  let verbatim = Spanned::detached(Verbatim("verbatim string"))
  let math = Spanned::detached(Math("math string"))
  let array = []
  array.push(normal)
  array.push(verbatim)
  array.push(math)
  assert_eq(
    ChunkExt::format_sentence(array),
    " normal stringverbatim string$math string$",
  )
  assert_eq(
    ChunkExt::format_verbatim(array),
    " normal stringverbatim string$math string$",
  )
  array.clear()
  let verbatim : Spanned[Chunk] = Spanned::detached(Verbatim("verbatim string"))
  array.push(verbatim)
  assert_eq(ChunkExt::to_biblatex_string(array, true), "{{verbatim string}}")
  let normal = Spanned::detached(Normal("normal string"))
  array.push(normal)
  assert_eq(
    ChunkExt::to_biblatex_string(array, false),
    "{{verbatim string}normal string}",
  )
}

///|
test "test_boundary" {
  let split_kw = split_token_lists_with_kw([], "keyword")
  assert_eq(split_kw, [[]])
  let split_normal_char = split_at_normal_char([], 'c', true)
  assert_eq(split_normal_char, ([], []))
}

///|
test "test_join_chunk_list" {
  let vls = [
    s(n("split "), { start: 1, end: 7 }),
    s(v("not, "), { start: 9, end: 14 }),
    s(n("but rather, here"), { start: 16, end: 32 }),
  ]
  let list = join_chunk_list(vls, ",")
  assert_eq(list, [
    { v: Normal("split "), span: { start: 1, end: 7 } },
    { v: Normal(","), span: { start: 9, end: 9 } },
    { v: Verbatim("not, "), span: { start: 9, end: 14 } },
    { v: Normal(","), span: { start: 16, end: 16 } },
    { v: Normal("but rather, here"), span: { start: 16, end: 32 } },
  ])
}
