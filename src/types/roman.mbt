/// used for parse Roman number in mod.mbt
///|
pub enum Numeral {
  I // 1
  V // 5
  X // 10
  L // 50
  C // 100
  D // 500
  M // 1000
}

///|
pub fn Numeral::value(self : Numeral) -> Int16 {
  match self {
    I => 1
    V => 5
    X => 10
    L => 50
    C => 100
    D => 500
    M => 1000
  }
}

///|
pub fn Numeral::ascii_upper(self : Numeral) -> Char {
  match self {
    I => 'I'
    V => 'V'
    X => 'X'
    L => 'L'
    C => 'C'
    D => 'D'
    M => 'M'
  }
}

///|
pub fn Numeral::ascii_lower(self : Numeral) -> Char {
  match self {
    I => 'i'
    V => 'v'
    X => 'x'
    L => 'l'
    C => 'c'
    D => 'd'
    M => 'm'
  }
}

///|
pub fn Numeral::from_char(input : Char) -> Numeral? {
  match input {
    'I' | 'i' => Some(I)
    'V' | 'v' => Some(V)
    'X' | 'x' => Some(X)
    'L' | 'l' => Some(L)
    'C' | 'c' => Some(C)
    'D' | 'd' => Some(D)
    'M' | 'm' => Some(M)
    _ => None
  }
}

///|
pub struct Roman {
  numerals : Array[Numeral]
}

///|
pub fn Roman::parse(input : String) -> Roman? {
  let numerals = []
  for c in input.iter() {
    let numeral_wrap = Numeral::from_char(c)
    if numeral_wrap is Some(numeral) {
      numerals.push(numeral)
    } else {
      return None
    }
  }
  Some({ numerals, })
}

///|
pub fn Roman::value(self : Roman) -> Int16 {
  let mut total : Int16 = 0
  let mut max : Int16 = 0
  for n in self.numerals.map(n => n.value()).rev_iter() {
    total += if n >= max { n } else { -n }
    if max < n {
      max = n
    }
  }
  total
}

///|
pub fn Roman::from(number : Int16) -> Roman {
  let numerals = []
  let mut number = number
  let array : Array[(Numeral, Numeral)] = [
    (C, M),
    (C, D),
    (X, C),
    (X, L),
    (I, X),
    (I, V),
  ]
  for pair in array {
    let secondary = pair.0
    let primary = pair.1
    while number >= primary.value() {
      number -= primary.value()
      numerals.push(primary)
    }
    let difference = primary.value() - secondary.value()
    if number >= difference {
      number -= difference
      numerals.push(secondary)
      numerals.push(primary)
    }
  }
  while number > 0 {
    number -= 1
    numerals.push(I)
  }
  { numerals, }
}

///|
test "test_many_numbers" {
  for i in 1..=4321 {
    let i = i.to_int16()
    assert_eq(i, Roman::from(i).value())
  }
}

///|
test "test_big_numbers" {
  for i in 32700..=32767 {
    let i = i.to_int16()
    assert_eq(i, Roman::from(i).value())
  }
}
