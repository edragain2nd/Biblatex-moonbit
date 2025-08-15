///|
/// An author, editor, or some other person affiliated with a cited work.
///
/// When parsed through [`Person::parse`], the whitespace is trimmed from the
/// fields.
pub(all) struct Person {
  /// The surname / family name / last name.
  name : String
  /// The given name / first name / forename.
  given_name : String
  /// The prefix is placed between given name and name. It could, for example,
  /// be a nobiliary particle.
  prefix : String
  /// The suffix is placed after the name (e.g., "Jr.").
  suffix : String
} derive(Eq)

///|
/// Constructs a new person from a chunk array:
pub fn Person::parse(chunks : Chunks) -> Person {
  if chunks.iter().any(val => val.v.get().contains("=")) {
    return Person::parse_extended_name_format(chunks)
  }
  Person::parse_bibtex(chunks)
}

///|
/// Constructs new person from chunk slices.
fn Person::parse_extended_name_format(chunks : Chunks) -> Person {
  let person : Map[String, String] = Map::new()
  for chunk in split_token_lists(chunks, ",") {
    let (key, value) = split_at_normal_char(chunk, '=', true)
    let key = ChunkExt::format_verbatim(key)
    let value = ChunkExt::format_verbatim(value)
    person.set(key, value)
  }
  let name = person.get_or_default("family", "")
  person.remove("family")
  let given_name = person.get_or_default("given", "")
  person.remove("given")
  let prefix = person.get_or_default("prefix", "")
  person.remove("prefix")
  let suffix = person.get_or_default("suffix", "")
  person.remove("suffix")
  { name, given_name, prefix, suffix }
}

///|
/// /// Constructs new person from bibtex.
fn Person::parse_bibtex(chunks : Chunks) -> Person {
  let num_commas = count_num_char(chunks, ',')
  match num_commas {
    0 => Person::parse_unified(chunks) // `<First> <Prefix> <Last>`
    1 => {
      let (v1, v2) = split_at_normal_char(chunks, ',', true)
      Person::parse_single_comma(v1, v2)
    } // `<Prefix> <Last>, <First>`
    _ => {
      let (v1, v2) = split_at_normal_char(chunks, ',', true)
      let (v2, v3) = split_at_normal_char(v2, ',', true)
      Person::parse_two_commas(v1, v2, v3)
    } // `<Prefix> <Last>, <Suffix>, <First>`.
  }
}

///|
/// Constructs new person from a chunk slice if in the
/// form `<First> <Prefix> <Last>`.
fn Person::parse_unified(chunks : Chunks) -> Person {
  // Find end of first sequence of capitalized words (denominated by first
  // lowercase word), start of last capitalized sequence.
  // If there is no subsequent capitalized word, take last one.
  // Treat verbatim as capital letters.
  let mut word_start = true
  let mut capital = false
  let mut seen_lowercase = false
  let mut seen_uppercase = false
  let mut seen_uppercase2 = false
  let mut cap_new_start = 0
  let mut cap_word_end = 0
  let mut last_word_start = 0
  let mut last_lowercase_start = 0
  for index, pair in chunk_chars(chunks).iter2() {
    let c = pair.0
    let v = pair.1
    if c.is_whitespace() && not(v) {
      word_start = true
      continue
    }
    if word_start {
      last_word_start = index
      // FIXME: moonbit only surpport is_ascii_uppercase
      capital = if v || c.is_ascii_uppercase() {
        seen_uppercase = true
        if seen_lowercase && last_lowercase_start >= cap_new_start {
          seen_uppercase2 = true
          cap_new_start = index
        }
        true
      } else {
        last_lowercase_start = index
        seen_lowercase = true
        false
      }
    }
    if capital && not(seen_lowercase) {
      cap_word_end = index
    }
    word_start = false
  }
  let mut name = ""
  let mut given_name = ""
  let mut prefix = ""
  for index, pair in chunk_chars(chunks).iter2() {
    let c = pair.0
    // FIXME: moonbit only surpport is_ascii_lowercase
    if (
        index <= cap_word_end &&
        seen_lowercase &&
        seen_uppercase &&
        not(index == 0 && c.is_ascii_lowercase())
      ) ||
      (index < last_word_start && not(seen_lowercase)) {
      given_name += c.to_string()
    } else if (index < cap_new_start && cap_new_start > cap_word_end) ||
      (
        index < last_word_start &&
        (
          not(seen_uppercase2) ||
          (last_word_start == last_lowercase_start && index < cap_new_start)
        )
      ) {
      prefix += c.to_string()
    } else {
      name += c.to_string()
    }
  }
  {
    name: name.trim_space_start(),
    given_name: given_name.trim_space_end(),
    prefix: prefix.trim_space_start().trim_space_end(),
    suffix: "",
  }
}

