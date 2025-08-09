///|
typealias @unscanny.Scanner

///|
typealias @unscanny.CharPredicate

///|
/// A date or a range of dates and their certainty and exactness.
pub(all) struct Date {
  /// The date or the date range.
  value : DateValue
  /// Indicates whether the sources are sure about the date.
  uncertain : Bool
  /// Indicates the specificity of the date value.
  approximate : Bool
} derive(Show, Eq)

///|
/// A single date or a range of dates.
pub enum DateValue {
  At(Datetime)
  After(Datetime)
  Before(Datetime)
  Between(Datetime, Datetime)
} derive(Show, Eq)

///|
/// Timezone-unaware date and time.
///
/// Must specify a year and may specify month, day, and time.
pub(all) struct Datetime {
  mut year : Int
  mut month : UInt?
  mut day : UInt?
  mut time : Time?
} derive(Eq)

///|
/// A potentially timezone aware time.
struct Time {
  /// The hour (0-23).
  hour : UInt
  /// The minute (0-59).
  minute : UInt
  /// The second (0-59).
  second : UInt
  /// An optional timezone offset.
  offset : TimeOffset?
} derive(Show, Eq)

///|
/// Create a new time from hours, minutes, and seconds. Return `None` if
/// the values are out of range.
pub fn Time::from_hms(hour : UInt, minute : UInt, second : UInt) -> Self? {
  guard hour <= 23 && minute <= 59 && second <= 59 else { return None }
  Some({ hour, minute, second, offset: None })
}

///|
/// Create a new time from hours, minutes, seconds and an offset. Return
/// `None` if the values are out of range.
pub fn Time::from_hms_offset(
  hour : UInt,
  minute : UInt,
  second : UInt,
  offset : TimeOffset,
) -> Self? {
  guard hour <= 23 && minute <= 59 && second <= 59 else { return None }
  Some({ hour, minute, second, offset: Some(offset) })
}

///|
/// Return seconds in UTC.
pub fn Time::to_utc_seconds(self : Time) -> Int {
  let mut seconds = self.hour.reinterpret_as_int() * 3600 +
    self.minute.reinterpret_as_int() * 60 +
    self.second.reinterpret_as_int()
  seconds -= match self.offset {
    Some(offset) => offset.to_seconds()
    None => 0
  }
  seconds
}

///|
pub impl Compare for Time with compare(self, other) {
  if (self.offset is Some(_) && other.offset is Some(_)) ||
    (self.offset is None && other.offset is None) {
    self.to_utc_seconds().compare(other.to_utc_seconds())
  } else {
    0
  }
}

///|
/// A timezone offset.
pub enum TimeOffset {
  /// Time is UTC. Do not assume an origin timezone.
  Utc
  /// Offser(positive, hours, minutes)
  /// positive: Whether the time is ahead of UTC.
  /// hours: The hour offset.
  /// minutes: The minute offset.
  Offset(Bool, UInt, UInt)
} derive(Show, Eq)

///|
/// Create a new offset.
pub fn TimeOffset::offset(
  positive : Bool,
  hours : UInt,
  minutes : UInt,
) -> TimeOffset {
  Offset(positive, hours, minutes)
}

///|
/// Create a new offset from an hour.
pub fn TimeOffset::offset_hour(hour : Int) -> TimeOffset {
  if hour < 0 {
    Offset(false, (-hour).reinterpret_as_uint(), 0)
  } else {
    Offset(true, hour.reinterpret_as_uint(), 0)
  }
}

///|
/// Convert to seconds.
fn TimeOffset::to_seconds(self : TimeOffset) -> Int {
  match self {
    Utc => 0
    Offset(positive, hours, minutes) => {
      let mut seconds = hours.reinterpret_as_int() * 3600 +
        minutes.reinterpret_as_int() * 60
      if not(positive) {
        seconds *= -1
      }
      seconds
    }
  }
}

