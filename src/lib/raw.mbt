///|
typealias @unscanny.(CharPredicate, Scanner)

///|
struct Field(Array[Spanned[RawChunk]])

///|
/// A literal representation of a bibliography file, with abbreviations not yet
/// resolved.
pub struct RawBibliogrphy {
  /// TeX commands to be prepended to the document, only supported by BibTeX.
  mut preamble : String
  /// The collection of citation keys and bibliography entries.
  entries : Array[Spanned[RawEntry]]
  /// A map of reusable abbreviations, only supported by BibTeX.
  abbreviations : Array[Pair]
}

///|
pub fn RawBibliogrphy::new() -> RawBibliogrphy {
  { preamble: "", entries: Array::new(), abbreviations: Array::new() }
}

///|
/// A raw extracted entry, with abbreviations not yet resolved.
pub struct RawEntry {
  /// The citation key.
  key : Spanned[String]
  /// Denotes the type of bibliographic item (e.g., `article`).
  kind : Spanned[String]
  /// Maps from field names to their values.
  fields : Array[Pair]
}

///|
/// Parse a raw bibliography from a source string.
pub fn RawBibliogrphy::parse(src : String) -> RawBibliogrphy raise ParseError {
  BiblatexParser::new(src).parse()
}

///|
/// Backing struct for parsing a Bib(La)TeX file into a [`RawBibliography`].
struct BiblatexParser {
  s : Scanner
  res : RawBibliogrphy
}

///|
/// An error that might occur during initial parsing of the bibliography.
/// span Span: Where in the source the error occurred.
/// kind ParseErrorKind: What kind of error occurred.
pub suberror ParseError (Span, ParseErrorKind) derive(Eq)

///|
pub impl Show for ParseError with to_string(self) {
  let ParseError((span, kind)) = self
  "\{kind}: \{span.start}-\{span.end}"
}

///|
pub impl Show for ParseError with output(self, logger) {
  logger.write_string(self.to_string())
  logger.write_char('\n')
}

///|
/// A literal representation of a bibliography entry field.
pub enum RawChunk {
  /// A normal field value.
  Normal(String)
  /// A field with strings and abbreviations
  Abbreviation(String)
} derive(Eq)

///|
/// Error conditions that might occur during initial parsing of the
/// bibliography.
///
/// Also see [`ParseError`].
pub enum ParseErrorKind {
  /// The file ended prematurely.
  UnexpectedEof
  /// An unexpected token was encountered.
  Unexpected(Token)
  /// A token was expected, but not found.
  Expected(Token)
  /// A field contained an abbreviation that was not defined.
  UnknownAbbreviation(String)
  /// A TeX command was malformed.
  MalformedCommand
  /// A duplicate citation key was found.
  DuplicateKey(String)
  /// A type error occurred while trying to resolve cross-references.
  ResolutionError(TypeErrorKind)
} derive(Eq)

///|
pub enum Token {
  /// An identifier for a field key, citation type, abbreviation, or citation
  /// key.
  Identifier
  /// An opening brace: `{`.
  OpeningBrace
  /// A closing brace: `}`.
  ClosingBrace
  /// A comma: `,`.
  Comma
  /// A quotation mark: `"`.
  QuotationMark
  /// An equals sign: `=`.
  Equals
  /// A decimal point: `.`.
  DecimalPoint
} derive(Eq)

///|
impl Show for ParseErrorKind with to_string(self) {
  match self {
    DuplicateKey(s) => "duplicate key \{s}"
    MalformedCommand => "malformed command"
    UnknownAbbreviation(s) => "unknown abbreviation \{s}"
    Expected(token) => "expected \{token}"
    Unexpected(token) => "unexpected \{token}"
    UnexpectedEof => "unexpected end of file"
    ResolutionError(e) => "type error occurred during crossref resolution: \{e}"
  }
}

///|
impl Show for ParseErrorKind with output(self, logger) {
  logger.write_string(self.to_string())
  logger.write_char('\n')
}

///|
impl Show for Token with to_string(self) {
  match self {
    Equals => "equals"
    QuotationMark => "double quote"
    Comma => "comma"
    ClosingBrace => "closing brace"
    OpeningBrace => "opening brace"
    Identifier => "identifier"
    DecimalPoint => "decimal point"
  }
}

///|
impl Show for Token with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
/// Constructs a new parser.
pub fn BiblatexParser::new(src : String) -> BiblatexParser {
  { s: Scanner::new(src), res: RawBibliogrphy::new() }
}