///|

///| Constructs new person from chunk slices if in the
/// form `<Prefix> <Last>, <First>`.
/// - `s1` corresponds to the part before the comma,
/// - `s2` to the part behind it.
///
/// The arguments should not contain the comma.
fn Person::parse_single_comma(s1 : Chunks, s2 : Chunks) -> Person {
  if s2.is_empty() ||
    (s2.length() == 1 && ChunkExt::format_verbatim(s2).is_empty()) {
    let formatted = ChunkExt::format_verbatim(s1)
    let last_space = formatted.rev_find(" ").unwrap_or(0)
    let (prefix, last) = formatted.split_at(last_space)
    return {
      name: last.trim_space_start(),
      given_name: "",
      prefix: prefix.trim_space_end(),
      suffix: "",
    }
  }
  let given_name = ChunkExt::format_verbatim(s2)
  let mut word_start = true
  let mut last_lower_case_end = -1
  let mut is_lowercase = false
  let mut last_word_start = 0
  let mut has_seen_uppercase_words = false
  for index, pair in chunk_chars(s1).iter2() {
    let c = pair.0
    let v = pair.1
    if c.is_whitespace() && not(v) {
      word_start = true
      continue
    }
    if word_start {
      last_word_start = index
      //FIXME:  moonbit only surpport is_ascii_lowercase
      if c.is_ascii_lowercase() || v {
        is_lowercase = true
      } else {
        is_lowercase = false
        has_seen_uppercase_words = true
      }
    }
    if is_lowercase {
      last_lower_case_end = index
    }
    word_start = false
  }
  let mut name = ""
  let mut prefix = ""
  for index, pair in chunk_chars(s1).iter2() {
    let c = pair.0
    if (index <= last_lower_case_end && has_seen_uppercase_words) ||
      (not(has_seen_uppercase_words) && index < last_word_start) {
      prefix += c.to_string()
    } else if has_seen_uppercase_words || index >= last_word_start {
      name += c.to_string()
    }
  }
  {
    name: name.trim_space_start(),
    given_name: given_name.trim_space_start(),
    prefix: prefix.trim_space_end(),
    suffix: "",
  }
}

///| Constructs new person from chunk slices if in the
/// form `<Prefix> <Last>, <Suffix>, <First>`.
///
/// `s1`, `s2`, `s3` correspond to the first through third part of the
/// value respectively.
///
/// The arguments should not contain the comma.
fn Person::parse_two_commas(s1 : Chunks, s2 : Chunks, s3 : Chunks) -> Person {
  let person = Person::parse_single_comma(s1, s3)
  { ..person, suffix: ChunkExt::format_verbatim(s2) }
}

///|
/// This is a ​​proxy type​​ that aliases Array[Person]
/// (array of Person objects) to the concrete type ArrayPerson. 
/// Its primary purpose is to enable trait implementations for the Array generic type when specialized to Person
pub(all) struct ArrayPerson(Array[Person]) derive(Show, Eq)

///|
pub impl Type for ArrayPerson with from_chunks(chunks) {
  split_token_lists_with_kw(chunks, "and")
  .iter()
  .map(subchunks => Person::parse(subchunks))
  .collect()
}