///|
/// Parse a date from chunks.
pub fn Date::parse(chunks : Chunks) -> Date raise TypeError {
  let span = ChunkExt::span(chunks)
  let date = ChunkExt::format_verbatim(chunks).to_upper()
  let mut date_trimmed = date.trim_space_end()
  let is_both = date_trimmed.has_suffix("%")
  let is_uncertain = is_both || date_trimmed.has_suffix("?")
  let is_approximate = is_both || date_trimmed.has_suffix("~")
  if is_uncertain || is_approximate {
    date_trimmed = date_trimmed.substring(end=date_trimmed.length() - 1)
  }
  let value = if date_trimmed.contains("X") {
    let (d1, d2) = Date::range_dates(date_trimmed) catch {
      TypeError((s, kind)) =>
        raise TypeError(
          (
            {
              start: s.start.saturating_add(span.start),
              end: s.end.saturating_add(span.start),
            },
            kind,
          ),
        )
    }
    DateValue::Between(d1, d2)
  } else if date_trimmed.find("/") is Some(pos) {
    let s1 = date_trimmed.substring(end=pos)
    let s2 = date_trimmed.substring(start=pos + 1)
    fn is_open_range(s : String) -> Bool {
      s.trim_space_start().trim_space_end().is_empty() || s == ".."
    }

    match (is_open_range(s1), is_open_range(s2)) {
      (false, false) => {
        let d1 = Datetime::parse(s1) catch {
          TypeError((s, kind)) =>
            raise TypeError(
              (
                {
                  start: s.start.saturating_add(span.start),
                  end: s.end.saturating_add(span.start),
                },
                kind,
              ),
            )
        }
        let d2 = Datetime::parse(s2) catch {
          TypeError((s, kind)) =>
            raise TypeError(
              (
                {
                  start: s.start.saturating_add(span.start + pos + 1),
                  end: s.end.saturating_add(span.start + pos + 1),
                },
                kind,
              ),
            )
        }
        DateValue::Between(d1, d2)
      }
      (false, true) => {
        let d1 = Datetime::parse(s1) catch {
          TypeError((s, kind)) =>
            raise TypeError(
              (
                {
                  start: s.start.saturating_add(span.start),
                  end: s.end.saturating_add(span.start),
                },
                kind,
              ),
            )
        }
        DateValue::After(d1)
      }
      (true, false) => {
        let d2 = Datetime::parse(s2) catch {
          TypeError((s, kind)) =>
            raise TypeError(
              (
                {
                  start: s.start.saturating_add(span.start + pos + 1),
                  end: s.end.saturating_add(span.start + pos + 1),
                },
                kind,
              ),
            )
        }
        DateValue::Before(d2)
      }
      (true, true) => raise TypeError((span, TypeErrorKind::UndefinedRange))
    }
  } else {
    let d = Datetime::parse(date_trimmed) catch {
      TypeError((s, kind)) =>
        raise TypeError(
          (
            {
              start: s.start.saturating_add(span.start),
              end: s.end.saturating_add(span.start),
            },
            kind,
          ),
        )
    }
    DateValue::At(d)
  }
  { approximate: is_approximate, uncertain: is_uncertain, value }
}

///|
/// Create a new date from `year`, `month`, and `day` chunks.
pub fn Date::parse_three_fields(
  year : Chunks,
  month : Chunks?,
  day : Chunks?,
) -> Date raise TypeError {
  let span = ChunkExt::span(year)
  let year = get_year(Scanner::new(ChunkExt::format_verbatim(year))) catch {
    TypeError((s, kind)) =>
      raise TypeError(
        (
          {
            start: s.start.saturating_add(span.start),
            end: s.end.saturating_add(span.start),
          },
          kind,
        ),
      )
  }
  let date_atom = { year, month: None, day: None, time: None }
  if month is Some(month) {
    let month = ChunkExt::format_verbatim(month)
    let s = Scanner::new(month)
    ignore(s.eat_whitespace())
    let month = s.eat_while(CharPredicate::new(Char::is_ascii_alphabetic))
    date_atom.month = match get_month_for_name(month) {
      Some(month) => Some(month)
      None =>
        match get_month_for_abbr(month) {
          Some((_, month)) => Some(month.reinterpret_as_uint())
          None => None
        }
    }
    if day is Some(day) {
      let span = ChunkExt::span(day)
      let day = ChunkExt::format_verbatim(day)
      let day : UInt = @strconv.parse_uint(
        day.trim_space_start().trim_space_end(),
      ) catch {
        @strconv.StrConvError(_) =>
          if span.is_empty() {
            raise TypeError((span, MissingNumber))
          } else {
            raise TypeError((span, InvalidNumber))
          }
      }
      if day < 1 || day > 31 {
        raise TypeError((span, DayOutOfRange))
      }
      date_atom.day = Some(day - 1)
    } else {
      if s
        .eat_while(
          CharPredicate::new(c => c.is_whitespace() || c is ('-' | '\u{00a0}')),
        )
        .is_empty() {
        return Date::from_datetime(date_atom)
      }
      let day_start = s.cursor()
      let day = s.eat_while(CharPredicate::new(Char::is_ascii_digit))
      let day_span : Span = { start: day_start, end: s.cursor() }
      if day.is_empty() {
        raise TypeError((day_span, MissingNumber))
      }
      let day = @strconv.parse_uint(day) catch { _ => 0 }
      if day < 1 || day > 31 {
        raise TypeError((day_span, DayOutOfRange))
      }
      date_atom.day = Some(day - 1)
    }
  }
  Date::from_datetime(date_atom)
}