///|
/// Parses the file, consuming the parser in the process.
pub fn BiblatexParser::parse(
  self : BiblatexParser,
) -> RawBibliogrphy raise ParseError {
  while not(self.s.done()) {
    ignore(self.s.eat_whitespace())
    match self.s.peek() {
      Some('@') => self.entry()
      Some('%') => self.comment()
      Some(_) => ignore(self.s.eat())
      None => break
    }
  }
  self.res
}

///|
/// Eat a comma.
fn BiblatexParser::comma(self : BiblatexParser) -> Unit raise ParseError {
  if not(self.s.eat_if(',')) {
    raise ParseError((self.here(), ParseErrorKind::Expected(Comma)))
  }
  ()
}

///|
/// Eat a delimiter.
fn BiblatexParser::brace(
  self : BiblatexParser,
  open : Bool,
) -> Unit raise ParseError {
  let (brace, token) = if open {
    ('{', Token::OpeningBrace)
  } else {
    ('}', Token::ClosingBrace)
  }
  let peeked = self.s.peek()
  if peeked == Some(brace) || peeked is Some('\"') {
    ignore(self.s.eat())
    ()
  } else {
    raise ParseError((self.here(), ParseErrorKind::Expected(token)))
  }
}

///|
/// Eat a quote.
fn BiblatexParser::quote(self : BiblatexParser) -> Unit raise ParseError {
  if not(self.s.eat_if('\"')) {
    raise ParseError(
      (self.here(), ParseErrorKind::Expected(Token::QuotationMark)),
    )
  } else {
    ()
  }
}

///|

///| Eat a quote.
fn BiblatexParser::equals(self : BiblatexParser) -> Unit raise ParseError {
  if not(self.s.eat_if('=')) {
    raise ParseError((self.here(), ParseErrorKind::Expected(Token::Equals)))
  } else {
    ()
  }
}

///|
/// Eat a string.
fn BiblatexParser::string(
  self : BiblatexParser,
) -> Spanned[String] raise ParseError {
  ignore(self.quote())
  let idx = self.s.cursor()
  let mut peeked = self.s.peek()
  while peeked is Some(c) {
    match c {
      '"' => {
        let res = self.s.from(idx)
        let span : Span = { start: idx, end: self.s.cursor() }
        ignore(self.quote())
        return Spanned::new(res, span)
      }
      '\\' => {
        ignore(self.s.eat())
        ignore(self.s.eat())
      }
      _ => ignore(self.s.eat())
    }
    peeked = self.s.peek()
  }
  raise ParseError((self.here(), ParseErrorKind::UnexpectedEof))
}

///|
/// Eat a number.
fn BiblatexParser::number(self : BiblatexParser) -> String raise ParseError {
  let idx = self.s.cursor()
  let mut has_dot : Bool = false
  let mut peeked = self.s.peek()
  while peeked is Some(c) {
    let start = self.s.cursor()
    match c {
      '0'..='9' => ignore(self.s.eat())
      '.' =>
        if not(has_dot) {
          ignore(self.s.eat())
          has_dot = true
        } else {
          raise ParseError(
            (
              { start, end: self.s.cursor() },
              ParseErrorKind::Unexpected(Token::DecimalPoint),
            ),
          )
        }
      _ => return self.s.from(idx)
    }
    peeked = self.s.peek()
  }
  raise ParseError((self.here(), ParseErrorKind::UnexpectedEof))
}

///|
/// Eat a braced value.
fn BiblatexParser::braced(
  self : BiblatexParser,
) -> Spanned[RawChunk] raise ParseError {
  ignore(self.brace(true))
  let idx = self.s.cursor()
  let mut braces : Int = 0
  let mut peeked = self.s.peek()
  while peeked is Some(c) {
    match c {
      '{' => {
        ignore(self.brace(true))
        braces += 1
      }
      '}' => {
        let res = self.s.from(idx)
        let span : Span = { start: idx, end: self.s.cursor() }
        ignore(self.brace(false))
        if braces == 0 {
          return Spanned::new(RawChunk::Normal(res), span)
        }
        braces -= 1
      }
      '\\' => {
        ignore(self.s.eat())
        ignore(self.s.eat())
      }
      _ => ignore(self.s.eat())
    }
    peeked = self.s.peek()
  }
  raise ParseError((self.here(), ParseErrorKind::UnexpectedEof))
}