///|
pub impl Type for ArrayPerson with to_chunks(self) {
  ArrayChunks::to_chunks(
    self.0.map(p => {
      let prefix = if p.prefix.get_char(0) is Some(c) {
        // FIXME: moonbit only surpport is_ascii_uppercase
        if c.is_ascii_uppercase() {
          (Some(Spanned::detached(Chunk::Verbatim(p.prefix))), " ")
        } else {
          (None, "\{p.prefix} ")
        }
      } else {
        (None, "")
      }
      let name_str = if not(p.suffix.is_empty()) {
        "\{prefix.1}\{p.name}, \{p.suffix}, \{p.given_name}"
      } else {
        "\{prefix.1}\{p.name}, \{p.given_name}"
      }
      let res = []
      res.push(Spanned::detached(Chunk::Normal(name_str)))
      if prefix.0 is Some(pre_chunk) {
        res.insert(0, pre_chunk)
      }
      res
    }),
  )
}

///|
pub impl Show for Person with to_string(self) {
  let mut res = ""
  if not(self.given_name.is_empty()) {
    res += "\{self.given_name} "
  }
  if not(self.prefix.is_empty()) {
    res += "\{self.prefix} "
  }
  res += self.name
  if not(self.suffix.is_empty()) {
    res += " \{self.suffix}"
  }
  res
}

///|
pub impl Show for Person with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
test "test_list_of_names" {
  let names = "Johannes Gutenberg and Aldus Manutius and Claude Garamond"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people : ArrayPerson = Type::from_chunks(people)
  let people : Array[Person] = people.0
  assert_eq(people.length(), 3)
  assert_eq(people[0].name, "Gutenberg")
  assert_eq(people[0].prefix, "")
  assert_eq(people[0].given_name, "Johannes")
  assert_eq(people[1].name, "Manutius")
  assert_eq(people[1].prefix, "")
  assert_eq(people[1].given_name, "Aldus")
  assert_eq(people[2].name, "Garamond")
  assert_eq(people[2].prefix, "")
  assert_eq(people[2].given_name, "Claude")
}

///|
test "test_list_of_names_multilines" {
  let names = "Johannes Gutenberg and\nAldus Manutius and\nClaude Garamond"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people1 : ArrayPerson = Type::from_chunks(people)
  let people1 = people1.0
  assert_eq(people1.length(), 3)
  let names = "Johannes Gutenberg\nand\nAldus Manutius\nand\nClaude Garamond"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people2 : ArrayPerson = Type::from_chunks(people)
  let people2 = people2.0
  assert_eq(people2.length(), 3)
  let names = "Johannes Gutenberg\nand\nAldus Manutius and\nClaude Garamond"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people3 : ArrayPerson = Type::from_chunks(people)
  let people3 = people3.0
  assert_eq(people3.length(), 3)
  assert_eq(people1, people2)
  assert_eq(people2, people3)
  assert_eq(people1[0].name, "Gutenberg")
  assert_eq(people1[0].prefix, "")
  assert_eq(people1[0].given_name, "Johannes")
  assert_eq(people1[1].name, "Manutius")
  assert_eq(people1[1].prefix, "")
  assert_eq(people1[1].given_name, "Aldus")
  assert_eq(people1[2].name, "Garamond")
  assert_eq(people1[2].prefix, "")
  assert_eq(people1[2].given_name, "Claude")
}

///|
test "test_leading_and" {
  let names = "and Gutenberg, Johannes and\nAldus Manutius and\nClaude Garamond"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people : ArrayPerson = Type::from_chunks(people)
  let people = people.0
  assert_eq(people.length(), 3)
  assert_eq(people[0].name, "Gutenberg")
  assert_eq(people[0].prefix, "and")
  assert_eq(people[0].given_name, "Johannes")
}

///|
test "test_trailing_and" {
  let names = "Johannes Gutenberg and\nAldus Manutius and\nClaude Garamond and"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people : ArrayPerson = Type::from_chunks(people)
  let people = people.0
  assert_eq(people.length(), 3)
  assert_eq(people[2].name, "and")
  assert_eq(people[2].prefix, "")
  assert_eq(people[2].given_name, "Claude Garamond")
}

