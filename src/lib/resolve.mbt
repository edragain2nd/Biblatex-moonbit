///|
typealias @span.Spanned

///|
pub fn parse_field(
  key : String,
  field : Field,
  abbreviations : Array[Pair]
) -> Chunks raise ParseError {
  let chunks : Array[Spanned[Chunk]] = []
  for e in field.inner() {
    match e.v {
      Normal(s) =>
        chunks.append(ContentParser::new(key, s, e.span.start).parse())
      Abbreviation(s) =>
        chunks.append(resolve_abbreviation(key, s, e.span, abbreviations))
    }
  }
  flatten(chunks)
  chunks
}

///|
struct ContentParser {
  s : Scanner
  verb_field : Bool
  mut current_chunk : Chunk
  result : Chunks
  mut start : Int
  offset : Int
}

///|
fn ContentParser::new(
  key : String,
  field : String,
  offset : Int
) -> ContentParser {
  {
    s: Scanner::new(field),
    verb_field: is_verbatim_field(key),
    current_chunk: ContentParser::default_chunk(0),
    result: [],
    start: 0,
    offset,
  }
}

///|
fn ContentParser::parse(self : ContentParser) -> Chunks raise ParseError {
  let offset = self.offset
  self
  .parse_impl()
  .map(chunk => Spanned::new(chunk.v, {
    start: chunk.span.start + offset,
    end: chunk.span.end + offset,
  })) catch {
    ParseError((span, error_kind)) =>
      raise ParseError(
        ({ start: span.start + offset, end: span.end + offset }, error_kind),
      )
  }
}

///|
fn ContentParser::parse_impl(self : ContentParser) -> Chunks raise ParseError {
  let mut depth = 0
  self.current_chunk = ContentParser::default_chunk(depth)
  let mut peeked = self.s.peek()
  while peeked is Some(c) {
    match c {
      '\\' => {
        let sequence = self.backslash()
        self.current_chunk = match self.current_chunk {
          Math(s) => Math(s + sequence)
          Normal(s) => Normal(s + sequence)
          Verbatim(s) => Verbatim(s + sequence)
        }
      }
      '$' if not(self.verb_field) => {
        self.turnaround(depth)
        let math = self.math()
        self.result.push(math)
      }
      '{' => {
        depth += 1
        self.turnaround(depth)
        ignore(self.s.eat())
        self.start += 1
      }
      '}' => {
        if depth == 0 {
          let idx = self.s.cursor()
          ignore(self.s.eat())
          raise ParseError(
            (
              { start: idx, end: self.s.cursor() },
              ParseErrorKind::Unexpected(Token::ClosingBrace),
            ),
          )
        }
        depth -= 1
        self.turnaround(depth)
        self.start += 1
        ignore(self.s.eat())
      }
      '-' => {
        let mut count = 0
        let hyphens = self.s.eat_while(
          CharPredicate::new(c => {
            let res = c == '-' && count < 3
            if res {
              count += 1
            }
            res
          }),
        )
        match count {
          1 =>
            self.current_chunk = match self.current_chunk {
              Math(s) => Math(s + "-")
              Normal(s) => Normal(s + "-")
              Verbatim(s) => Verbatim(s + "-")
            }
          2 =>
            self.current_chunk = match self.current_chunk {
              Math(s) => Math(s + "–")
              Normal(s) => Normal(s + "–")
              Verbatim(s) => Verbatim(s + "–")
            }
          3 =>
            self.current_chunk = match self.current_chunk {
              Math(s) => Math(s + "—")
              Normal(s) => Normal(s + "—")
              Verbatim(s) => Verbatim(s + "—")
            }
          _ =>
            self.current_chunk = match self.current_chunk {
              Math(s) => Math(s + hyphens)
              Normal(s) => Normal(s + hyphens)
              Verbatim(s) => Verbatim(s + hyphens)
            }
        }
      }
      _ if c.is_whitespace() => {
        self.current_chunk = match self.current_chunk {
          Math(s) => Math(s + " ")
          Normal(s) => Normal(s + " ")
          Verbatim(s) => Verbatim(s + " ")
        }
        ignore(self.s.eat_whitespace())
      }
      _ => {
        let eaten = self.s.eat().unwrap().to_string()
        self.current_chunk = match self.current_chunk {
          Math(s) => Math(s + eaten)
          Normal(s) => Normal(s + eaten)
          Verbatim(s) => Verbatim(s + eaten)
        }
      }
    }
    peeked = self.s.peek()
  }
  if not(self.current_chunk.get().is_empty()) || self.result.is_empty() {
    self.turnaround(depth)
  }
  self.result
}

