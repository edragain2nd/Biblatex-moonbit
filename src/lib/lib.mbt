///|
typealias @types.(TypeError, Chunk, ArrayString, TypeErrorKind)

///|
typealias Array[Spanned[Chunk]] as Chunks

///|
typealias @span.Span

///|
traitalias @types.(Type, ChunkExt)

///|
fnalias @types.parse_chunks

///|
/// A fully parsed bibliography.
pub struct Bibliography {
  /// The bibliography entries.
  entries : Array[Entry]
  /// Maps from citation keys to indices in `items`.
  mut keys : Map[String, Int]
} derive(Default, Show, Eq)

///|
pub(all) struct Entry {
  /// The citation key.
  key : String
  /// Denotes the type of bibliography item (e.g., `Article`).
  entry_type : EntryType
  /// Maps from field names to their associated chunk vectors.
  fields : Map[String, Chunks]
} derive(Show, Eq)

///|
/// Errors that can occur when retrieving a field of an [`Entry`].
pub(all) enum RetrievalError {
  /// The entry has no field with this name.
  Missing(String)
  /// The field contains malformed data.
  TypeError(TypeError)
} derive(Eq)

///|
pub impl Show for RetrievalError with to_string(self) {
  match self {
    Missing(s) => "field \{s} is missing"
    TypeError(err) => "\{err}"
  }
}

///|
pub impl Show for RetrievalError with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
/// Converts a `Result[T, RetrievalError]` into a `Result[T? , TypeError]` with error handling.
fn[T] convert_result(err : Result[T, RetrievalError]) -> Result[T?, TypeError] {
  match err {
    Ok(val) => Ok(Some(val))
    Err(RetrievalError::Missing(_)) => Ok(None)
    Err(RetrievalError::TypeError(err)) => Err(err)
  }
}

///|
/// Create a new, empty bibliography.
pub fn Bibliography::new() -> Bibliography {
  Bibliography::default()
}

///|
/// Parse a bibliography from a source string.
pub fn Bibliography::parse(src : String) -> Result[Bibliography, ParseError] {
  try? Bibliography::from_raw(RawBibliogrphy::parse(src))
}

///|
/// Construct a bibliography from a raw bibliography, with the `xdata` and
/// `crossref` links resolved.
pub fn Bibliography::from_raw(
  raw : RawBibliogrphy,
) -> Bibliography raise ParseError {
  let res = Bibliography::new()
  let abbr = raw.abbreviations
  for entry in raw.entries {
    if res.get(entry.v.key.v) is Some(_) {
      raise ParseError((entry.span, DuplicateKey(entry.v.key.v)))
    }
    let fields = Map::new()
    for spanned_field in entry.v.fields {
      let field_key = spanned_field.key.v.to_lower()
      let parsed = parse_field(field_key, spanned_field.value.v, abbr)
      fields[field_key] = parsed
    }
    ignore(
      res.insert({
        key: entry.v.key.v,
        entry_type: EntryType::new(entry.v.kind.v),
        fields,
      }),
    )
  }
  let entries = res.entries.copy()
  for entry in entries {
    entry.resolve_crossrefs(res) catch {
      TypeError((span, kind)) => raise ParseError((span, ResolutionError(kind)))
    }
  }
  { ..res, entries, }
}

///|
/// The number of bibliography entries.
pub fn Bibliography::length(self : Bibliography) -> Int {
  self.entries.length()
}

///|
/// Whether the bibliography is empty.
pub fn Bibliography::is_empty(self : Bibliography) -> Bool {
  self.entries.is_empty()
}

///|
/// Returns the entry with the given cite key.
pub fn Bibliography::get(self : Bibliography, key : String) -> Entry? {
  let index = self.keys.get(key)
  guard index is Some(_) else { None }
  self.entries.get(index.unwrap())
}

///|
/// Insert an entry into the bibliography.
///
/// If an entry with the same cite key is already present, the entry is
/// updated and the old entry is returned.
pub fn Bibliography::insert(self : Bibliography, entry : Entry) -> Entry? {
  if self.get(entry.key) is Some(prev) {
    let index = self.keys.get(entry.key).unwrap()
    self.entries[index] = entry
    Some(prev)
  } else {
    let index = self.entries.length()
    self.keys[entry.key] = index
    let result_arraystring : Result[ArrayString, RetrievalError] = entry.get_as(
      "ids",
    )
    if convert_result(result_arraystring).unwrap() is Some(ids) {
      for alias_ in ids.0 {
        self.keys[alias_] = index
      }
    }
    self.entries.push(entry)
    None
  }
}

///|
/// Remove the entry with the given cite key.
pub fn Bibliography::remove(self : Bibliography, key : String) -> Entry? {
  let index = match self.keys.get(key) {
    Some(index) => index
    None => return None
  }
  let entry = self.entries.remove(index)
  self.keys.remove(key)
  self.keys = self.keys.map((_, v) => if v > index { v - 1 } else { v })
  Some(entry)
}

///|
/// Add an alias for a cite key.
///
/// Does nothing if no entry with the given cite key exists.
pub fn[T : Show] Bibliography::alias_(
  self : Bibliography,
  key : String,
  alias_ : T,
) -> Unit {
  if self.keys.get(key) is Some(index) {
    self.keys[alias_.to_string()] = index
  }
}

///|
/// An iterator over the bibliography's entries.
pub fn Bibliography::iter(self : Bibliography) -> Iter[Entry] {
  self.entries.iter()
}