///|
fn Date::from_datetime(atom : Datetime) -> Date {
  { approximate: false, uncertain: false, value: DateValue::At(atom) }
}

///|
fn Date::range_dates(source : String) -> (Datetime, Datetime) raise TypeError {
  let s = Scanner::new(source)
  ignore(s.eat_whitespace())
  let year_part = s.eat_while(CharPredicate::new(Char::is_ascii_digit))
  let sure_digits = year_part.length()
  let mut variables = 1
  for _ in 1..=(4 - sure_digits) {
    variables *= 10
  }
  if sure_digits < 2 || s.eat_while('X').length() + sure_digits != 4 {
    raise TypeError(({ start: 0, end: s.cursor() }, WrongNumberOfDigits))
  }
  let year = (@strconv.parse_int(year_part) * variables) catch { _ => 0 }
  variables -= 1
  if sure_digits != 4 {
    return (
      { year, month: None, day: None, time: None },
      { year: year + variables, month: None, day: None, time: None },
    )
  }
  get_hyphen(s)
  let idx = s.cursor()
  match s.eat_while('X').length() {
    0 => {
      let month_start = s.cursor()
      let month = s.eat_while(CharPredicate::new(Char::is_ascii_digit))
      if month.length() != 2 {
        raise TypeError(({ start: idx, end: s.cursor() }, WrongNumberOfDigits))
      }
      let month = @strconv.parse_uint(month) catch { _ => 0 }
      if month > 11 {
        raise TypeError(
          ({ start: month_start, end: s.cursor() }, MonthOutOfRange),
        )
      }
      get_hyphen(s)
      if s.eat_while('X').length() == 2 {
        ignore(s.eat_whitespace())
        if not(s.done()) {
          raise TypeError((here(s), InvalidFormat))
        }
        return (
          { year, month: Some(month), day: Some(0), time: None },
          { year, month: Some(month), day: Some(30), time: None },
        )
      }
      raise TypeError((here(s), InvalidFormat))
    }
    2 => {
      ignore(s.eat_whitespace())
      if not(s.done()) {
        get_hyphen(s)
        if s.eat_while('X').length() != 2 {
          raise TypeError((here(s), InvalidFormat))
        }
      }
      (
        { year, month: Some(0), day: None, time: None },
        { year, month: Some(11), day: None, time: None },
      )
    }
    _ => raise TypeError(({ start: idx, end: s.cursor() }, WrongNumberOfDigits))
  }
}

///|
pub fn Date::to_fieldset(self : Date) -> Array[(String, String)] {
  self.value.to_fieldset()
}

///|
fn get_year(s : Scanner) -> Int raise TypeError {
  ignore(s.eat_whitespace())
  let year_idx = s.cursor()
  let has_sign = s.eat_if(['-', '+'])
  ignore(s.eat_whitespace())
  let digits = s.eat_while(CharPredicate::new(Char::is_ascii_digit))
  if digits.is_empty() || digits.length() > 4 {
    raise TypeError(({ start: year_idx, end: s.cursor() }, WrongNumberOfDigits))
  }
  let year = @strconv.parse_int(s.from(year_idx)) catch { _ => 0 }
  if parse_era_marker(s) is Some(positive_era) {
    if has_sign {
      raise TypeError(({ start: year_idx, end: s.cursor() }, InvalidFormat))
    }
    if year == 0 {
      raise TypeError(({ start: year_idx, end: s.cursor() }, YearZeroCE))
    }
    if not(positive_era) {
      return -year + 1
    }
  }
  year
}