///|
fn ContentParser::turnaround(self : ContentParser, depth : Int) -> Unit {
  let chunk = self.current_chunk
  self.current_chunk = ContentParser::default_chunk(depth)
  self.result.push(
    Spanned::new(chunk, { start: self.start, end: self.s.cursor() }),
  )
  self.start = self.s.cursor()
}

///|
fn ContentParser::backslash(self : ContentParser) -> String raise ParseError {
  self.eat_assert('\\')
  match self.s.peek() {
    Some(c) if c != '^' &&
      c != '~' &&
      @utils.is_escapable(c, self.verb_field, true) => {
      ignore(self.s.eat())
      c.to_string()
    }
    _ if self.verb_field => "\\"
    Some(c) if not(c.is_whitespace()) && not(c.is_control()) => self.command()
    Some(c) => c.to_string()
    None => raise ParseError((self.here(), ParseErrorKind::UnexpectedEof))
  }
}

///|
fn ContentParser::command(self : ContentParser) -> String raise ParseError {
  let pos = self.s.cursor()
  let valid_start = self.s
    .peek()
    .map(c => not(c.is_whitespace() && not(c.is_control())))
    .unwrap_or_default()
  if not(valid_start) {
    raise ParseError(
      ({ start: pos, end: self.s.cursor() }, ParseErrorKind::MalformedCommand),
    )
  }
  if not(is_single_char_func(self.s.eat().unwrap(), false)) {
    ignore(self.s.eat_while(CharPredicate::new(is_id_continue)))
  }
  let command = self.s.from(pos)
  let ws = not(self.s.eat_whitespace().is_empty())
  let first_char = command.iter().nth(0).unwrap()
  let arg : String? = if self.s.peek() != Some('{') &&
    command.char_length() == 1 &&
    first_char != '-' &&
    is_single_char_func(first_char, ws) {
    let idx = self.s.cursor()
    ignore(self.s.eat())
    Some(self.s.from(idx))
  } else if not(ws) && self.s.eat_if('{') {
    let mut depth = 1
    let idx = self.s.cursor()
    for {
      ignore(self.s.eat_until(['{', '}']))
      match self.s.eat() {
        Some('{') => depth += 1
        Some('}') => {
          depth -= 1
          if depth == 0 {
            break
          }
        }
        Some(_) => abort("unreachable")
        None => raise ParseError((self.here(), ParseErrorKind::UnexpectedEof))
      }
    }
    let brace = '}'.to_string().length()
    let arg = self.s.from(idx)
    let arg = ContentParser::new(
      "",
      arg.substring(start=0, end=arg.length() - brace),
      idx,
    ).parse()
    let arg = @types.ChunkExt::format_verbatim(arg)
    Some(arg)
  } else {
    None
  }
  execute_command(command, arg)
}

///|
fn ContentParser::math(self : ContentParser) -> Spanned[Chunk] raise ParseError {
  self.eat_assert('$')
  let idx = self.s.cursor()
  let res = self.s.eat_until(CharPredicate::new(c => c == '$'))
  let span : Span = { start: idx, end: self.s.cursor() }
  if self.s.done() {
    raise ParseError((self.here(), ParseErrorKind::UnexpectedEof))
  }
  ignore(self.s.eat())
  self.start = self.s.cursor()
  Spanned::new(Math(res), span)
}

///|
fn ContentParser::eat_assert(self : ContentParser, c : Char) -> Unit {
  if self.s.eat() != Some(c) {
    abort("assertion failed: expected '\{c}'")
  }
}

///|
fn ContentParser::here(self : ContentParser) -> Span {
  { start: self.s.cursor(), end: self.s.cursor() }
}

///|
fn ContentParser::default_chunk(depth : Int) -> Chunk {
  if depth > 0 {
    Verbatim("")
  } else {
    Normal("")
  }
}

///|
fn resolve_abbreviation(
  key : String,
  abbr : String,
  span : Span,
  map : Array[Pair]
) -> Chunks raise ParseError {
  let fields = map.iter().find_first(e => e.key.v == abbr).map(e => e.value.v)
  match fields {
    Some(fields) => parse_field(key, fields, map)
    None => {
      let month = @types.get_month_for_abbr(abbr)
      match month {
        Some((month, _)) => {
          let array : Array[Spanned[Chunk]] = []
          array.push(Spanned::new(Normal(month), span))
          return array
        }
        None =>
          raise ParseError((span, ParseErrorKind::UnknownAbbreviation(abbr)))
      }
    }
  }
}