///|
/// An iterator over the bibliography's entry keys.
pub fn Bibliography::keys(self : Bibliography) -> Iter[String] {
  self.entries.iter().map(entry => entry.key)
}

///|
/// Consume this struct and return a vector of the bibliography's entries.
pub fn Bibliography::to_array(self : Bibliography) -> Array[Entry] {
  self.entries
}

// FIXME: not related to file IO, only debugger log​

///|
/// Serialize this bibliography into a logger with BibLaTeX string.
pub fn Bibliography::write_biblatex(
  self : Bibliography,
  logger : &Logger,
) -> Unit {
  logger.write_char('\n')
  logger.write_string(self.to_biblatex_string())
}

///|
/// Serialize this bibliography into a BibLaTeX string.
pub fn Bibliography::to_biblatex_string(self : Bibliography) -> String {
  let mut res = ""
  for entry in self.entries {
    res += "\{entry.to_biblatex_string()}\n"
  }
  res
}

// FIXME: not related to file IO, only debugger log​

///|
/// Serialize this bibliography into a logger with BibTeX string.
pub fn Bibliography::write_bibtex(
  self : Bibliography,
  logger : &Logger,
) -> Unit {
  logger.write_char('\n')
  logger.write_string(self.to_bibtex_string())
}

///|
/// Serialize this bibliography into a BibTeX string.
pub fn Bibliography::to_bibtex_string(self : Bibliography) -> String {
  let mut res = ""
  for entry in self.entries {
    res += "\{entry.to_bibtex_string()}\n"
  }
  res
}

///|
/// Construct new, empty entry.
pub fn Entry::new(key : String, entry_type : EntryType) -> Entry {
  { key, entry_type, fields: Map::new() }
}

///|
/// Get the chunk slice of a field.
///
/// The field key must be lowercase.
pub fn Entry::get(self : Entry, key : String) -> Chunks? {
  self.fields.get(key)
}

///|
/// Retrieves and parses a field from an entry with type conversion.
pub fn[T : Type] Entry::get_as(
  self : Entry,
  key : String,
) -> Result[T, RetrievalError] {
  let res = self.get(key)
  if res is None {
    return Err(RetrievalError::Missing(key))
  }
  let res = res.unwrap()
  let res : T = parse_chunks(res) catch {
    err => return Err(RetrievalError::TypeError(err))
  }
  Ok(res)
}

///|
/// Retrieves and parses a field from an entry with permisstype type conversion.
pub fn[T : Type] Entry::get_as_permisstype(
  self : Entry,
  key : String,
) -> Result[PermissiveType[T], RetrievalError] {
  let res = self.get(key)
  if res is None {
    return Err(RetrievalError::Missing(key))
  }
  let res = res.unwrap()
  let res : PermissiveType[T] = PermissiveType::from_chunks(res)
  Ok(res)
}

///|
/// Set the chunk slice for a field.
///
/// The field key is lowercase before insertion.
pub fn Entry::set(self : Entry, key : String, chunks : Chunks) -> Unit {
  self.fields[key.to_lower()] = chunks
}

///|
/// Set the value of a field as a specific type.
///
/// The field key is lowercase before insertion.
pub fn[T : Type] Entry::set_as(self : Entry, key : String, value : T) -> Unit {
  self.set(key, value.to_chunks())
}

///|
/// Set the permisstype value of a field as a specific type.
///
/// The field key is lowercase before insertion.
pub fn[T : Type] Entry::set_as_permisstype(
  self : Entry,
  key : String,
  value : PermissiveType[T],
) -> Unit {
  self.set(key, PermissiveType::to_chunks(value))
}

///|
/// Remove a field from the entry.
pub fn Entry::remove(self : Entry, key : String) -> Chunks? {
  let res = self.fields.get(key)
  if res is None {
    None
  } else {
    self.fields.remove(key)
    res
  }
}

///|
/// The parents of an entry in a semantic sense (`crossref` and `xref`).
pub fn Entry::parents(self : Entry) -> Result[Array[String], TypeError] {
  let parents = []
  let res : Result[String, RetrievalError] = self.get_as("crossref")
  let crossref = convert_result(res)
  if crossref is Err(err) {
    return Err(err)
  }
  let crossref = crossref.unwrap()
  if crossref is Some(crossref) {
    parents.push(crossref)
  }
  let res : Result[ArrayString, RetrievalError] = self.get_as("xref")
  let xrefs = convert_result(res)
  if xrefs is Err(err) {
    return Err(err)
  }
  let xrefs = xrefs.unwrap()
  if xrefs is Some(xrefs) {
    parents.append(xrefs.0)
  }
  Ok(parents)
}

