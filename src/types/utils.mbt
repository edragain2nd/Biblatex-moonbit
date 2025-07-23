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