///|
fn execute_command(command : String, arg : String?) -> String {
  fn last_char_combine(v : String?, combine : Char) -> String {
    if v is Some(v) {
      if v.is_empty() {
        match combine {
          '\u{302}' => return "^"
          '\u{303}' => return "~"
          _ => return combine.to_string()
        }
      } else {
        let chars = v.to_array()
        let last = match chars.unsafe_pop() {
          'ı' => 'i'
          'ȷ' => 'j'
          c => c
        }
        let combined = @compose.compose(last, combine)
        let str = if chars.is_empty() { "" } else { chars.to_string() }
        let mut res = str + combined.unwrap_or(last).to_string()
        if combined is None {
          res += combine.to_string()
        }
        res
      }
    } else {
      combine.to_string()
    }
  }

  match command {
    "LaTeX" => "LaTeX"
    "TeX" => "TeX"
    "textendash" => "–"
    "textemdash" => "—"
    "textquotesingle" => "'"
    "textquotedblleft" => "“"
    "textquotedblright" => "”"
    "textquoteleft" => "‘"
    "textquoteright" => "’"
    "textquotestraightdblbase" | "quotedblbase" => "„"
    "textquotestraightbase" | "quotesinglbase" => "‚"
    "textquotedbl" => "\""
    "textasciicircum" => "^"
    "textasciigrave" => "`"
    "textasciitilde" => "~"
    "textasteriskcentered" => "⁎"
    "textbackslash" => "\\"
    "textbar" => "|"
    "textbraceleft" => "{"
    "textbraceright" => "}"
    "textbullet" => "•"
    "textdagger" => "†"
    "textdaggerdbl" => "‡"
    "textdollar" => "$"
    "textless" => "<"
    "textgreater" => ">"
    "textexclamdown" => "¡"
    "textquestiondown" => "¿"
    "textordfeminine" => "ª"
    "textordmasculine" => "º"
    "textperiodcentered" => "·"
    "textregistered" => "®"
    "texttrademark" => "™"
    "textsection" => "§"
    "textunderscore" => "_"
    "textvisiblespace" => "␣"
    "guillemotleft" => "«"
    "guillemotright" => "»"
    "guilsinglleft" => "‹"
    "guilsinglright" => "›"
    "aa" => "å"
    "AA" => "Å"
    "ae" => "æ"
    "AE" => "Æ"
    "dh" => "ð"
    "dj" => "đ"
    "DJ" => "Đ"
    "ng" => "ŋ"
    "NG" => "Ŋ"
    "l" => "ł"
    "L" => "Ł"
    "i" => "ı"
    "oe" => "œ"
    "OE" => "Œ"
    "o" if arg is None => "ø"
    "O" => "Ø"
    "ss" => "ß"
    "SS" => "ẞ"
    "th" => "þ"
    "TH" => "Þ"
    "P" | "textparagraph" => "¶"
    "S" => "§"
    "copyright" => if arg is Some(arg) { "©\{arg}" } else { "©".to_string() }
    "ddag" => "‡"
    "dots" | "textellipsis" => "…"
    "pounds" => "£"
    "`" => last_char_combine(arg, '\u{300}')
    "´" => last_char_combine(arg, '\u{301}')
    "'" => last_char_combine(arg, '\u{301}')
    "^" => last_char_combine(arg, '\u{302}')
    "~" => last_char_combine(arg, '\u{303}')
    "=" => last_char_combine(arg, '\u{304}')
    "u" => last_char_combine(arg, '\u{306}')
    "." => last_char_combine(arg, '\u{307}')
    "\"" => last_char_combine(arg, '\u{308}')
    "r" => last_char_combine(arg, '\u{30A}')
    "H" => last_char_combine(arg, '\u{30B}')
    "v" => last_char_combine(arg, '\u{30C}')
    "d" => last_char_combine(arg, '\u{323}')
    "c" => last_char_combine(arg, '\u{327}')
    "k" => last_char_combine(arg, '\u{328}')
    "b" => last_char_combine(arg, '\u{332}')
    "o" => last_char_combine(arg, '\u{338}')
    "-" => ""
    _ =>
      if arg is Some(arg) {
        "\\\{command}{{\{arg}}}"
      } else {
        "\\\{command} "
      }
  }
}

