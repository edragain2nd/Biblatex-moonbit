///|
/// An error that may occur while parsing the chunks in a field into a specific
pub(all) suberror TypeError (Span, TypeErrorKind) derive(Eq)

///|
pub impl Show for TypeError with to_string(self) {
  match self {
    TypeError((span, kind)) => "\{kind}: \{span.start}-\{span.end}"
  }
}

///|
pub impl Show for TypeError with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
/// Error conditions that might occur while parsing the chunks in a field into a specific
/// [`Type`].
///
/// Also see [`TypeError`].
pub(all) enum TypeErrorKind {
  /// The date range was open on both sides.
  UndefinedRange
  /// The day in a date was out of range (1-31).
  DayOutOfRange
  /// The month in a date was out of range (1-12).
  MonthOutOfRange
  /// The given input did not contain a valid number.
  InvalidNumber
  /// The given input did not contain a number.
  MissingNumber
  /// A number did not have the right number of digits.
  WrongNumberOfDigits
  /// The entry was not in a format valid for that type.
  InvalidFormat
  /// There is no [`Gender`] variant for this input.
  UnknownGender
  /// There was no integer range.
  InvalidIntegerRange
  /// There is no [`Pagination`] variant for this input.
  UnknownPagination
  /// There is no [`EditorType`] variant for this input.
  UnknownEditorType
  /// There is no [`Language`] variant for this input.
  UnknownLangId
  /// The year 0 CE or BCE does not exist.
  YearZeroCE
} derive(Eq)

///|
pub impl Show for TypeErrorKind with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl Show for TypeErrorKind with to_string(self) {
  match self {
    UndefinedRange => "range must not be open on both sides"
    DayOutOfRange => "day out of range (must be between 1 and 31)"
    MonthOutOfRange => "month out of range (must be between 1 and 12)"
    InvalidNumber => "invalid number"
    MissingNumber => "missing number"
    WrongNumberOfDigits => "wrong number of digits"
    InvalidFormat => "invalid format"
    UnknownGender => "unknown gender"
    InvalidIntegerRange => "invalid integer range"
    UnknownPagination => "unknown pagination"
    UnknownEditorType => "unknown editor type"
    UnknownLangId => "unknown language id"
    YearZeroCE => "year 0 CE or BCE does not exist"
  }
}

///|
/// Convert Bib(La)TeX data types from and to chunk slices.
pub trait Type {
  /// Parse the type from chunks.
  from_chunks(chunks : Chunks) -> Self raise TypeError
  /// Serialize the type into chunks.
  ///
  /// This produces chunks with _detached spans_ that must not be used to
  /// index the source file.
  to_chunks(Self) -> Chunks
}

///|
pub impl Type for Int64 with from_chunks(chunks) {
  let span = ChunkExt::span(chunks)
  let s = ChunkExt::format_verbatim(chunks)
  let s = s.trim_space_start().trim_space_end()
  try {
    if @strconv.parse_int64(s) is n {
      n
    } else if Roman::parse(s) is Some(roman) {
      roman.value().to_int64()
    } else if span.is_empty() {
      raise TypeError((span, TypeErrorKind::MissingNumber))
    } else {
      raise TypeError((span, TypeErrorKind::InvalidNumber))
    }
  } catch {
    @strconv.StrConvError(_) =>
      raise TypeError((span, TypeErrorKind::InvalidNumber))
    TypeError((span, error_kind)) => raise TypeError((span, error_kind))
    _ => raise TypeError((span, TypeErrorKind::InvalidNumber))
  }
}

///|
pub impl Type for Int64 with to_chunks(self) {
  let str = self.to_string()
  [Spanned::detached(Chunk::Normal(str))]
}

///|
pub impl Type for String with from_chunks(chunks) {
  ChunkExt::format_verbatim(chunks)
}

///|
pub impl Type for String with to_chunks(self) {
  [Spanned::detached(Verbatim(self))]
}

///|
/// This is a ​​proxy type​​ that aliases Array[Chunks]
/// (array of Chunks objects) to the concrete type ArrayChunks. 
/// Its primary purpose is to enable trait implementations for the Array generic type when specialized to Chunks
pub(all) type ArrayChunks Array[Chunks] derive(Show,Eq)

///|
pub impl Type for ArrayChunks with from_chunks(chunk) {
  split_token_lists_with_kw(chunk, "and")
}

///|
pub impl Type for ArrayChunks with to_chunks(self) {
  let merged = []
  let mut first = true
  for chunk in self.inner() {
    if first {
      first = false
    } else {
      merged.push(Spanned::detached(Chunk::Normal(" and ")))
    }
    merged.append(chunk)
  }
  merged
}

