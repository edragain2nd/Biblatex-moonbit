///|
typealias @types.TypeError

///|
typealias @types.Span

///|
pub(all) struct Bibliography {
  entries : Array[Entry]
  keys : Map[String, UInt]
} derive(Default)

///|
pub(all) struct Entry {
  key : String
  entry_type : EntryType
  fields : Map[String, Chunks]
}

///|
pub(all) struct Spanned[T] {
  v : T
  span : Span
}

///|
pub fn[T] Spanned::new(v : T, span : Span) -> Spanned[T] {
  { v, span }
}

///|
pub(all) enum RetrievalError {
  Missing(String)
  TypeError(TypeError)
}

///|
impl Show for RetrievalError with output(self, logger) {
  match self {
    Missing(s) => logger.write_string("field \{s} is missing")
    TypeError(err) => logger.write_string(err.to_string())
  }
}