///|
fn parse_era_marker(s : Scanner) -> Bool? raise TypeError {
  ignore(s.eat_whitespace())
  let era_idx = s.cursor()
  if s.eat_if("AD") || s.eat_if("CE") {
    //FIXME: moonbit only surpport is_ascii_alphabetic
    if s.peek() is Some(c) && (c.is_ascii_alphabetic() || c.is_numeric()) {
      raise TypeError(({ start: era_idx, end: s.cursor() }, InvalidFormat))
    }
    return Some(true)
  }
  if s.eat_if("BC") {
    ignore(s.eat_if("E"))
    if s.peek() is Some(c) && (c.is_ascii_alphabetic() || c.is_numeric()) {
      raise TypeError(({ start: era_idx, end: s.cursor() }, InvalidFormat))
    }
    return Some(false)
  }
  None
}

///|
fn get_hyphen(s : Scanner) -> Unit raise TypeError {
  ignore(s.eat_whitespace())
  if s.eat_while('-').is_empty() {
    raise TypeError((here(s), InvalidFormat))
  }
  ignore(s.eat_whitespace())
  ()
}

///|
fn here(s : Scanner) -> Span {
  { start: s.cursor(), end: s.cursor() }
}

///|
pub impl Type for Date with from_chunks(chunks) {
  Date::parse(chunks)
}

///|
pub impl Type for Date with to_chunks(self) {
  let mut s = match self.value {
    Before(end) => "../\{end}"
    After(start) => "\{start}/.."
    At(date) => "\{date}"
    Between(start, end) => "\{start}/\{end}"
  }
  s += match (self.approximate, self.uncertain) {
    (true, true) => "%"
    (true, false) => "~"
    (false, true) => "?"
    (false, false) => ""
  }
  [Spanned::detached(Chunk::Normal(s))]
}

///|
pub fn DateValue::to_fieldset(self : DateValue) -> Array[(String, String)] {
  match self {
    At(date) | After(date) | Before(date) => date.to_fieldset()
    Between(start, end) => {
      let set = start.to_fieldset()
      set.append(end.to_fieldset().map(kv => ("end\{kv.0}", kv.1)))
      set
    }
  }
}

///|
fn Datetime::parse(src : String) -> Datetime raise TypeError {
  let s = Scanner::new(src)
  let pos = s.cursor()
  let year = parse_short_year(s) catch {
    _ => {
      s.jump(pos)
      parse_year(s)
    }
  }
  let mut month = None
  let mut day = None
  ignore(s.eat_whitespace())
  if s.done() {
    return { year, month, day, time: None }
  }
  parse_hyphen(s)
  let some_month = parse_month(s)
  month = Some(some_month)
  ignore(s.eat_whitespace())
  if s.done() {
    return { year, month, day, time: None }
  }
  parse_hyphen(s)
  let some_day = parse_day(s)
  day = Some(some_day)
  if some_day + 1 > days_in_month(some_month, year) {
    raise TypeError(({ start: pos, end: s.cursor() }, DayOutOfRange))
  }
  ignore(s.eat_whitespace())
  if s.done() {
    return { year, month, day, time: None }
  }
  if not(s.eat_if('T')) {
    raise TypeError(({ start: pos, end: s.cursor() }, InvalidFormat))
  }
  let hour = parse_hour(s)
  ignore(s.eat_whitespace())
  if s.done() {
    return {
      year,
      month,
      day,
      time: Some({ hour, minute: 0, second: 0, offset: None }),
    }
  }
  parse_colon(s)
  let minute = parse_minutes_or_seconds(s)
  ignore(s.eat_whitespace())
  if s.done() {
    return {
      year,
      month,
      day,
      time: Some({ hour, minute, second: 0, offset: None }),
    }
  }
  parse_colon(s)
  let second = parse_minutes_or_seconds(s)
  ignore(s.eat_whitespace())
  if s.done() {
    return {
      year,
      month,
      day,
      time: Some({ hour, minute, second, offset: None }),
    }
  }
  let offset = parse_offset(s)
  return {
    year,
    month,
    day,
    time: Some({ hour, minute, second, offset: Some(offset) }),
  }
}

///|
pub fn Datetime::to_fieldset(self : Datetime) -> Array[(String, String)] {
  let year = format_year(self.year)
  let fields = [("year", year)]
  if self.month is Some(month) {
    fields.push(("month", format_month_or_day(month + 1)))
    if self.day is Some(day) {
      fields.push(("day", format_month_or_day(day + 1)))
    }
  }
  fields
}