///|
/// Eat an element of an abbreviation.
fn BiblatexParser::abbr_element(
  self : BiblatexParser,
) -> Spanned[RawChunk] raise ParseError {
  let start = self.s.cursor()
  let res = match self.s.peek() {
    Some(c) if c.is_ascii_digit() => RawChunk::Normal(self.number())
    Some(c) if is_id_start(c) => RawChunk::Abbreviation(self.ident().v)
    _ => return self.single_field()
  }
  Spanned::new(res, { start, end: self.s.cursor() })
}

///|
/// Eat an abbreviation field.
fn BiblatexParser::abbr_field(
  self : BiblatexParser,
) -> Spanned[Field] raise ParseError {
  let start = self.s.cursor()
  let elems : Array[Spanned[RawChunk]] = []
  for {
    elems.push(self.abbr_element())
    ignore(self.s.eat_whitespace())
    if not(self.s.eat_if('#')) {
      break
    }
    ignore(self.s.eat_whitespace())
  }
  Spanned::new(elems, { start, end: self.s.cursor() })
}

///|
/// Eat a field.
fn BiblatexParser::field(
  self : BiblatexParser,
) -> (Spanned[String], Spanned[Field]) raise ParseError {
  let key = self.ident()
  ignore(self.s.eat_whitespace())
  ignore(self.equals())
  ignore(self.s.eat_whitespace())
  let value = self.abbr_field()
  ignore(self.s.eat_whitespace())
  self.comment()
  (key, value)
}

///|
/// Eat single field
fn BiblatexParser::single_field(
  self : BiblatexParser,
) -> Spanned[RawChunk] raise ParseError {
  match self.s.peek() {
    Some('{') => self.braced()
    Some('"') => {
      let string = self.string()
      Spanned::new(RawChunk::Normal(string.v), string.span)
    }
    _ => raise ParseError((self.here(), ParseErrorKind::UnexpectedEof))
  }
}

///|
/// Eat fields
fn BiblatexParser::fields(
  self : BiblatexParser,
) -> Array[Pair] raise ParseError {
  let fields = []
  while not(self.s.done()) {
    ignore(self.s.eat_whitespace())
    if self.s.peek() is Some('}') {
      return fields
    }
    let (key, value) = self.field()
    fields.push(Pair::new(key, value))
    ignore(self.s.eat_whitespace())
    match self.s.peek() {
      Some(',') => {
        self.comma()
        ignore(self.s.eat_whitespace())
        self.comment()
      }
      Some('}') => return fields
      _ =>
        raise ParseError((self.here(), ParseErrorKind::Expected(Token::Comma)))
    }
  }
  fields
}

///|
/// Eat an entry key.
fn BiblatexParser::key(self : BiblatexParser) -> Spanned[String] {
  let idx = self.s.cursor()
  ignore(self.s.eat_while(CharPredicate::new(is_key)))
  Spanned::new(self.s.from(idx), { start: idx, end: self.s.cursor() })
}

///|
/// Eat an identifier.
fn BiblatexParser::ident(
  self : BiblatexParser,
) -> Spanned[String] raise ParseError {
  let idx = self.s.cursor()
  let is_start = self.s.peek().map(is_id_start).unwrap_or_default()
  if is_start {
    ignore(self.s.eat())
    ignore(self.s.eat_while(CharPredicate::new(is_id_continue)))
    Spanned::new(self.s.from(idx), { start: idx, end: self.s.cursor() })
  } else {
    raise ParseError((self.here(), ParseErrorKind::Expected(Token::Identifier)))
  }
}

///|
/// Eat an entry.
fn BiblatexParser::entry(self : BiblatexParser) -> Unit raise ParseError {
  let start = self.s.cursor()
  if self.s.eat() != Some('@') {
    abort("must not call entry when not at an '@")
  }
  let entry_type = self.ident()
  ignore(self.s.eat_whitespace())
  self.brace(true)
  ignore(self.s.eat_whitespace())
  match entry_type.v.to_lower() {
    "string" => self.strings()
    "preamble" => self.preamble()
    "comment" => ignore(self.s.eat_until('}'))
    _ => self.body(entry_type, start)
  }
  ignore(self.s.eat_whitespace())
  self.brace(false)
  ()
}

///|
/// Eat the body of a strings entry.
fn BiblatexParser::strings(self : BiblatexParser) -> Unit raise ParseError {
  let fields = self.fields()
  self.res.abbreviations.append(fields)
  ()
}

