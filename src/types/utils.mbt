///|
/// Characters that can be escaped.
///
/// In read mode (`read_char = true`), colons are also converted to an unescaped
/// string to keep compatibility with Zotero. Zotero escapes colons when
/// exporting verbatim fields. This crate doesn't escape colons when exporting.
///
/// List of reserved characters here
/// http://latexref.xyz/Reserved-characters.html
pub fn is_escapable(c : Char, verb : Bool, read_char : Bool) -> Bool {
  match c {
    '{' | '}' | '\\' => true
    '~' | '^' | '#' | '&' | '%' | '$' | '_' if not(verb) => true
    ':' if read_char => true
    _ => false
  }
}

///|
/// Removes leading whitespace from a string.
///
/// # Arguments
/// * `self` - The input string to trim.
///
/// # Returns
/// A new `String` with leading whitespace removed.
///
fn String::trim_space_start(self : String) -> String {
  let s = StringBuilder::new()
  s.write_iter(self.iter().drop_while(c => c.is_whitespace()))
  s.to_string()
}

///|
/// Removes trailing whitespace from a string.
///
/// # Arguments
/// * `self` - The input string to trim.
///
/// # Returns
/// A new `String` with trailing whitespace removed.
///
fn String::trim_space_end(self : String) -> String {
  self.rev().trim_space_start().rev()
}

///|
/// Splits a string into two parts at the given index.
///
/// # Arguments
/// * `self` - The input string to split.
/// * `index` - The position at which to split (0-based).
///
/// # Returns
/// A tuple `(left, right)` where `left` is the substring before `index`,
/// and `right` is the substring from `index` onward.
///
fn String::split_at(self : String, index : Int) -> (String, String) {
  (self.substring(end=index), self.substring(start=index))
}

///|
/// Performs saturating integer addition (clamps at `Int::MAX`).
///
/// # Arguments
/// * `self` - The base integer.
/// * `len` - The value to add.
///
/// # Returns
/// `self + len`, or `Int::MAX` if the result would overflow.
///
fn Int::saturating_add(self : Int, len : Int) -> Int {
  if @int.max_value - self < len {
    @int.max_value
  } else {
    self + len
  }
}

///|
/// Checks if a string starts with any whitespace character.
///
/// # Arguments
/// * `self` - The input string to check.
///
/// # Returns
/// `true` if the first character is whitespace, `false` otherwise.
///
fn String::starts_with_whitespace(self : String) -> Bool {
  if self.get_char(0) is Some(c) {
    c.is_whitespace()
  } else {
    false
  }
}

///|
/// Checks if a string ends with any whitespace character.
///
/// # Arguments
/// * `self` - The input string to check.
///
/// # Returns
/// `true` if the last character is whitespace, `false` otherwise.
///
fn String::ends_with_whitespace(self : String) -> Bool {
  self.rev().starts_with_whitespace()
}

///|
/// Formats a year as a zero-padded string with optional negative sign.
///
/// # Arguments
/// * `year` - The year to format (can be negative for BCE dates).
///
/// # Returns
/// A formatted string with leading zeros and optional `-` prefix.
///
fn format_year(year : Int) -> String {
  let mut result = ""
  let abs_year = year.abs()
  if year < 0 {
    result += "-"
    let digits = if abs_year < 10 {
      3
    } else if abs_year < 100 {
      2
    } else if abs_year < 1000 {
      1
    } else {
      0
    }
    for _ in 0..=(digits - 1) {
      result += "0"
    }
  } else {
    let digits = if abs_year < 10 {
      3
    } else if abs_year < 100 {
      2
    } else if abs_year < 1000 {
      1
    } else {
      0
    }
    for _ in 0..=(digits - 1) {
      result += "0"
    }
  }
  result += abs_year.to_string()
  result
}

///|
/// Formats a month or day as a 2-digit zero-padded string.
///
/// # Arguments
/// * `month` - The month or day (1-12 for months, 1-31 for days).
///
/// # Returns
/// A string like `"01"` for values < 10, or `"12"` otherwise.
///
fn format_month_or_day(month : UInt) -> String {
  if month < 9 {
    "0\{month}"
  } else {
    month.to_string()
  }
}

///|
test "test_format_year" {
  assert_eq(format_year(1), "0001")
  assert_eq(format_year(11), "0011")
  assert_eq(format_year(111), "0111")
  assert_eq(format_year(1111), "1111")
  assert_eq(format_year(-1), "-0001")
  assert_eq(format_year(-11), "-0011")
  assert_eq(format_year(-111), "-0111")
  assert_eq(format_year(-1111), "-1111")
}

///|
test "test_format_month_or_day" {
  assert_eq(format_month_or_day(1), "01")
  assert_eq(format_month_or_day(12), "12")
}