///|
pub impl Compare for Datetime with compare(self, other) {
  let year_ord = self.year.compare(other.year)
  if year_ord != 0 {
    if year_ord == 1 {
      return 1
    } else {
      return -1
    }
  }
  let month_ord : Int = match (self.month, other.month) {
    (Some(s), Some(o)) => s.compare(o)
    _ => 0
  }
  if month_ord != 0 {
    return month_ord
  }
  let day_ord : Int = match (self.day, other.day) {
    (Some(s), Some(o)) => s.compare(o)
    _ => 0
  }
  if day_ord != 0 {
    return day_ord
  }
  match (self.time, other.time) {
    (Some(s), Some(o)) => s.compare(o)
    _ => 0
  }
}

///|
pub impl Show for Datetime with to_string(self) {
  let mut res = format_year(self.year)
  if self.month is Some(month) {
    if self.day is Some(day) {
      res += "-\{format_month_or_day((month+1))}-\{format_month_or_day(day+1)}"
    } else {
      res += "-\{format_month_or_day((month+1))}"
    }
  }
  res
}

///|
pub impl Show for Datetime with output(self, logger) {
  logger.write_string(self.to_string())
  logger.write_char('\n')
}

///|
fn parse_int(s : Scanner, lb : Int, ub : Int) -> Int? {
  ignore(s.eat_whitespace())
  let sign = s.eat_if(CharPredicate::new(c => c is ('+' | '-')))
  let positive = if sign { not(s.before().has_suffix("-")) } else { true }
  ignore(s.eat_whitespace())
  let num = s.eat_while(CharPredicate::new(Char::is_numeric))
  if num.length() < lb || num.length() > ub {
    return None
  }
  let mul = if positive { 1 } else { -1 }
  let num = (@strconv.parse_int(num) * mul) catch { _ => return None }
  Some(num)
}

///|
fn parse_unsigned_int(s : Scanner, lb : Int, ub : Int) -> UInt? {
  ignore(s.eat_whitespace())
  let num = s.eat_while(CharPredicate::new(Char::is_numeric))
  if num.length() < lb || num.length() > ub {
    return None
  }
  let num = @strconv.parse_uint(num) catch { _ => return None }
  Some(num)
}

///|
/// Parse a string with a plus/minus and one to four digits into an integer.
fn parse_year(s : Scanner) -> Int raise TypeError {
  let pos = s.cursor()
  parse_int(s, 4, 4).or_error(
    TypeError(({ start: pos, end: s.cursor() }, InvalidFormat)),
  )
}

///|
fn parse_short_year(s : Scanner) -> Int raise TypeError {
  let pos = s.cursor()
  let year = parse_int(s, 2, 2).or_error(
    TypeError(({ start: pos, end: s.cursor() }, InvalidFormat)),
  )
  let year = if year < 50 { year + 2000 } else { year + 1900 }
  year
}

///|
/// Parse the month in the 0-11 range.
fn parse_month(s : Scanner) -> UInt raise TypeError {
  let pos = s.cursor()
  let month = parse_unsigned_int(s, 1, 2).or_error(
    TypeError(({ start: pos, end: s.cursor() }, InvalidFormat)),
  )
  if month < 1 || month > 12 {
    raise TypeError(({ start: pos, end: s.cursor() }, MonthOutOfRange))
  }
  month - 1
}

///|
/// Parse the day in the 0-30 range.
fn parse_day(s : Scanner) -> UInt raise TypeError {
  let pos = s.cursor()
  let day = parse_unsigned_int(s, 1, 2).or_error(
    TypeError(({ start: pos, end: s.cursor() }, InvalidFormat)),
  )
  if day < 1 || day > 31 {
    raise TypeError(({ start: pos, end: s.cursor() }, DayOutOfRange))
  }
  day - 1
}

///|
/// Parse the hour in the 0-23 range.
fn parse_hour(s : Scanner) -> UInt raise TypeError {
  let pos = s.cursor()
  let hour = parse_unsigned_int(s, 1, 2).or_error(
    TypeError(({ start: pos, end: s.cursor() }, InvalidFormat)),
  )
  if hour > 23 {
    raise TypeError(({ start: pos, end: s.cursor() }, InvalidNumber))
  }
  hour
}