///|
/// Eat the body of a preamble entry.
fn BiblatexParser::preamble(self : BiblatexParser) -> Unit raise ParseError {
  let idx = self.s.cursor()
  ignore(self.string())
  let string = self.s.from(idx)
  if not(self.res.preamble.is_empty()) {
    self.res.preamble += " # "
  }
  self.res.preamble += string
  ()
}

///|
/// Eat the body of an entry.
fn BiblatexParser::body(
  self : BiblatexParser,
  kind : Spanned[String],
  start : Int,
) -> Unit raise ParseError {
  let key = self.key()
  ignore(self.s.eat_whitespace())
  self.comma()
  ignore(self.s.eat_whitespace())
  self.comment()
  ignore(self.s.eat_whitespace())
  let fields = self.fields()
  let raw_entry : RawEntry = { key, kind, fields }
  self.res.entries.push(
    Spanned::new(raw_entry, { start, end: self.s.cursor() }),
  )
  ()
}

///|
fn BiblatexParser::comment(self : BiblatexParser) -> Unit {
  if self.s.eat_if('%') {
    ignore(self.s.eat_until('\n'))
  }
  ()
}

///|
fn BiblatexParser::here(self : BiblatexParser) -> Span {
  { start: self.s.cursor(), end: self.s.cursor() }
}

///|
/// The keys for fields and their values.
pub struct Pair {
  key : Spanned[String]
  value : Spanned[Field]
}

///|
pub fn Pair::new(key : Spanned[String], value : Spanned[Field]) -> Pair {
  { key, value }
}

///|
/// Whether a character is allowed in an entry key
pub fn is_key(c : Char) -> Bool {
  not(c is (',' | '}')) && not(c.is_control()) && not(c.is_whitespace())
}

///|
/// Whether a character can start an identifier.
pub fn is_id_start(c : Char) -> Bool {
  not(c is (':' | '<' | '-' | '>')) && is_id_continue(c)
}

///|
/// Whether a character can continue an identifier.
pub fn is_id_continue(c : Char) -> Bool {
  not(c is ('@' | '{' | '}' | '"' | '#' | '\'' | '(' | ')' | ',' | '=' | '%')) &&
  not(c.is_control()) &&
  not(c.is_whitespace())
}

///|
impl Show for Field with to_string(self) {
  let field = self.0
  if field.length() == 1 {
    let raw_chunk = field.get(0).unwrap().v
    if raw_chunk is Normal(s) {
      return "{\{s}}"
    }
  }
  let mut res : String = ""
  let mut first = true
  for field in field {
    if not(first) {
      res += " # "
    } else {
      first = false
    }
    match field.v {
      Normal(s) => res += "\"\{s}\""
      Abbreviation(s) => res += s
    }
  }
  res
}

///|
impl Show for Field with output(self, logger) {
  logger.write_string(self.to_string())
  logger.write_char('\n')
}

///|
fn test_prop(key : String, value : String) -> String {
  let t = "@article{test, \{key}=\{value}}"
  let bt = try? RawBibliogrphy::parse(t)
  let article = bt.unwrap().entries.get(0).unwrap()
  article.v.fields.get(0).unwrap().value.v.to_string()
}

///|
test "test_entry_key" {
  let file = "@article{!\"#$%&'()*+-./123:;<=>?@ABC[\\]^_`abc{|~,}"
  let bt = RawBibliogrphy::parse(file)
  let article = bt.entries[0]
  assert_eq(article.v.key.v, "!\"#$%&'()*+-./123:;<=>?@ABC[\\]^_`abc{|~")
}

///|
test "test_empty_entry_key" {
  let file = "@article{,}"
  let bt = RawBibliogrphy::parse(file)
  let article = bt.entries[0]
  assert_eq(article.v.key.v, "")
}

///|
test "test_parse_article" {
  let file =
    #|@article{haug2020,
    #|title = "Great proceedings\{",
    #|year = 2002,
    #|author = {Haug, {Martin} and Haug, Gregor}
    #|}
  let bt = RawBibliogrphy::parse(file)
  let article = bt.entries[0]
  assert_eq(article.v.kind.v, "article")
  assert_eq(article.v.fields[0].key.v, "title")
  assert_eq(article.v.fields[1].key.v, "year")
  assert_eq(article.v.fields[2].key.v, "author")
  assert_eq(article.v.fields[0].value.v.to_string(), "{Great proceedings\\{}")
  assert_eq(article.v.fields[1].value.v.to_string(), "{2002}")
  assert_eq(
    article.v.fields[2].value.v.to_string(),
    "{Haug, {Martin} and Haug, Gregor}",
  )
}

