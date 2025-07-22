///|
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