///|
test "test_consecutive_and" {
  let names = "Johannes Gutenberg and and\nAldus Manutius and\nClaude Garamond"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people : ArrayPerson = Type::from_chunks(people)
  let people = people.0
  assert_eq(people.length(), 4)
  assert_eq(people[1].name, "")
  assert_eq(people[1].prefix, "")
  assert_eq(people[1].given_name, "")
  let names = "Johannes Gutenberg and and and\nAldus Manutius and\nClaude Garamond"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people : ArrayPerson = Type::from_chunks(people)
  let people = people.0
  assert_eq(people.length(), 5)
  assert_eq(people[1].name, "")
  assert_eq(people[1].prefix, "")
  assert_eq(people[1].given_name, "")
  assert_eq(people[2].name, "")
  assert_eq(people[2].prefix, "")
  assert_eq(people[2].given_name, "")
}

///|
test "test_name_with_and_inside" {
  let names = "Johannes anderson Gutenberg and Claudeand Garamond and Aanderson Manutius"
  let people = [Spanned::detached(Chunk::Normal(names))]
  let people : ArrayPerson = Type::from_chunks(people)
  let people = people.0
  assert_eq(people.length(), 3)
  assert_eq(people[0].name, "Gutenberg")
  assert_eq(people[0].prefix, "anderson")
  assert_eq(people[0].given_name, "Johannes")
  assert_eq(people[1].name, "Garamond")
  assert_eq(people[1].prefix, "")
  assert_eq(people[1].given_name, "Claudeand")
  assert_eq(people[2].name, "Manutius")
  assert_eq(people[2].prefix, "")
  assert_eq(people[2].given_name, "Aanderson")
}

///|
test "test_verbatim" {
  let people = [
    Spanned::detached(Chunk::Verbatim("Johannes")),
    Spanned::detached(Chunk::Normal(" ")),
    Spanned::detached(Chunk::Verbatim("Gutenberg")),
  ]
  let people = ArrayPerson::from_chunks(people).0
  assert_eq(people.length(), 1)
  assert_eq(people[0].name, "Gutenberg")
  assert_eq(people[0].given_name, "Johannes")
  let people = [
    Spanned::detached(Chunk::Verbatim("Johannes")),
    Spanned::detached(Chunk::Normal(" ")),
    Spanned::detached(Chunk::Verbatim("Gutenberg")),
    Spanned::detached(Chunk::Normal(" and ")),
    Spanned::detached(Chunk::Verbatim("Manutius")),
    Spanned::detached(Chunk::Normal(" ")),
    Spanned::detached(Chunk::Verbatim("Aldus")),
  ]
  let people = ArrayPerson::from_chunks(people).0
  assert_eq(people.length(), 2)
  assert_eq(people[0].name, "Gutenberg")
  assert_eq(people[0].given_name, "Johannes")
  assert_eq(people[1].name, "Aldus")
  assert_eq(people[1].given_name, "Manutius")
  let people = [
    Spanned::detached(Chunk::Verbatim("Johannes".to_string())),
    Spanned::detached(Chunk::Normal(" ".to_string())),
    Spanned::detached(Chunk::Verbatim("Gutenberg".to_string())),
    Spanned::detached(Chunk::Normal(" and Manutius Aldus".to_string())),
  ]
  let people = ArrayPerson::from_chunks(people).0
  assert_eq(people.length(), 2)
  assert_eq(people[0].name, "Gutenberg")
  assert_eq(people[0].given_name, "Johannes")
  assert_eq(people[1].name, "Aldus")
  assert_eq(people[1].given_name, "Manutius")
}

///|
test "test_person_comma" {
  let p = Person::parse([Spanned::zero(n("jean de la fontaine,"))])
  assert_eq(p.name, "fontaine")
  assert_eq(p.prefix, "jean de la")
  assert_eq(p.given_name, "")
  assert_eq(ArrayPerson([p]).to_chunks(), [d(n("jean de la fontaine, "))])
  let p = Person::parse([Spanned::zero(n("de la fontaine, Jean"))])
  assert_eq(p.name, "fontaine")
  assert_eq(p.prefix, "de la")
  assert_eq(p.given_name, "Jean")
  assert_eq(ArrayPerson([p]).to_chunks(), [d(n("de la fontaine, Jean"))])
  let p = Person::parse([Spanned::zero(n("De La Fontaine, Jean"))])
  assert_eq(p.name, "De La Fontaine")
  assert_eq(p.prefix, "")
  assert_eq(p.given_name, "Jean")
  assert_eq(ArrayPerson([p]).to_chunks(), [d(n("De La Fontaine, Jean"))])
  let p = Person::parse([Spanned::zero(n("De la Fontaine, Jean"))])
  assert_eq(p.name, "Fontaine")
  assert_eq(p.prefix, "De la")
  assert_eq(p.given_name, "Jean")
  let p = Person::parse([Spanned::zero(n("de La Fontaine, Jean"))])
  assert_eq(p.name, "La Fontaine")
  assert_eq(p.prefix, "de")
  assert_eq(p.given_name, "Jean")
}