///|
test "test_resolve_string" {
  let bt = RawBibliogrphy::parse("@string{BT = \"bibtex\"}")
  assert_eq(bt.abbreviations[0].key.v, "BT")
  // assert_eq(bt.abbreviations[0].value.v, Array[Spanned::new(RawChunk::Normal("bibtex"), {start : 14,end : 20})])
}

///|
test "test_escape" {
  assert_eq(test_prop("author", "{Mister A\\}\"B\"}"), "{Mister A\\}\"B\"}")
}

///|
test "test_abbr" {
  assert_eq(test_prop("author", "dec # {~12}"), "dec # \"~12\"")
}

///|
test "test_parse_error" {
  let mut res = ""
  let parser : BiblatexParser = BiblatexParser::new("dont have comma")
  let _ = parser.comma() catch {
    ParseError((_, kind)) => res = kind.to_string()
  }
  assert_eq(res, "expected comma")
  let parser : BiblatexParser = BiblatexParser::new("dont have brace")
  let _ = parser.brace(true) catch {
    ParseError((_, kind)) => res = kind.to_string()
  }
  assert_eq(res, "expected opening brace")
  let parser : BiblatexParser = BiblatexParser::new("dont have qupte")
  let _ = parser.quote() catch {
    ParseError((_, kind)) => res = kind.to_string()
  }
  assert_eq(res, "expected double quote")
  let parser : BiblatexParser = BiblatexParser::new("\"unclosed")
  let _ = parser.string() catch {
    ParseError((_, kind)) => {
      res = kind.to_string()
      Spanned::detached("")
    }
  }
  assert_eq(res, "unexpected end of file")
  let parser : BiblatexParser = BiblatexParser::new("3.14.15")
  let _ = parser.number() catch {
    ParseError((_, kind)) => {
      res = kind.to_string()
      ""
    }
  }
  assert_eq(res, "unexpected decimal point")
  let parser : BiblatexParser = BiblatexParser::new("")
  let _ = parser.number() catch {
    ParseError((_, kind)) => {
      res = kind.to_string()
      ""
    }
  }
  assert_eq(res, "unexpected end of file")
  let parser : BiblatexParser = BiblatexParser::new("{unclosed")
  let _ = parser.braced() catch {
    ParseError((_, kind)) => {
      res = kind.to_string()
      Spanned::detached(RawChunk::Normal(""))
    }
  }
  assert_eq(res, "unexpected end of file")
  let parser : BiblatexParser = BiblatexParser::new("")
  let _ = parser.single_field() catch {
    ParseError((_, kind)) => {
      res = kind.to_string()
      Spanned::detached(RawChunk::Normal(""))
    }
  }
  assert_eq(res, "unexpected end of file")
  let parser : BiblatexParser = BiblatexParser::new("author=Alice title=Book")
  let _ = parser.fields() catch {
    ParseError((_, kind)) => {
      res = kind.to_string()
      [Pair::new(Spanned::detached(""), Spanned::detached([]))]
    }
  }
  assert_eq(res, "expected comma")
  let parser : BiblatexParser = BiblatexParser::new(":123invalid")
  let _ = parser.ident() catch {
    ParseError((_, kind)) => {
      res = kind.to_string()
      Spanned::detached("")
    }
  }
  assert_eq(res, "expected identifier")
}

///|
test "test_preamble" {
  let s = "@preamble{\"Some text\"}\n@preamble{\"First\"}\n@preamble{\"Second\"}"
  let bt = RawBibliogrphy::parse(s)
  assert_eq(bt.preamble, "\"Some text\" # \"First\" # \"Second\"")
}

///|
test "test_show" {
  let error = ParseError(({ start: 1, end: 2 }, UnexpectedEof))
  let logger : StringBuilder = StringBuilder::new()
  error.output(logger)
  let field : Field = []
  field.output(logger)
  let t1 = Token::Equals
  let t2 = Token::ClosingBrace
  t1.output(logger)
  t2.output(logger)
  let kind1 = ParseErrorKind::DuplicateKey("key")
  let kind2 = ParseErrorKind::MalformedCommand
  let kind3 = ParseErrorKind::UnknownAbbreviation("abbr")
  let kind4 = ParseErrorKind::ResolutionError(UndefinedRange)
  kind1.output(logger)
  kind2.output(logger)
  kind3.output(logger)
  kind4.output(logger)
  println(logger)
}

///|
test "panic_entry" {
  let parser : BiblatexParser = BiblatexParser::new("preamble{\"Some text\"}")
  let _ = parser.entry()

}