///|
/// Parse minutes or seconds in the 0-59 range.
fn parse_minutes_or_seconds(s : Scanner) -> UInt raise TypeError {
  let pos = s.cursor()
  let num = parse_unsigned_int(s, 1, 2).or_error(
    TypeError(({ start: pos, end: s.cursor() }, InvalidFormat)),
  )
  if num > 59 {
    raise TypeError(({ start: pos, end: s.cursor() }, InvalidNumber))
  }
  num
}

///|
/// Parse an offset.
fn parse_offset(s : Scanner) -> TimeOffset raise TypeError {
  ignore(s.eat_whitespace())
  let pos = s.cursor()
  let c = s.eat()
  match c {
    Some('Z') => Utc
    Some('+' | '-') => {
      let positive = c is Some('+')
      let hours = parse_hour(s)
      ignore(s.eat_whitespace())
      if s.done() {
        return Offset(positive, hours, 0)
      }
      parse_colon(s)
      let minutes = parse_minutes_or_seconds(s)
      Offset(positive, hours, minutes)
    }
    _ => raise TypeError(({ start: pos, end: s.cursor() }, InvalidFormat))
  }
}

///|
/// Parse a hyphen.
pub fn parse_hyphen(s : Scanner) -> Unit raise TypeError {
  let pos = s.cursor()
  ignore(s.eat_whitespace())
  if not(s.eat_if('-')) {
    raise TypeError(({ start: pos, end: s.cursor() }, InvalidFormat))
  }
  ignore(s.eat_while('-'))
  ()
}

///|
/// Parse a colon.
pub fn parse_colon(s : Scanner) -> Unit raise TypeError {
  let pos = s.cursor()
  ignore(s.eat_whitespace())
  if not(s.eat_if(':')) {
    raise TypeError(({ start: pos, end: s.cursor() }, InvalidFormat))
  }
  ()
}

///|
fn days_in_month(month : UInt, year : Int) -> UInt {
  if month == 1 {
    if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) {
      29
    } else {
      28
    }
  } else if month < 7 {
    31 - month % 2
  } else {
    30 + month % 2
  }
}

///|
/// Used to resolve month abbreviations to their respective values.
pub fn get_month_for_abbr(month : String) -> (String, Int)? {
  match month.to_lower() {
    "jan" => Some(("January", 0))
    "feb" => Some(("February", 1))
    "mar" => Some(("March", 2))
    "apr" => Some(("April", 3))
    "may" => Some(("May", 4))
    "jun" => Some(("June", 5))
    "jul" => Some(("July", 6))
    "aug" => Some(("August", 7))
    "sep" => Some(("September", 8))
    "oct" => Some(("October", 9))
    "nov" => Some(("November", 10))
    "dec" => Some(("December", 11))
    _ => None
  }
}

///|
/// Used to resolve month names to their respective values.
fn get_month_for_name(month : String) -> UInt? {
  match month.to_lower() {
    "january" => Some(0)
    "february" => Some(1)
    "march" => Some(2)
    "april" => Some(3)
    "may" => Some(4)
    "june" => Some(5)
    "july" => Some(6)
    "august" => Some(7)
    "september" => Some(8)
    "october" => Some(9)
    "november" => Some(10)
    "december" => Some(11)
    _ => None
  }
}

///|
test "panic_parse_empty_date" {
  let _ = Date::parse([])
  let _ = Date::parse([s(n(""), { start: 0, end: 0 })])

}

///|
test "test_parse_date" {
  let date = Date::parse([s(n("2017-10 -25?"), { start: 0, end: 12 })])
  assert_eq(date.to_chunks(), [d(n("2017-10-25?"))])
  assert_eq(date, {
    value: DateValue::At({
      year: 2017,
      month: Some(9),
      day: Some(24),
      time: None,
    }),
    uncertain: true,
    approximate: false,
  })
  let date = Date::parse([s(n("19XX~"), { start: 0, end: 5 })])
  assert_eq(date.to_chunks(), [d(n("1900/1999~"))])
  assert_eq(date, {
    value: DateValue::Between(
      { year: 1900, month: None, day: None, time: None },
      { year: 1999, month: None, day: None, time: None },
    ),
    uncertain: false,
    approximate: true,
  })
  let date = Date::parse([s(n("1948-03-02/1950"), { start: 1, end: 16 })])
  assert_eq(date.to_chunks(), [d(n("1948-03-02/1950"))])
  assert_eq(date, {
    value: DateValue::Between(
      { year: 1948, month: Some(2), day: Some(1), time: None },
      { year: 1950, month: None, day: None, time: None },
    ),
    uncertain: false,
    approximate: false,
  })
  let date = Date::parse([s(n("2020-04-04T18:30:31/"), { start: 0, end: 20 })])
  assert_eq(date.to_chunks(), [d(n("2020-04-04/.."))])
  assert_eq(date, {
    value: DateValue::After({
      year: 2020,
      month: Some(3),
      day: Some(3),
      time: Some(Time::from_hms(18, 30, 31).unwrap()),
    }),
    uncertain: false,
    approximate: false,
  })
  let date = Date::parse([s(n("/-0031-07%"), { start: 0, end: 10 })])
  assert_eq(date.to_chunks(), [d(n("../-0031-07%"))])
  assert_eq(date, {
    value: DateValue::Before({
      year: -31,
      month: Some(6),
      day: None,
      time: None,
    }),
    uncertain: true,
    approximate: true,
  })
}