///|
test "test_person_no_comma" {
  let p = Person::parse([Spanned::zero(n(""))])
  assert_eq(p.name, "")
  assert_eq(p.prefix, "")
  assert_eq(p.given_name, "")
  let p = Person::parse([Spanned::zero(n("jean de la fontaine"))])
  assert_eq(p.name, "fontaine")
  assert_eq(p.prefix, "jean de la")
  assert_eq(p.given_name, "")
  let p = Person::parse([Spanned::zero(n("Jean de la fontaine"))])
  assert_eq(p.name, "fontaine")
  assert_eq(p.prefix, "de la")
  assert_eq(p.given_name, "Jean")
  let p = Person::parse([
    Spanned::zero(n("Jean ")),
    Spanned::zero(v("de")),
    Spanned::zero(n(" la fontaine")),
  ])
  assert_eq(p.name, "fontaine")
  assert_eq(p.prefix, "la")
  assert_eq(p.given_name, "Jean de")
  let p = Person::parse([
    Spanned::zero(n("Jean ")),
    Spanned::zero(v("de")),
    Spanned::zero(n(" ")),
    Spanned::zero(v("la")),
    Spanned::zero(n(" fontaine")),
  ])
  assert_eq(p.name, "fontaine")
  assert_eq(p.prefix, "")
  assert_eq(p.given_name, "Jean de la")
  let p = Person::parse([
    Spanned::zero(n("jean ")),
    Spanned::zero(v("de")),
    Spanned::zero(n(" ")),
    Spanned::zero(v("la")),
    Spanned::zero(n(" fontaine")),
  ])
  assert_eq(p.name, "de la fontaine")
  assert_eq(p.prefix, "jean")
  assert_eq(p.given_name, "")
  let p = Person::parse([Spanned::zero(n("Jean De La Fontaine"))])
  assert_eq(p.name, "Fontaine")
  assert_eq(p.prefix, "")
  assert_eq(p.given_name, "Jean De La")
  let p = Person::parse([Spanned::zero(n("jean De la Fontaine"))])
  assert_eq(p.name, "Fontaine")
  assert_eq(p.prefix, "jean De la")
  assert_eq(p.given_name, "")
  let p = Person::parse([Spanned::zero(n("Jean de La Fontaine"))])
  assert_eq(p.name, "La Fontaine")
  assert_eq(p.prefix, "de")
  assert_eq(p.given_name, "Jean")
}

///|
test "test_person_two_comma" {
  let p = Person::parse([Spanned::zero(n("Mudd, Sr., Harcourt Fenton"))])
  assert_eq(p.name, "Mudd")
  assert_eq(p.prefix, "")
  assert_eq(p.suffix, "Sr.")
  assert_eq(p.given_name, "Harcourt Fenton")
}