///|
/// Verify if the entry has the appropriate fields for its [`EntryType`].
pub fn Entry::verify(self : Entry) -> Report {
  let reqs = self.entry_type.requirements()
  let missing = []
  let superfluous = []
  for field in reqs.required {
    match field {
      "journaltitle" =>
        if self.get_non_empty(field) is None {
          missing.push(field)
        } else if self.get_non_empty("journal") is None {
          missing.push(field)
        }
      "location" =>
        if self.get_non_empty(field) is None {
          missing.push(field)
        } else if self.get_non_empty("address") is None {
          missing.push(field)
        }
      "school" =>
        if self.entry_type is (Thesis | MastersThesis | PhdThesis) {
          if self.get_non_empty(field) is None {
            missing.push(field)
          } else if self.get_non_empty("institution") is None {
            missing.push(field)
          }
        }
      _ => if self.get_non_empty(field) is None { missing.push(field) }
    }
  }
  for field in reqs.forbidden {
    if self.get_non_empty(field) is Some(_) {
      superfluous.push(field)
    }
  }
  let _ = match reqs.author_eds_field {
    OneRequired =>
      if self.author().is_err() && self.editors().or([]).is_empty() {
        missing.push("author")
      }
    BothRequired => {
      if self.editors().or([]).is_empty() {
        missing.push("editor")
      }
      if self.author().is_err() {
        missing.push("author")
      }
    }
    AuthorRequired | AuthorRequiredEditorOptional =>
      if self.author().is_err() {
        missing.push("author")
      }
    EditorRequiredAuthorForbidden => {
      if self.editors().or([]).is_empty() {
        missing.push("editor")
      }
      if self.author().is_ok() {
        superfluous.push("author")
      }
    }
    _ => ()
  }
  let _ = match reqs.page_chapter_field {
    OneRequired =>
      if self.pages().is_err() && self.chapter().is_err() {
        missing.push("pages")
      }
    BothForbidden => {
      if self.pages().is_ok() {
        superfluous.push("pages")
      }
      if self.chapter().is_ok() {
        superfluous.push("chapter")
      }
    }
    PagesRequired => if self.pages().is_err() { missing.push("pages") }
    _ => ()
  }
  let malformed = []
  for pair in self.fields {
    let key = pair.0
    let chunks = pair.1
    try {
      let _ = match key {
        "edition" => {
          let _ : PermissiveType[Int64] = PermissiveType::from_chunks(chunks)

        }
        "organization" => {
          let _ : ArrayChunks = parse_chunks(chunks)

        }
        "pages" => {
          let _ : ArrayRange = parse_chunks(chunks)

        }
        "publisher" => {
          let _ : ArrayChunks = parse_chunks(chunks)

        }
        "volume" => {
          let _ : Int64 = parse_chunks(chunks)

        }
        "bookpagination" => {
          let _ : Pagination = parse_chunks(chunks)

        }
        "pagination" => {
          let _ : Pagination = parse_chunks(chunks)

        }
        "volumes" => {
          let _ : Int64 = parse_chunks(chunks)

        }
        "gender" => {
          let _ : Gender = parse_chunks(chunks)

        }
        "editortype" => {
          let _ : EditorType = parse_chunks(chunks)

        }
        "editoratype" => {
          let _ : EditorType = parse_chunks(chunks)

        }
        "editorbtype" => {
          let _ : EditorType = parse_chunks(chunks)

        }
        "editorctype" => {
          let _ : EditorType = parse_chunks(chunks)

        }
        "xref" => {
          let _ : ArrayString = parse_chunks(chunks)

        }
        "xdata" => {
          let _ : ArrayString = parse_chunks(chunks)

        }
        "ids" => {
          let _ : ArrayString = parse_chunks(chunks)

        }
        _ => continue
      }

    } catch {
      err => malformed.push((key, err))
    }
  }
  let array = [
    ("date", self.date()),
    ("urldate", self.url_date()),
    ("origdate", self.orig_date()),
    ("eventdate", self.event_date()),
  ].map(pair => if pair.1.is_err() {
    (pair.0, Some(pair.1.unwrap_err()))
  } else {
    (pair.0, None)
  })
  for pair in array {
    let key = pair.0
    let err = pair.1
    if err is Some(TypeError(t)) {
      malformed.push((key, t))
    }
  }
  if reqs.needs_date {
    if self.date() is Err(Missing(_)) {
      missing.push("year")
    }
  }
  { missing, superfluous, malformed }
}

///|
/// Serialize this entry into a BibLaTeX string.
pub fn Entry::to_biblatex_string(self : Entry) -> String {
  let mut biblatex = ""
  let ty = self.entry_type.to_biblatex()
  biblatex += "@\{ty}{\{self.key},\n"
  for pair in self.fields {
    let key = pair.0
    let value = pair.1
    let key = match key {
      "journal" => "journaltitle"
      "address" => "location"
      "school" => "institution"
      k => k
    }
    biblatex += "\{key} = \{ChunkExt::to_biblatex_string(value,is_verbatim_field(key))},\n"
  }
  biblatex += "}"
  biblatex
}

///|
/// Serialize this entry into a BibTeX string.
///
pub fn Entry::to_bibtex_string(self : Entry) -> String {
  let mut bibtex = ""
  let ty = self.entry_type.to_bibtex()
  let thesis = ty is (PhdThesis | MastersThesis)
  bibtex += "@\{ty}{\{self.key}\n"
  for pair in self.fields {
    let key = pair.0
    let value = pair.1
    if key is "date" {
      let res = convert_result(self.date()).unwrap().unwrap()
      if res is Typed(date) {
        for kv in date.to_fieldset() {
          let key = kv.0
          let value = kv.1
          let v = ChunkExt::to_biblatex_string(
            [Spanned::zero(Chunk::Normal(value))],
            false,
          )
          bibtex += "\{key} = \{v},\n"
        }
        continue
      }
    }
    let key = match key {
      "journaltitle" => "journal"
      "location" => "address"
      "institution" if thesis => "school"
      k => k
    }
    bibtex += "\{key} = \{ChunkExt::to_biblatex_string(value,is_verbatim_field(key))},\n"
  }
  bibtex += "}"
  bibtex
}

///|
/// Get an entry but return None for empty chunk slices.
fn Entry::get_non_empty(self : Entry, key : String) -> Chunks? {
  let entry = self.get(key)
  if entry is None {
    None
  } else {
    let entry = entry.unwrap()
    if not(entry.is_empty()) {
      Some(entry)
    } else {
      None
    }
  }
}