///|
/// This is a ​​proxy type​​ that aliases Array[String]
/// (array of String objects) to the concrete type ArrayString. 
/// Its primary purpose is to enable trait implementations for the Array generic type when specialized to String
pub(all) type ArrayString Array[String] derive(Show,Eq)

///|
pub impl Type for ArrayString with from_chunks(chunks) {
  split_token_lists(chunks, ",")
  .iter()
  .map(chunks => ChunkExt::format_verbatim(chunks))
  .collect()
}

///|
pub impl Type for ArrayString with to_chunks(self) {
  let chunks = self
    .inner()
    .iter()
    .map(s => Spanned::detached(Chunk::Normal(s)))
    .collect()
  join_chunk_list(chunks, ",")
}

///|
/// A value that could be either a typed value or a literal string.
pub(all) enum PermissiveType[T] {
  /// A typed version of the value.
  Typed(T)
  /// A literal string, for example `"Reprinted, and revised edition"`.
  Chunks(Chunks)
} derive(Show, Eq)

///|
/// usage:
/// ```moonbit
/// let chunks : Chunks = [{v: Normal("Monroe, Brian Albert"), span: {start: 2147483647, end: 2147483647}}]
/// let res : PermissiveType[ArrayPerson] = PermissiveType::from_chunks(chunks)
/// inspect(res,content="Typed(ArrayPerson([Brian Albert Monroe]))")
/// ```
pub fn[T : Type] PermissiveType::from_chunks(
  chunks : Chunks,
) -> PermissiveType[T] {
  try {
    let val : T = parse_chunks(chunks)
    PermissiveType::Typed(val)
  } catch {
    _ => PermissiveType::Chunks(chunks)
  }
}

///|

///|
/// usage:
/// ```moonbit
/// let chunks : Chunks = [{v: Normal("Monroe, Brian Albert"), span: {start: 2147483647, end: 2147483647}}]
/// let res : PermissiveType[ArrayPerson] = PermissiveType::from_chunks(chunks)
/// let chunks_ = PermissiveType::to_chunks(res)
/// inspect(chunks_,content="[{v: Normal(\"Monroe, Brian Albert\"), span: {start: 2147483647, end: 2147483647}}]")
/// ```
pub fn[T : Type] PermissiveType::to_chunks(self : PermissiveType[T]) -> Chunks {
  match self {
    Typed(val) => val.to_chunks()
    Chunks(chunks) => chunks
  }
}

///|
pub impl Type for Array[PermissiveType[Language]] with from_chunks(chunks) {
  split_token_lists_with_kw(chunks, "and")
  .iter()
  .map(c => PermissiveType::from_chunks(c))
  .collect()
}

///|
pub impl Type for Array[PermissiveType[Language]] with to_chunks(self) {
  let merged = []
  let mut first = true
  for chunk in self {
    if first {
      first = false
    } else {
      merged.push(Spanned::detached(Chunk::Verbatim(" and ")))
    }
    merged.append(chunk.to_chunks())
  }
  merged
}

///|
/// Defines the pagination scheme to use for formatting purposes.
pub(all) enum Pagination {
  Page
  Column
  Line
  Verse
  Section
  Paragraph
} derive(Show)

///|
pub fn Pagination::from_str(s : String) -> Pagination? {
  match s {
    "page" => Some(Page)
    "column" => Some(Column)
    "line" => Some(Line)
    "verse" => Some(Verse)
    "Section" => Some(Section)
    "paragraph" => Some(Paragraph)
    _ => None
  }
}

///|
pub impl Type for Pagination with from_chunks(chunks) {
  let span = ChunkExt::span(chunks)
  let pagination = Pagination::from_str(
    ChunkExt::format_verbatim(chunks).to_lower(),
  )
  if pagination is Some(pagination) {
    pagination
  } else {
    raise TypeError((span, TypeErrorKind::UnknownPagination))
  }
}

///|
pub impl Type for Pagination with to_chunks(self) {
  let res = self.to_string()
  [Spanned::detached(Normal(res))]
}

///|
/// Which role the according editor had.
///
/// The value of the `editor` through `editorc` fields.
pub(all) enum EditorType {
  Editor
  Compiler
  Founder
  Continuator
  Redactor
  Reviser
  Collaborator
  Organizer
  Director
  Unknown(String)
} derive(Show, Eq)

///|
pub fn EditorType::from_str(s : String) -> EditorType? {
  let editor = match s {
    "editor" => Editor
    "compiler" => Compiler
    "founder" => Founder
    "continuator" => Continuator
    "redactor" => Redactor
    "reviser" => Reviser
    "collaborator" => Collaborator
    "Organizer" => Organizer
    "director" => Director
    _ => Unknown(s)
  }
  Some(editor)
}

///|
pub impl Type for EditorType with from_chunks(chunks) {
  let span = ChunkExt::span(chunks)
  if EditorType::from_str(ChunkExt::format_verbatim(chunks).to_lower())
    is Some(editor_type) {
    editor_type
  } else {
    raise TypeError((span, TypeErrorKind::UnknownEditorType))
  }
}