///|
test "test_parse_date_from_three_fields" {
  let year = [s(n("2020"), { start: 0, end: 4 })]
  let month = [s(n("January\u{A0}12th"), { start: 20, end: 32 })]
  let date = Date::parse_three_fields(year, Some(month), None)
  assert_eq(
    date.value,
    DateValue::At({ year: 2020, month: Some(0), day: Some(11), time: None }),
  )
  let year = [s(n("-0004"), { start: 0, end: 5 })]
  let month = [s(n("aug"), { start: 41, end: 44 })]
  let day = [s(n("28"), { start: 48, end: 50 })]
  let date = Date::parse_three_fields(year, Some(month), Some(day))
  assert_eq(
    date.value,
    DateValue::At({ year: -4, month: Some(7), day: Some(27), time: None }),
  )
}

///|
test "test_parse_bce_year" {
  let year = [s(n("3 AD"), { start: 0, end: 4 })]
  let date = Date::parse_three_fields(year, None, None)
  assert_eq(
    date.value,
    DateValue::At({ year: 3, month: None, day: None, time: None }),
  )
  let year = [s(n("3 BCE"), { start: 0, end: 5 })]
  let date = Date::parse_three_fields(year, None, None)
  assert_eq(
    date.value,
    DateValue::At({ year: -2, month: None, day: None, time: None }),
  )
  let year = [s(n("90"), { start: 0, end: 2 })]
  let date = Date::parse_three_fields(year, None, None)
  assert_eq(
    date.value,
    DateValue::At({ year: 90, month: None, day: None, time: None }),
  )
}

///|
test "test_parse_datetime" {
  let date1 = Datetime::parse("2017-10 -25")
  assert_eq(date1.to_string(), "2017-10-25")
  assert_eq(date1, { year: 2017, month: Some(9), day: Some(24), time: None })
  let date2 = Datetime::parse("  2019 -- 03 ")
  assert_eq(date2, { year: 2019, month: Some(2), day: None, time: None })
  assert_eq(date2.to_string(), "2019-03")
  let date3 = Datetime::parse("  -0006")
  assert_eq(date3.to_string(), "-0006")
  assert_eq(date3, { year: -6, month: None, day: None, time: None })
  let date4 = Datetime::parse("2020-09-06T13:39:00")
  assert_eq(date4, {
    year: 2020,
    month: Some(8),
    day: Some(5),
    time: Some(Time::from_hms(13, 39, 00).unwrap()),
  })
  let date5 = Datetime::parse("2020-09-06T13:39:00Z")
  assert_eq(date5, {
    year: 2020,
    month: Some(8),
    day: Some(5),
    time: Some(Time::from_hms_offset(13, 39, 00, TimeOffset::Utc).unwrap()),
  })
  let date6 = Datetime::parse("2020-09-06T13:39:00+01")
  assert_eq(date6, {
    year: 2020,
    month: Some(8),
    day: Some(5),
    time: Some(
      Time::from_hms_offset(13, 39, 00, TimeOffset::offset_hour(1)).unwrap(),
    ),
  })
  let date6 = Datetime::parse("2020-09-06T13:39:00-02:10")
  assert_eq(date6, {
    year: 2020,
    month: Some(8),
    day: Some(5),
    time: Some(
      Time::from_hms_offset(13, 39, 00, TimeOffset::offset(false, 2, 10)).unwrap(),
    ),
  })
  assert_true(date3 < date4)
  assert_true(date2 > date1)
}