///|
/// Resolves all data dependencies defined by `crossref` and `xdata` fields.
fn Entry::resolve_crossrefs(
  self : Entry,
  bib : Bibliography,
) -> Unit raise TypeError {
  let refs = []
  let s : Result[String, RetrievalError] = self.get_as("crossref")
  let s = convert_result(s).unwrap_or_error()
  if s is Some(crossref) {
    let entry = bib.get(crossref)
    if entry is Some(entry) {
      refs.push(entry)
    }
  }
  let array_s : Result[ArrayString, RetrievalError] = self.get_as("xdata")
  let array_s = convert_result(array_s).unwrap_or_error()
  if array_s is Some(keys) {
    let keys = keys.0
    for key in keys {
      let entry = bib.get(key)
      if entry is Some(entry) {
        refs.push(entry)
      }
    }
  }
  for crossref in refs {
    crossref.resolve_crossrefs(bib)
    self.resolve_single_crossref(crossref)
  }
  ignore(self.remove("xdata"))
}

///|
/// Resolve data dependencies using another entry.
fn Entry::resolve_single_crossref(
  self : Entry,
  crossref : Entry,
) -> Unit raise TypeError {
  let req = self.entry_type.requirements()
  let relevant = req.required
  relevant.append(req.optional)
  relevant.append(req.page_chapter_field.possible())
  relevant.append(req.author_eds_field.possible())
  if self.entry_type is XData {
    for f in crossref.fields.keys() {
      relevant.push(f)
    }
  }
  for f in relevant {
    if self.get(f) is Some(_) {
      continue
    }
    match f {
      "journaltitle" | "journalsubtitle" if crossref.entry_type is Periodical => {
        let key = if f.contains("s") { "subtitle" } else { "title" }
        if crossref.get(key) is Some(item) {
          self.set(f, item)
        }
      }
      "booktitle" | "booksubtitle" | "booktitleaddon" if crossref.entry_type.is_collection() => {
        let key = if f.contains("s") {
          "subtitle"
        } else if f.contains("a") {
          "titleaddon"
        } else {
          "title"
        }
        if crossref.get(key) is Some(item) {
          self.set(f, item)
        }
      }
      "maintitle" | "mainsubtitle" | "maintitleaddon" if crossref.entry_type.is_multi_volume() => {
        let key = if f.contains("s") {
          "subtitle"
        } else if f is "maintitleaddon" {
          "titleaddon"
        } else {
          "title"
        }
        if crossref.get(key) is Some(item) {
          self.set(f, item)
        }
      }
      "address" =>
        if crossref.get(f) is Some(item) {
          self.set(f, item)
        } else if crossref.get("location") is Some(item) {
          self.set(f, item)
        }
      "institution" =>
        if crossref.get(f) is Some(item) {
          self.set(f, item)
        } else if crossref.get("school") is Some(item) {
          self.set(f, item)
        }
      "school" =>
        if crossref.get(f) is Some(item) {
          self.set(f, item)
        } else if crossref.get("institution") is Some(item) {
          self.set(f, item)
        }
      "journaltitle" =>
        if crossref.get(f) is Some(item) {
          self.set(f, item)
        } else if crossref.get("journal") is Some(item) {
          self.set(f, item)
        }
      "title" | "addendum" | "note" => ()
      _ => if crossref.get(f) is Some(item) { self.set(f, item) }
    }
  }
  if self.entry_type is XData {
    return
  }
  if req.needs_date {
    if convert_result(crossref.date()).unwrap_or_error() is Some(date) {
      self.set_date(date)
    }
  }
}

///|
/// A report of the validity of an `Entry`. Can be obtained by calling [`Entry::verify`].
pub(all) struct Report {
  /// These fields were missing, although they are required for the entry type.
  missing : Array[String]
  /// These fields were present but are not allowed for the entry type.
  superfluous : Array[String]
  /// These fields were present but contained malformed data.
  malformed : Array[(String, TypeError)]
} derive(Show, Eq)

///| Whether the report is empty and contains no errors.
pub fn Report::is_ok(self : Report) -> Bool {
  self.missing.is_empty() &&
  self.superfluous.is_empty() &&
  self.malformed.is_empty()
}

///|
test "test_correct_bib" {
  let contents = @fs.read_file_to_string("tests/gral.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  assert_eq(bibliography.entries.length(), 83)
}

///|
test "test_repeated_key" {
  let contents = @fs.read_file_to_string("tests/gral_rep_key.bib")
  let bibliography = Bibliography::parse(contents)
  match bibliography {
    Ok(_) => abort("Should return Err")
    Err(s) => {
      let ParseError((_, kind)) = s
      assert_eq(kind, DuplicateKey("ishihara2012"))
    }
  }
}

///|
test "test_parse_incorrect_result" {
  let contents = @fs.read_file_to_string("tests/incorrect_syntax.bib")
  let bibliography = Bibliography::parse(contents)
  match bibliography {
    Ok(_) => abort("Should return Err")
    Err(s) =>
      assert_eq(
        s,
        ParseError(({ start: 369, end: 369 }, Expected(Token::Equals))),
      )
  }
}

///|
test "test_parse_incorrect_types" {
  let contents = @fs.read_file_to_string("tests/incorrect_data.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  let rashid = bibliography.get("rashid2016").unwrap()
  match rashid.pagination() {
    Err(TypeError(s)) =>
      assert_eq(s, TypeError(({ start: 352, end: 359 }, UnknownPagination)))
    _ => abort("")
  }
}

///|
test "test_keys" {
  let contents = @fs.read_file_to_string("tests/editortypes.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  assert_eq(bibliography.keys().collect(), [
    "acerolaThisDifferenceGaussians2022", "mozart_KV183_1773", "Smith2018",
  ])
}

///|
test "test_gral_paper" {
  dump_debug("tests/gral.bib")
}

///|
test "test_ds_report" {
  dump_debug("tests/ds.bib")
}

///|
test "test_libra_paper" {
  dump_author_title("tests/libra.bib")
}

///|
test "test_rass_report" {
  dump_author_title("tests/rass.bib")
}

///|
test "test_polar_report" {
  dump_author_title("tests/polaritons.bib")
}

///|
test "test_comments" {
  let contents = @fs.read_file_to_string("tests/comments.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  assert_eq(bibliography.keys().collect(), [
    "mcelreath2007mathematical", "fischer2022equivalence", "roes2003belief", "wong2016null",
  ])
  assert_eq(
    ChunkExt::format_verbatim(
      bibliography.get("wong2016null").unwrap().title().unwrap(),
    ),
    "Null hypothesis testing (I)-5% significance level",
  )
}