///|
fn flatten(chunks : Chunks) -> Unit {
  let mut i = 1
  for {
    if i >= chunks.length() {
      break
    }
    let former = chunks[i - 1].v
    let later = chunks[i].v
    let merge = (former is Normal(_) && later is Normal(_)) ||
      (former is Verbatim(_) && later is Verbatim(_))
    if merge {
      let start = chunks[i - 1].span.start
      let end = chunks[i].span.end
      chunks[i] = Spanned::new(Normal(""), { start: 0, end: 0 })
      let merged_former = match former {
        Verbatim(s) => Chunk::Verbatim(s + later.get())
        Normal(s) => Chunk::Normal(s + later.get())
        Math(s) => Chunk::Math(s + later.get())
      }
      chunks[i - 1] = Spanned::new(merged_former, { start, end })
      ignore(chunks.remove(i))
    } else {
      i += 1
    }
  }
}

///|
fn is_single_char_func(c : Char, ws : Bool) -> Bool {
  c is ('"' | '´' | '`' | '\'' | '^' | '~' | '=' | '.' | '\\' | '-') ||
  (ws && c is ('b' | 'c' | 'd' | 'H' | 'k' | 'r' | 'u' | 'v'))
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
fn m(s : String) -> Chunk {
  Math(s)
}

///|
fn z(c : RawChunk) -> Spanned[RawChunk] {
  Spanned::new(c, { start: 0, end: 0 })
}

///|
test "test_process" {
  let map = [("abc", "ABC"), ("hi", "hello"), ("you", "person")]
    .iter()
    .map(kv => {
      let array = []
      array.push(z(RawChunk::Normal(kv.1)))
      Pair::new(Spanned::detached(kv.0), Spanned::detached(array))
    })
    .collect()
  let field = [
    z(RawChunk::Abbreviation("abc")),
    z(RawChunk::Normal("good {TIMES}")),
    z(RawChunk::Abbreviation("hi")),
    z(RawChunk::Abbreviation("you")),
    z(RawChunk::Normal("last")),
  ]
  let res = parse_field("", field, map)
  assert_eq(res[0].v, n("ABCgood "))
  assert_eq(res[1].v, v("TIMES"))
  assert_eq(res[2].v, n("hellopersonlast"))
  assert_eq(res.length(), 3)
}

///|
test "test_resolve_commands_and_escape" {
  let field = [
    z(RawChunk::Normal("\\\"{A}ther und {\"\\LaTeX \"} {\\relax for you\\}}")),
  ]
  let res = parse_field("", field, [])
  assert_eq(res[0].v, n("Äther und "))
  assert_eq(res[1].v, v("\"LaTeX\""))
  assert_eq(res[2].v, n(" "))
  assert_eq(res[3].v, v("\\relax for you}"))
  assert_eq(res.length(), 4)
  let field = [z(RawChunk::Normal("M\\\"etal S\\= ound"))]
  let res = parse_field("", field, [])
  assert_eq(res[0].v, n("Mëtal Sōund"))
  let raw =
    #|L\^{e} D\~{u}ng Tr\'{a}ng
  let field = [z(RawChunk::Normal(raw))]
  let res = parse_field("", field, [])
  assert_eq(res[0].v, n("Lê Dũng Tráng"))
  let raw =
    #|\b b \c c \d a \H o \k a \r a \u a \v a
  let field = [z(RawChunk::Normal(raw))]
  let res = parse_field("", field, [])
  assert_eq(res[0].v, n("b̲ ç ạ ő ą å ă ǎ"))
}

///|
test "test_math" {
  let field = [
    z(
      RawChunk::Normal(
        "The $11^{th}$ International Conference on How To Make \\$\\$",
      ),
    ),
  ]
  let res = parse_field("", field, [])
  assert_eq(res[0].v, n("The "))
  assert_eq(res[1].v, m("11^{th}"))
  assert_eq(res[2].v, n(" International Conference on How To Make $$"))
  assert_eq(res.length(), 3)
}
//FAIDED

///|
test "test_commands" {
  let field = [
    z(RawChunk::Normal("Bose\\textendash{}Einstein uses Win\\-dows")),
  ]
  let res = parse_field("", field, [])
  assert_eq(res[0].v, n("Bose–Einstein uses Windows"))
}

///|
test "test_hyphens" {
  let field = [
    z(RawChunk::Normal("- Knitting A--Z --- A practical guide -----")),
  ]
  let res = parse_field("", field, [])
  assert_eq(res[0].v, n("- Knitting A–Z — A practical guide —–"))
}