///|
test "test_person_extended_name_format" {
  // AUTHOR = {given=Hans, family=Harman}
  let p = Person::parse([Spanned::zero(n("given=Hans, family=Harman"))])
  assert_eq(p.name, "Harman")
  assert_eq(p.prefix, "")
  assert_eq(p.suffix, "")
  assert_eq(p.given_name, "Hans")

  // AUTHOR = {given={Jean Pierre}}
  let p = Person::parse([
    Spanned::zero(n("given=")),
    Spanned::zero(v("Jean Pierre")),
  ])
  assert_eq(p.name, "")
  assert_eq(p.prefix, "")
  assert_eq(p.suffix, "")
  assert_eq(p.given_name, "Jean Pierre")

  // AUTHOR = {given={Jean Pierre Simon}, given-i=JPS}
  let p = Person::parse([
    Spanned::zero(n("given=")),
    Spanned::zero(v("Jean Pierre Simon")),
    Spanned::zero(n(", given-i=JPS")),
  ])
  assert_eq(p.name, "")
  assert_eq(p.prefix, "")
  assert_eq(p.suffix, "")
  assert_eq(p.given_name, "Jean Pierre Simon")

  // AUTHOR = {given=Jean, prefix=de la, prefix-i=d, family=Rousse}
  let p = Person::parse([
    Spanned::zero(n("given=Jean, prefix=de la, prefix-i=d, family=Rousse")),
  ])
  assert_eq(p.name, "Rousse")
  assert_eq(p.prefix, "de la")
  assert_eq(p.suffix, "")
  assert_eq(p.given_name, "Jean")

  // AUTHOR = {"family={Robert and Sons, Inc.}"}
  let p = Person::parse([
    Spanned::zero(n("family=")),
    Spanned::zero(v("Robert and Sons, Inc.")),
  ])
  assert_eq(p.name, "Robert and Sons, Inc.")
  assert_eq(p.prefix, "")
  assert_eq(p.suffix, "")
  assert_eq(p.given_name, "")

  // AUTHOR = {given = Simon, prefix = de, family = Beumont}
  let p = Person::parse([
    Spanned::zero(n("given = Simon, prefix = de, family = Beumont")),
  ])
  assert_eq(p.name, "Beumont")
  assert_eq(p.prefix, "de")
  assert_eq(p.suffix, "")
  assert_eq(p.given_name, "Simon")

  // AUTHOR = {given=Hans, family=Harman and given=Simon, prefix=de, family=Beumont}
  let people = [
    Spanned::zero(
      n("given=Hans, family=Harman and given=Simon, prefix=de, family=Beumont"),
    ),
  ]
  let people = ArrayPerson::from_chunks(people).0
  assert_eq(people.length(), 2)
  assert_eq(people[0].name, "Harman")
  assert_eq(people[0].prefix, "")
  assert_eq(people[0].suffix, "")
  assert_eq(people[0].given_name, "Hans")
  assert_eq(people[1].name, "Beumont")
  assert_eq(people[1].prefix, "de")
  assert_eq(people[1].suffix, "")
  assert_eq(people[1].given_name, "Simon")

  // AUTHOR = {Hans Harman and given=Simon, prefix=de, family=Beumont}
  let people = [
    Spanned::zero(n("Hans Harman and given=Simon, prefix=de, family=Beumont")),
  ]
  let people = ArrayPerson::from_chunks(people).0
  assert_eq(people.length(), 2)
  assert_eq(people[0].name, "Harman")
  assert_eq(people[0].prefix, "")
  assert_eq(people[0].suffix, "")
  assert_eq(people[0].given_name, "Hans")
  assert_eq(people[1].name, "Beumont")
  assert_eq(people[1].prefix, "de")
  assert_eq(people[1].suffix, "")
  assert_eq(people[1].given_name, "Simon")

  // AUTHOR = {nosortothers=true and Hans Harman and given=Simon, family=Beumont, prefix=de, useprefix=true}
  let people = [
    Spanned::zero(
      n(
        "nosortothers=true and Hans Harman and given=Simon, family=Beumont, prefix=de, useprefix=true",
      ),
    ),
  ]
  let people = ArrayPerson::from_chunks(people).0
  assert_eq(people.length(), 3)
  assert_eq(people[0].name, "")
  assert_eq(people[0].prefix, "")
  assert_eq(people[0].suffix, "")
  assert_eq(people[0].given_name, "")
}

///|
test "test_coverage" {
  let person : Person = {
    name: "Lord",
    given_name: "Blackwood",
    prefix: "Alistair",
    suffix: "III",
  }
  assert_eq(person.to_string(), "Blackwood Alistair Lord III")
  let array : ArrayPerson = ArrayPerson([person])
  assert_eq(
    array.to_chunks().to_string(),
    "[{v: Verbatim(\"Alistair\"), span: {start: 2147483647, end: 2147483647}}, {v: Normal(\" Lord, III, Blackwood\"), span: {start: 2147483647, end: 2147483647}}]",
  )
}
