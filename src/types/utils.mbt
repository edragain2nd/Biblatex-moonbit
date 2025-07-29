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
fn String::split_at(self : String, index : Int) -> (String, String) {
  (self.substring(end=index), self.substring(start=index))
}

///|
fn Int::saturating_add(self : Int, len : Int) -> Int {
  if @int.max_value - self < len {
    @int.max_value
  } else {
    self + len
  }
}

///|
fn String::starts_with_whitespace(self : String) -> Bool {
  if self.get_char(0) is Some(c) {
    c.is_whitespace()
  } else {
    false
  }
}

///|
fn String::ends_with_whitespace(self : String) -> Bool {
  self.rev().starts_with_whitespace()
}

///|
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