///|
test "test_extended_name_format" {
  dump_author_title("tests/extended_name_format.bib")
}

///|
fn dump_debug(file : String) -> Unit raise @fs.IOError {
  let contents = @fs.read_file_to_string(file)
  let bibliography = Bibliography::parse(contents).unwrap()
  println("\{bibliography}")
}

///|
fn dump_author_title(file : String) -> Unit raise @fs.IOError {
  let contents = @fs.read_file_to_string(file)
  let bibliography = Bibliography::parse(contents).unwrap()
  println(bibliography.to_biblatex_string())
  for x in bibliography {
    let authors = match x.author() {
      Ok(a) => a
      Err(_) => []
    }
    let mut res = ""
    for a in authors {
      res += "\{a}, "
    }
    println(res)
    println("\"\{ChunkExt::format_sentence(x.title().unwrap())}\".")
  }
}

///|
test "test_alias" {
  let contents = @fs.read_file_to_string("tests/cross.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  assert_eq(bibliography.get("issue201"), bibliography.get("github"))
  bibliography.alias_("issue201", "crap")
  assert_eq(bibliography.get("crap"), bibliography.get("unstable"))
  let _ = bibliography.remove("crap")
  let entry = bibliography.get("cannonfodder").unwrap()
  assert_eq(entry.key, "cannonfodder")
  assert_eq(entry.entry_type, Misc)
}

///|
test "test_bibtex_conversion" {
  let contents = @fs.read_file_to_string("tests/cross.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  let biblatex = bibliography.get("haug2019").unwrap().to_biblatex_string()
  assert_true(
    biblatex.contains("institution = {Technische Universität Berlin},"),
  )
  let bibtex = bibliography.get("haug2019").unwrap().to_bibtex_string()
  assert_true(bibtex.contains("school = {Technische Universität Berlin},"))
  assert_true(bibtex.contains("year = {2019},"))
  assert_true(bibtex.contains("month = {10},"))
  assert_true(!bibtex.contains("institution"))
  assert_true(!bibtex.contains("date"))
}

///|
test "test_verify" {
  let contents = @fs.read_file_to_string("tests/cross.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  assert_true(bibliography.get("haug2019").unwrap().verify().is_ok())
  assert_true(bibliography.get("cannonfodder").unwrap().verify().is_ok())
  let ill = bibliography.get("ill-defined").unwrap()
  let report = ill.verify()
  assert_eq(report.missing.length(), 3)
  assert_eq(report.superfluous.length(), 3)
  assert_eq(report.malformed.length(), 1)
  assert_true(report.missing.contains("title"))
  assert_true(report.missing.contains("year"))
  assert_true(report.missing.contains("editor"))
  assert_true(report.superfluous.contains("maintitle"))
  assert_true(report.superfluous.contains("author"))
  assert_true(report.superfluous.contains("chapter"))
  assert_eq(report.malformed[0].0, "gender")
  let contents = @fs.read_file_to_string("tests/libra.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  let tien = bibliography.get("tienBigDataUnleashing2013").unwrap()
  let report = tien.verify()
  assert_true(report.missing.contains("journaltitle"))
  let entry = Entry::new("test1", Article)
  let _ = entry.verify()
  let entry = Entry::new("test2", InCollection)
  let _ = entry.verify()
  let entry = Entry::new("test3", XData)
  let _ = entry.verify()
  let entry = Entry::new("test4", Dataset)
  let _ = entry.verify()
  let entry = Entry::new("test5", InBook)
  let _ = entry.verify()
  let entry = Entry::new("test6", MvProceedings)
  entry.set_pages(Typed([{ start: 1, end: 2 }]))
  let _ = entry.verify()
  let entry = Entry::new("test7", Article)
  entry.set_edition(Typed(2999))
  entry.set_organization([[Spanned::detached(Normal("organization"))]])
  entry.set_publisher([[Spanned::detached(Normal("publisher"))]])
  entry.set_book_pagination(Page)
  entry.set_pagination(Page)
  entry.fields.set("editortype", [Spanned::detached(Normal("editor"))])
  entry.fields.set("editoratype", [Spanned::detached(Normal("editor"))])
  entry.fields.set("editorbtype", [Spanned::detached(Normal("editor"))])
  entry.fields.set("editorctype", [Spanned::detached(Normal("editor"))])
  entry.fields.set("xref", [Spanned::detached(Normal("xref"))])
  entry.fields.set("xdata", [Spanned::detached(Normal("xdata"))])
  entry.fields.set("ids", [Spanned::detached(Normal("ids"))])
  entry.fields.set("eventyear", [Spanned::detached(Normal("1944"))])
  entry.fields.set("eventmonth", [Spanned::detached(Normal("March"))])
  entry.fields.set("eventday", [Spanned::detached(Normal("64"))])
  let _ = entry.verify()

}

///|
test "test_crossref" {
  let contents = @fs.read_file_to_string("tests/cross.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  let e = bibliography.get("macmillan").unwrap()
  assert_eq(ChunkExt::format_verbatim(e.publisher().unwrap()[0]), "Macmillan")
  assert_eq(
    ChunkExt::format_verbatim(e.location().unwrap()),
    "New York and London",
  )
  let book = bibliography.get("recursive").unwrap()
  assert_eq(
    ChunkExt::format_verbatim(book.publisher().unwrap()[0]),
    "Macmillan",
  )
  assert_eq(
    ChunkExt::format_verbatim(book.location().unwrap()),
    "New York and London",
  )
  assert_eq(
    ChunkExt::format_verbatim(book.title().unwrap()),
    "Recursive shennenigans and other important stuff",
  )
  assert_eq(bibliography.get("arrgh").unwrap().parents().unwrap(), [
    "polecon".to_string(),
  ])
  let arrgh = bibliography.get("arrgh").unwrap()
  assert_eq(arrgh.entry_type, Article)
  assert_eq(arrgh.volume().unwrap(), PermissiveType::Typed(115))
  assert_eq(arrgh.editors().unwrap()[0].0[0].name, "Uhlig")
  assert_eq(ChunkExt::format_verbatim(arrgh.number().unwrap()), "6")
  assert_eq(
    ChunkExt::format_verbatim(arrgh.journal().unwrap()),
    "Journal of Political Economy",
  )
  assert_eq(
    ChunkExt::format_verbatim(arrgh.title().unwrap()),
    "An‐arrgh‐chy: The Law and Economics of Pirate Organization",
  )
}

///|
test "linebreak_field" {
  let contents =
    #|@book{key, title = {Hello
    #|Martin}};
  let bibliography = Bibliography::parse(contents).unwrap()
  let entry = bibliography.get("key").unwrap()
  assert_eq(ChunkExt::format_verbatim(entry.title().unwrap()), "Hello Martin")
}

///|
test "test_verbatim_fields" {
  let contents = @fs.read_file_to_string("tests/libra.bib")
  let bibliography = Bibliography::parse(contents).unwrap()

  // Import an entry/field with escaped colons
  let e = bibliography.get("dierksmeierJustHODLMoral2018").unwrap()
  assert_eq(e.doi().unwrap(), "10.1007/s41463-018-0036-z")
  assert_eq(
    e.file().unwrap(),
    "C:\\Users\\mhaug\\Zotero\\storage\\DTPR7TES\\Dierksmeier - 2018 - Just HODL On the Moral Claims of Bitcoin and Ripp.pdf",
  )

  // Import an entry/field with unescaped colons
  let e = bibliography.get("LibraAssociationIndependent").unwrap()
  assert_eq(e.url().unwrap(), "https://libra.org/association/")

  // Test export of entry (not escaping colons)
  let e = bibliography.get("finextraFedGovernorChallenges2019").unwrap()
  let s =
    #|@online{finextraFedGovernorChallenges2019,
    #|title = {Fed {Governor} Challenges {Facebook}'s {Libra} Project},
    #|author = {FinExtra},
    #|date = {2019-12-18},
    #|url = {https://www.finextra.com/newsarticle/34986/fed-governor-challenges-facebooks-libra-project},
    #|urldate = {2020-08-22},
    #|file = {C:\\Users\\mhaug\\Zotero\\storage\\VY9LAKFE\\fed-governor-challenges-facebooks-libra-project.html},
    #|}
  assert_eq(e.to_biblatex_string(), s)

  // Test URLs with math and backslashes
  let e = bibliography.get("weirdUrl2023").unwrap()
  let s =
    #|example.com?A=$B\%\{}
  assert_eq(e.url().unwrap(), s)
  let s =
    #|example.com?A=$B\%\{}
  assert_eq(e.doi().unwrap(), s)
}

///|
test "test_synthesized_entry" {
  let e = Entry::new("Test123", EntryType::Article)
  let person : Person = {
    name: "Monroe",
    given_name: "Brian Albert",
    prefix: "",
    suffix: "",
  }
  let brian = [person]
  e.set_author(brian)
  assert_eq(Ok(brian), e.author())
}

///|
test "test_case_sensitivity" {
  let contents = @fs.read_file_to_string("tests/case.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  let entry = bibliography.get("biblatex2023").unwrap()
  let author = entry.author()
  match author {
    Ok(a) => assert_eq(a[0].name, "Kime")
    Err(RetrievalError::Missing(_)) => abort("Tags should be case insensitive.")
    _ => abort("")
  }
}

///|
test "test_whitespace_collapse" {
  let raw =
    #|@article{aksin,
    #|title        = {Effect of immobilization on catalytic characteristics of
    #|saturated {Pd-N}-heterocyclic carbenes in {Mizoroki-Heck}
    #|reactions},
    #|}
  let bibliography = Bibliography::parse(raw).unwrap()
  let entry = bibliography.get("aksin").unwrap()
  assert_eq(
    entry.title().unwrap().get(0).map(s => s.v),
    Some(
      Chunk::Normal(
        "Effect of immobilization on catalytic characteristics of saturated ".to_string(),
      ),
    ),
  )
}

///|
test "test_empty_date_fields" {
  let raw =
    #|@article{test,
    #|            year        = 2000,
    #|            day         = {},
    #|            month    = {},
    #|          }
  let bibliography = Bibliography::parse(raw).unwrap()
  assert_eq(
    bibliography.get("test").unwrap().date(),
    Err(
      TypeError(
        TypeError(({ start: 74, end: 74 }, TypeErrorKind::MissingNumber)),
      ),
    ),
  )
}

///|
test "test_page_ranges" {
  let raw =
    #|@article{test,
    #|pages = {1---2},
    #|}
    #|@article{test1,
    #|pages = {2--3},
    #|}
    #|@article{test2,
    #|pages = {1},
    #|}
  let bibliography = Bibliography::parse(raw).unwrap()
  assert_eq(
    bibliography.get("test").unwrap().pages(),
    Ok(PermissiveType::Typed([{ start: 1, end: 2 }])),
  )
  assert_eq(
    bibliography.get("test1").unwrap().pages(),
    Ok(PermissiveType::Typed([{ start: 2, end: 3 }])),
  )
  assert_eq(
    bibliography.get("test2").unwrap().pages(),
    Ok(PermissiveType::Typed([{ start: 1, end: 1 }])),
  )
}

///|
test "test_editor_types" {
  let contents = @fs.read_file_to_string("tests/editortypes.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  let video = bibliography.get("acerolaThisDifferenceGaussians2022").unwrap()
  assert_eq(
    video.editors(),
    Ok([
      (
        [{ name: "Acerola", given_name: "", prefix: "", suffix: "" }],
        EditorType::Director,
      ),
    ]),
  )
  let music = bibliography.get("mozart_KV183_1773").unwrap()
  assert_eq(
    music.editors(),
    Ok([
      (
        [
          {
            name: "Mozart",
            given_name: "Wolfgang Amadeus",
            prefix: "",
            suffix: "",
          },
        ],
        EditorType::Unknown("pianist"),
      ),
    ]),
  )
  let audio = bibliography.get("Smith2018").unwrap()
  assert_eq(
    audio.editors(),
    Ok([
      (
        [{ name: "Smith", given_name: "Stacey Vanek", prefix: "", suffix: "" }],
        EditorType::Unknown("host"),
      ),
      (
        [{ name: "Plotkin", given_name: "Stanley", prefix: "", suffix: "" }],
        EditorType::Unknown("participant"),
      ),
    ]),
  )
}

///|
test "test_show" {
  assert_eq(Missing("author").to_string(), "field author is missing")
  let raw =
    #|@article{aksin,
    #|title        = {Effect of immobilization on catalytic characteristics of
    #|saturated {Pd-N}-heterocyclic carbenes in {Mizoroki-Heck}
    #|reactions},
    #|}
  let bibliography = Bibliography::parse(raw).unwrap()
  let logger = StringBuilder::new()
  bibliography.write_biblatex(logger)
  assert_eq(
    logger.to_string(),
    "\n@article{aksin,\ntitle = {Effect of immobilization on catalytic characteristics of saturated {Pd-N}-heterocyclic carbenes in {Mizoroki-Heck} reactions},\n}\n",
  )
  let logger = StringBuilder::new()
  bibliography.write_bibtex(logger)
  assert_eq(
    logger.to_string(),
    "\n@article{aksin\ntitle = {Effect of immobilization on catalytic characteristics of saturated {Pd-N}-heterocyclic carbenes in {Mizoroki-Heck} reactions},\n}\n",
  )
  let logger = StringBuilder::new()
  let error = TypeError(TypeError(({ start: 1, end: 2 }, InvalidFormat)))
  error.output(logger)
  assert_eq(logger.to_string(), "invalid format: 1-2")
}

///|
test "test_error" {
  let err : TypeError = TypeError(
    ({ start: 1, end: 2 }, TypeErrorKind::InvalidFormat),
  )
  let convert_err : Result[Unit?, TypeError] = convert_result(
    Err(TypeError(err)),
  )
  assert_eq(convert_err, Err(err))
  let contents = @fs.read_file_to_string("tests/gral_rep_key.bib")
  let bibliography = Bibliography::parse(contents)
  assert_eq(
    bibliography,
    Err(
      ParseError(
        (
          { start: 28452, end: 28744 },
          ParseErrorKind::DuplicateKey("ishihara2012"),
        ),
      ),
    ),
  )
  let raw_bib = RawBibliogrphy::new()
  let rc1 : Field = [Spanned::detached(Normal("1944"))]
  let rc2 : Field = [Spanned::detached(Normal("10"))]
  let rc3 : Field = [Spanned::detached(Normal("64"))]
  let rc4 : Field = [Spanned::detached(Normal("test"))]
  let pair = [
    { key: Spanned::detached("year"), value: Spanned::detached(rc1) },
    { key: Spanned::detached("month"), value: Spanned::detached(rc2) },
    { key: Spanned::detached("day"), value: Spanned::detached(rc3) },
  ]
  let raw_entry : RawEntry = {
    key: Spanned::detached("test"),
    kind: Spanned::detached("article"),
    fields: pair,
  }
  let cross_pair = [
    { key: Spanned::detached("crossref"), value: Spanned::detached(rc4) },
  ]
  let raw_entry_cross : RawEntry = {
    key: Spanned::detached("test2"),
    kind: Spanned::detached("article"),
    fields: cross_pair,
  }
  raw_bib.entries.push(Spanned::detached(raw_entry))
  raw_bib.entries.push(Spanned::detached(raw_entry_cross))
  let _ = Bibliography::from_raw(raw_bib) catch {
    ParseError((_, kind)) => {
      assert_eq(kind, ResolutionError(DayOutOfRange))
      Bibliography::new()
    }
  }

}

///|
test "test_Bibliography_Entry" {
  let contents = @fs.read_file_to_string("tests/rass.bib")
  let bibliography = Bibliography::parse(contents).unwrap()
  assert_eq(bibliography.length(), 22)
  let raw =
    #|@article{aksin,
    #|title        = {Effect of immobilization on catalytic characteristics of
    #|saturated {Pd-N}-heterocyclic carbenes in {Mizoroki-Heck}
    #|reactions},
    #|}
  let bibliography = Bibliography::parse(raw).unwrap()
  let c1 = Spanned::new(
    Chunk::Normal(
      "Effect of immobilization on catalytic characteristics of saturated ",
    ),
    { start: 32, end: 99 },
  )
  let c2 = Spanned::new(Chunk::Verbatim("Pd-N"), { start: 100, end: 104 })
  let c3 = Spanned::new(Chunk::Normal("-heterocyclic carbenes in "), {
    start: 105,
    end: 131,
  })
  let c4 = Spanned::new(Chunk::Verbatim("Mizoroki-Heck"), {
    start: 132,
    end: 145,
  })
  let c5 = Spanned::new(Chunk::Normal(" reactions"), { start: 146, end: 156 })
  let entry = Entry::new("aksin", Article)
  let array = [c1, c2, c3, c4, c5]
  entry.set_title(array)
  assert_eq(bibliography.to_array(), [entry])
  assert_false(bibliography.is_empty())
  assert_eq(bibliography.insert(entry), Some(entry))
  assert_eq(bibliography.remove("test"), None)
}

///|
test "test_Entry" {
  let entry = Entry::new("aksin", Article)
  entry.fields.set("gender", [Spanned::detached(Normal("1944XGD"))])
  let type_error : TypeError = TypeError(
    ({ start: 2147483647, end: 2147483647 }, UnknownGender),
  )
  let res : Result[Gender, RetrievalError] = entry.get_as("gender")
  assert_eq(res, Err(TypeError(type_error)))
  let number : Int64 = 2999
  entry.set_as("volumes", number)
  assert_eq(entry.volumes(), Ok(2999))
  let array_string : ArrayString = ArrayString([
    "a short review", "a long review",
  ])
  entry.set_as("xref", array_string)
  assert_eq(entry.parents(), Ok(["a short review", "a long review"]))
  let entry = Entry::new("aksin", Article)
  entry.set_date(Chunks([Spanned::detached(Normal("date"))]))
  entry.set_journal_title([Spanned::detached(Normal("journaltitle"))])
  entry.set_location([Spanned::detached(Normal("location"))])
  assert_eq(
    entry.to_bibtex_string(),
    "@article{aksin\ndate = {date},\njournal = {journaltitle},\naddress = {location},\n}",
  )
  entry.set_abstract_([])
  assert_eq(entry.get_non_empty("abstract"), None)
  let entry = Entry::new("aksin", XData)
  let cross_entry = Entry::new("bksin", Book)
  cross_entry.fields.set("booktitle", [])
  cross_entry.fields.set("title", [])
  entry.resolve_single_crossref(cross_entry)
  let cross_entry = Entry::new("bksin", Book)
  cross_entry.fields.set("booksubtitle", [])
  entry.resolve_single_crossref(cross_entry)
  let cross_entry = Entry::new("bksin", Book)
  cross_entry.fields.set("booktitleaddon", [])
  entry.resolve_single_crossref(cross_entry)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("maintitle", [])
  cross_entry.fields.set("address", [])
  cross_entry.fields.set("title", [])
  entry.resolve_single_crossref(cross_entry)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("mainsubtitle", [])
  entry.resolve_single_crossref(cross_entry)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("maintitleaddon", [])
  entry.resolve_single_crossref(cross_entry)
  let entry = Entry::new("aksin", TechReport)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("institution", [])
  entry.resolve_single_crossref(cross_entry)
  let entry = Entry::new("aksin", TechReport)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("school", [])
  entry.resolve_single_crossref(cross_entry)
  let entry = Entry::new("aksin", MastersThesis)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("school", [])
  entry.resolve_single_crossref(cross_entry)
  let entry = Entry::new("aksin", MastersThesis)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("institution", [])
  entry.resolve_single_crossref(cross_entry)
  let entry = Entry::new("aksin", Article)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("journaltitle", [])
  entry.resolve_single_crossref(cross_entry)
  let entry = Entry::new("aksin", Article)
  let cross_entry = Entry::new("bksin", MvBook)
  cross_entry.fields.set("journal", [])
  entry.resolve_single_crossref(cross_entry)
  let entry = Entry::new("", Article)
  let res : Result[PermissiveType[EditorType], RetrievalError] = entry.get_as_permisstype(
    "editor",
  )
  assert_eq(res, Err(Missing("editor")))
  entry.set_as_permisstype("editor", Typed(EditorType::Compiler))
  let res : Result[PermissiveType[EditorType], RetrievalError] = entry.get_as_permisstype(
    "editor",
  )
  assert_eq(res, Ok(Typed(Compiler)))
}
