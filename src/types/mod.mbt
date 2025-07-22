///|
typealias @span.Span

///|
pub(all) struct TypeError {
  span : Span
  kind : TypeErrorKind
}

///|
pub impl Show for TypeError with to_string(self) {
  "\{self.kind} : \{self.span.start} - \{self.span.end}"
}

///|
pub impl Show for TypeError with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
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
}

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

