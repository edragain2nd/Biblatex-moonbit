///|
pub fn is_verbatim_field(key : String) -> Bool {
  match key {
    "file"
    | "doi"
    | "uri"
    | "eprint"
    | "verba"
    | "verbb"
    | "verbc"
    | "pdf"
    | "url"
    | "urlraw" => true
    _ => false
  }
}
