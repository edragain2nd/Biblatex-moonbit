///|
pub fn is_escapable(c : Char, verb : Bool, read_char : Bool) -> Bool {
  match c {
    '{' | '}' | '\\' =>true
    '~' | '^' | '#' | '&' | '%' | '$' | '_' if not(verb) =>
      true
    ':' if read_char => true
    _ => false
  }
}