///|
pub impl Type for EditorType with to_chunks(self) {
  let res = self.to_string()
  [Spanned::detached(Normal(res))]
}

///|
pub(all) enum Gender {
  SingularFemale
  SingularMale
  SingularNeuter
  PluralFemale
  PluralMale
  PluralNeuter
} derive(Show)

///|
pub fn Gender::plural(self : Gender) -> Gender {
  match self {
    SingularFemale => PluralFemale
    SingularMale => PluralMale
    SingularNeuter => PluralNeuter
    _ => self
  }
}

///|
pub fn Gender::singular(self : Gender) -> Gender {
  match self {
    PluralFemale => SingularFemale
    PluralMale => SingularMale
    PluralNeuter => SingularNeuter
    _ => self
  }
}

///|
pub fn Gender::coalesce(list : Array[Gender]) -> Gender? {
  if list.is_empty() {
    return None
  }
  if list.length() == 1 {
    return Some(list[0])
  }
  let mut was_female = false
  let mut was_male = false
  let mut was_neuter = false
  for g in list {
    match g {
      SingularFemale | PluralFemale => was_female = true
      SingularMale | PluralMale => was_male = true
      SingularNeuter | PluralNeuter => was_neuter = true
    }
  }
  if was_female && not(was_male) && not(was_neuter) {
    Some(PluralFemale)
  } else if was_male && not(was_female) && not(was_neuter) {
    Some(PluralMale)
  } else {
    Some(PluralNeuter)
  }
}

///|
pub impl Type for Gender with from_chunks(chunks) {
  let span = ChunkExt::span(chunks)
  match ChunkExt::format_verbatim(chunks).to_lower() {
    "sf" => SingularFemale
    "sm" => SingularMale
    "sn" => SingularNeuter
    "pf" => PluralFemale
    "pm" => PluralMale
    "pn" => PluralNeuter
    _ => raise TypeError((span, TypeErrorKind::UnknownGender))
  }
}

///|
pub impl Type for Gender with to_chunks(self) {
  let res = self.to_string()
  [Spanned::detached(Chunk::Normal(res))]
}

///|
pub(all) struct Range {
  start : Int
  end : Int
} derive(Show, Eq)

///|
pub impl Type for Range with from_chunks(chunks) {
  let span = ChunkExt::span(chunks)
  let array_range : ArrayRange = parse_chunks(chunks)
  let range = array_range.inner().get(0)
  if range is Some(range) {
    range
  } else {
    raise TypeError((span, InvalidIntegerRange))
  }
}

///|
pub impl Type for Range with to_chunks(self) {
  let str = "\{self.start}-\{self.end}"
  [Spanned::detached(Chunk::Normal(str))]
}

///|
/// This is a ​​proxy type​​ that aliases Array[Range]
/// (array of Range objects) to the concrete type ArrayRange. 
/// Its primary purpose is to enable trait implementations for the Array generic type when specialized to Range
pub(all) type ArrayRange Array[Range] derive(Show,Eq)

///|
pub impl Type for ArrayRange with from_chunks(chunks) {
  let range_arrays = split_token_lists(chunks, ",")
  let res = []
  let number = fn(s : Scanner, offset : Int) -> Int raise TypeError {
    ignore(s.eat_whitespace())
    let idx = s.cursor()
    let num = s.eat_while(CharPredicate::new(c => c.is_ascii_digit()))
    @strconv.parse_int(num) catch {
      _ =>
        raise TypeError(
          ({ start: idx + offset, end: s.cursor() + offset }, InvalidNumber),
        )
    }
  }
  let component = fn(s : Scanner, offset : Int) -> Int raise TypeError {
    for {
      let num = number(s, offset)
      ignore(s.eat_whitespace())
      if not(s.eat_if(':')) {
        return num
      }
    }
  }
  for
    pair in range_arrays.map(f => (
      ChunkExt::format_verbatim(f),
      ChunkExt::span(f),
    )) {
    let range_candidate = pair.0
    let span = pair.1
    let s = Scanner::new(range_candidate)
    let start = component(s, span.start)
    ignore(s.eat_whitespace())
    if not(s.eat_if(['-', '–', '—'])) {
      res.push({ start, end: start })
      continue
    }
    ignore(s.eat_while('-'))
    ignore(s.eat_whitespace())
    let end = component(s, span.start)
    res.push({ start, end })
  }
  res
}

///|
pub impl Type for ArrayRange with to_chunks(self) {
  let chunks = self
    .inner()
    .map(range => {
      let str = "\{range.start}-\{range.end}"
      Spanned::detached(Chunk::Normal(str))
    })
  join_chunk_list(chunks, ",")
}
