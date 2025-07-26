///|
typealias @types.(TypeError, Chunk, ArrayString)

///|
typealias Array[Spanned[Chunk]] as Chunks

///|
typealias @span.Span

///|
traitalias @types.(Type, ChunkExt)

///|
fnalias @types.parse_chunks

///|
pub(all) struct Bibliography {
  mut entries : Array[Entry]
  mut keys : Map[String, Int]
} derive(Default)

///|
pub(all) struct Entry {
  key : String
  entry_type : EntryType
  fields : Map[String, Chunks]
}

///|
pub(all) enum RetrievalError {
  Missing(String)
  TypeError(TypeError)
}

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
fn[T] convert_result(err : Result[T, RetrievalError]) -> Result[T?, TypeError] {
  match err {
    Ok(val) => Ok(Some(val))
    Err(RetrievalError::Missing(_)) => Ok(None)
    Err(RetrievalError::TypeError(err)) => Err(err)
  }
}

///|
pub fn Bibliography::new() -> Bibliography {
  Bibliography::default()
}

///|
pub fn Bibliography::parse(src : String) -> Result[Bibliography, ParseError] {
  try? Bibliography::from_raw(RawBibliogrphy::parse(src))
}

///|
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
pub fn Bibliography::length(self : Bibliography) -> Int {
  self.entries.length()
}

///|
pub fn Bibliography::is_empty(self : Bibliography) -> Bool {
  self.entries.is_empty()
}

///|
pub fn Bibliography::get(self : Bibliography, key : String) -> Entry? {
  let index = self.keys.get(key)
  guard index is Some(_) else { None }
  self.entries.get(index.unwrap())
}

///|
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
      for alias_ in ids.inner() {
        self.keys[alias_] = index
      }
    }
    self.entries.push(entry)
    None
  }
}

///|
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
pub fn Bibliography::iter(self : Bibliography) -> Iter[Entry] {
  self.entries.iter()
}

///|
pub fn Bibliography::keys(self : Bibliography) -> Iter[String] {
  self.entries.iter().map(entry => entry.key)
}

///|
pub fn Bibliography::to_array(self : Bibliography) -> Array[Entry] {
  self.entries
}

// FIXME: not related to file IO, only debugger log​

///|
pub fn Bibliography::write_biblatex(
  self : Bibliography,
  logger : &Logger,
) -> Unit {
  logger.write_char('\n')
  logger.write_string(self.to_biblatex_string())
}

///|
pub fn Bibliography::to_biblatex_string(self : Bibliography) -> String {
  let mut res = ""
  for entry in self.entries {
    res += "\{entry.to_biblatex_string()}\n"
  }
  res
}

// FIXME: not related to file IO, only debugger log​

///|
pub fn Bibliography::write_bibtex(
  self : Bibliography,
  logger : &Logger,
) -> Unit {
  logger.write_char('\n')
  logger.write_string(self.to_bibtex_string())
}

///|
pub fn Bibliography::to_bibtex_string(self : Bibliography) -> String {
  let mut res = ""
  for entry in self.entries {
    res += "\{entry.to_bibtex_string()}\n"
  }
  res
}

///|
pub fn Entry::new(key : String, entry_type : EntryType) -> Entry {
  { key, entry_type, fields: Map::new() }
}

///|
pub fn Entry::get(self : Entry, key : String) -> Chunks? {
  self.fields.get(key)
}

///|
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
pub fn Entry::set(self : Entry, key : String, chunks : Chunks) -> Unit {
  self.fields[key.to_lower()] = chunks
}

///|
pub fn[T : Type] Entry::set_as(self : Entry, key : String, value : T) -> Unit {
  self.set(key, value.to_chunks())
}

///|
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
    parents.append(xrefs.inner())
  }
  Ok(parents)
}

///|
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
pub fn Entry::to_biblatex_string(self : Entry) -> String {
  let mut biblatex = ""
  let ty = self.entry_type.to_biblatex()
  biblatex += "@\{ty}{{\{self.key},\n"
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
pub fn Entry::to_bibtex_string(self : Entry) -> Result[String, TypeError] {
  let mut bibtex = ""
  let ty = self.entry_type.to_bibtex()
  let thesis = ty is (PhdThesis | MastersThesis)
  bibtex += "@\{ty}{{\{self.key}\n"
  for pair in self.fields {
    let key = pair.0
    let value = pair.1
    if key is "date" {
      let res = convert_result(self.date())
      if res.is_err() {
        return Err(res.unwrap_err())
      }
      if res.unwrap() is Some(date) {
        if date is Typed(date) {
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
      } else {
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
  Ok(bibtex)
}

///|
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
    let keys = keys.inner()
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
        } else if f.contains("a") {
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
pub(all) struct Report {
  /// These fields were missing, although they are required for the entry type.
  missing : Array[String]
  /// These fields were present but are not allowed for the entry type.
  superfluous : Array[String]
  /// These fields were present but contained malformed data.
  malformed : Array[(String, TypeError)]
}

///| Whether the report is empty and contains no errors.
pub fn Report::is_ok(self : Report) -> Bool {
  self.missing.is_empty() &&
  self.superfluous.is_empty() &&
  self.malformed.is_empty()
}
// test "temp" {

// }  ArrayString::get_as(entry,"ids")
//   entry
