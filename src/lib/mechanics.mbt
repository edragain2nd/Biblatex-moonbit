///|
/// Describes the type of a bibliographical entry.
///
/// Each type comes with a different set of required and allowable fields that
/// are taken into consideration in [`Entry::verify`](crate::Entry::verify).
pub(all) enum EntryType {
  // BibTeX
  Article
  Book
  Booklet
  InBook
  InCollection
  InProceedings
  Manual
  MastersThesis
  PhdThesis
  Misc
  Proceedings
  TechReport
  Unpublished

  // BibLaTeX
  MvBook
  BookInBook
  SuppBook
  Periodical
  SuppPeriodical
  Collection
  MvCollection
  SuppCollection
  Reference
  MvReference
  InReference
  MvProceedings
  Report
  Patent
  Thesis
  Online
  Software
  Dataset
  Set
  XData
  Unknown(String)
} derive(Eq, Compare)

///|
pub impl Show for EntryType with to_string(self) {
  match self {
    Unknown(s) => "Unknown(\{s})"
    EntryType::Article => "article"
    EntryType::Book => "book"
    EntryType::Booklet => "booklet"
    EntryType::InBook => "inbook"
    EntryType::InCollection => "incollection"
    EntryType::InProceedings => "inproceedings"
    EntryType::Manual => "manual"
    EntryType::MastersThesis => "mastersthesis"
    EntryType::PhdThesis => "phdthesis"
    EntryType::Misc => "misc"
    EntryType::Proceedings => "proceedings"
    EntryType::TechReport => "techreport"
    EntryType::Unpublished => "unpublished"
    EntryType::MvBook => "mvbook"
    EntryType::BookInBook => "bookinbook"
    EntryType::SuppBook => "suppbook"
    EntryType::Periodical => "periodical"
    EntryType::SuppPeriodical => "suppperiodical"
    EntryType::Collection => "collection"
    EntryType::MvCollection => "mvcollection"
    EntryType::SuppCollection => "suppcollection"
    EntryType::Reference => "reference"
    EntryType::MvReference => "mvreference"
    EntryType::InReference => "inreference"
    EntryType::MvProceedings => "mvproceedings"
    EntryType::Report => "report"
    EntryType::Patent => "patent"
    EntryType::Thesis => "thesis"
    EntryType::Online => "online"
    EntryType::Software => "software"
    EntryType::Dataset => "dataset"
    EntryType::Set => "set"
    EntryType::XData => "xdata"
  }
}

///|
pub impl Show for EntryType with output(self, logger) {
  logger.write_string(self.to_string())
  logger.write_char('\n')
}

///|
/// Describes the optionality mode of the `author` and `editor` fields.
pub enum AuthorMode {
  /// Neither of the fields are required to be set.
  NoneRequired
  /// At least one of the fields must be present.
  OneRequired
  /// Both fields must be set.
  BothRequired
  /// The `author` field must be present.
  AuthorRequired
  /// The `author` field must be present, the `editor` field is optional.
  AuthorRequiredEditorOptional
  /// The `editor` field must be set while the `author` field must not be set.
  EditorRequiredAuthorForbidden
} derive(Show, Eq)

///|
impl Default for AuthorMode with default() {
  AuthorRequired
}

///|
/// Returns the array of valid contributor roles for this author mode.
pub fn AuthorMode::possible(self : AuthorMode) -> Array[String] {
  match self {
    OneRequired | BothRequired | AuthorRequiredEditorOptional =>
      ["author", "editor"]
    AuthorRequired => ["author"]
    EditorRequiredAuthorForbidden => ["editor"]
    _ => []
  }
}

///|
/// Describes the optionality mode of the `pages` and `chapter` field
pub(all) enum PagesChapterMode {
  /// No specification for the `page` and `chapter` field is given.
  None
  /// At least one of the fields must be present.
  OneRequired
  /// Both fields are optional.
  BothOptional
  /// Neither field may appear.
  BothForbidden
  /// The `pages` field might be present, there is no specification for the
  /// `chapter` field.
  PagesOptional
  /// The `pages` field must be present.
  PagesRequired
} derive(Show, Eq)

///|
impl Default for PagesChapterMode with default() {
  None
}

///|
/// Returns the array of valid contributor roles for this pages chapter mode.
pub fn PagesChapterMode::possible(self : PagesChapterMode) -> Array[String] {
  match self {
    OneRequired | BothOptional => ["pages", "chapter"]
    PagesOptional | PagesRequired => ["pages"]
    _ => []
  }
}

///|
/// Specifies what kinds of fields an entry might have to hold.
pub(all) struct Requirments {
  /// Fields that have to be present for the entry to be valid.
  required : Array[String]
  /// Fields that might be present and are often used by bibliography styles.
  ///
  /// These fields, together with the required fields, will be taken into
  /// consideration for `crossref` and `xdata` transfers.
  optional : Array[String]
  /// These fields must not appear for the entry to be valid.
  forbidden : Array[String]
  /// Specifies the relation of author and editor field compulsiveness.
  mut author_eds_field : AuthorMode
  /// Specifies the relation of page and chapter field compulsiveness.
  mut page_chapter_field : PagesChapterMode
  /// Shows whether a `date` or `year` field has to be present.
  mut needs_date : Bool
} derive(Default, Show, Eq)

///|
/// Parse from a string.
pub fn EntryType::new(name : String) -> EntryType {
  let name = name.to_lower()
  match name {
    // BibTeX
    "article" => Article
    "book" => Book
    "booklet" => Booklet
    "inbook" => InBook
    "incollection" => InCollection
    "inproceedings" => InProceedings
    "manual" => Manual
    "mastersthesis" => MastersThesis
    "phdthesis" => PhdThesis
    "misc" => Misc
    "proceedings" => Proceedings
    "techreport" => TechReport
    "unpublished" => Unpublished

    // BibLaTeX
    "mvbook" => MvBook
    "bookinbook" => BookInBook
    "suppbook" => SuppBook
    "periodical" => Periodical
    "suppperiodical" => SuppPeriodical
    "collection" => Collection
    "mvcollection" => MvCollection
    "suppcollection" => SuppCollection
    "reference" => Reference
    "mvreference" => MvReference
    "inreference" => InReference
    "mvproceedings" => MvProceedings
    "report" => Report
    "patent" => Patent
    "thesis" => Thesis
    "online" => Online
    "software" => Software
    "dataset" => Dataset
    "set" => Set
    "xdata" => XData
    "conference" => InProceedings
    "electronic" => Online
    "www" => Online
    _ => Unknown(name)
  }
}

///|
/// Is this a multi-volume work?
pub fn EntryType::is_multi_volume(self : EntryType) -> Bool {
  self is (MvBook | MvCollection | MvReference | MvProceedings)
}

///|
/// Is this a single-volume composite work?
pub fn EntryType::is_collection(self : EntryType) -> Bool {
  self is (Book | Collection | Periodical | Reference | Proceedings)
}

///|
/// Convert into a type native to BibLaTeX.
pub fn EntryType::to_biblatex(self : EntryType) -> EntryType {
  match self {
    MastersThesis => Thesis
    PhdThesis => Thesis
    TechReport => Report
    Unknown(_) => Misc
    _ => self
  }
}

///|
/// Convert into a type supported by BibTeX.
pub fn EntryType::to_bibtex(self : EntryType) -> EntryType {
  match self {
    MvBook => Book
    BookInBook => InBook
    SuppBook => InBook
    Periodical => Misc
    SuppPeriodical => Article
    Collection => Proceedings
    MvCollection => Proceedings
    SuppCollection => InCollection
    Reference => Misc
    MvReference => Misc
    InReference => InCollection
    MvProceedings => Proceedings
    Report => TechReport
    Patent => Misc
    Thesis => PhdThesis
    Online => Misc
    Software => Misc
    Dataset => Misc
    Set => Misc
    XData => Misc
    Unknown(_) => Misc
    _ => self
  }
}

///|
/// Get the required fields for the `EntryType`.
pub fn EntryType::requirements(self : EntryType) -> Requirments {
  let mut reqs = Requirments::default()
  reqs.needs_date = true
  reqs.required.push("title")
  reqs.optional.push("note")
  reqs.optional.push("location")
  reqs.optional.push("titleadddon")
  reqs.optional.push("subtitle")
  reqs.optional.push("url")
  reqs.optional.push("urldate")
  reqs.optional.push("doi")
  reqs.optional.push("eprint")
  reqs.optional.push("eprintclass")
  reqs.optional.push("eprinttype")
  reqs.optional.push("pubstate")
  reqs.optional.push("language")
  reqs.optional.push("addendum")
  if self.is_multi_volume() {
    reqs.forbidden.push("maintitle")
    reqs.forbidden.push("mainsubtitle")
    reqs.forbidden.push("maintitleaddon")
    reqs.forbidden.push("part")
    reqs.forbidden.push("volume")
  }
  match self {
    Article => {
      reqs.required.push("journaltitle")
      ignore(reqs.optional.remove(1))
      reqs.optional.push("number")
      reqs.optional.push("series")
      reqs.optional.push("version")
      reqs.optional.push("volume")
      reqs.optional.push("annotator")
      reqs.optional.push("commentator")
      reqs.optional.push("translator")
      reqs.optional.push("origlanguage")
      reqs.optional.push("journalsubtitle")
      reqs.optional.push("issue")
      reqs.optional.push("issuetitle")
      reqs.optional.push("issuesubtitle")
      reqs.optional.push("eid")
      reqs.optional.push("issn")
      reqs.page_chapter_field = PagesChapterMode::PagesOptional
      reqs.author_eds_field = AuthorMode::AuthorRequiredEditorOptional
    }
    Book => {
      reqs.required.push("publisher")
      reqs.optional.push("edition")
      reqs.optional.push("number")
      reqs.optional.push("series")
      reqs.optional.push("part")
      reqs.optional.push("volume")
      reqs.optional.push("volumes")
      reqs.optional.push("annotator")
      reqs.optional.push("commentator")
      reqs.optional.push("translator")
      reqs.optional.push("origlanguage")
      reqs.optional.push("afterword")
      reqs.optional.push("foreword")
      reqs.optional.push("introduction")
      reqs.optional.push("maintitle")
      reqs.optional.push("mainsubtitle")
      reqs.optional.push("maintitleaddon")
      reqs.optional.push("isbn")
      reqs.optional.push("pagetotal")
      reqs.author_eds_field = AuthorMode::OneRequired
      reqs.page_chapter_field = PagesChapterMode::BothOptional
    }
    Booklet => {
      reqs.optional.push("howpublished")
      reqs.optional.push("type")
      reqs.optional.push("pagetotal")
      reqs.author_eds_field = AuthorMode::OneRequired
      reqs.page_chapter_field = PagesChapterMode::BothOptional
      reqs.needs_date = false
    }
    InBook => {
      reqs.required.push("publisher")
      reqs.required.push("booktitle")
      reqs.optional.push("bookauthor")
      reqs.optional.push("volume")
      reqs.optional.push("volumes")
      reqs.optional.push("part")
      reqs.optional.push("type")
      reqs.optional.push("series")
      reqs.optional.push("number")
      reqs.optional.push("edition")
      reqs.optional.push("annotator")
      reqs.optional.push("commentator")
      reqs.optional.push("translator")
      reqs.optional.push("origlanguage")
      reqs.optional.push("afterword")
      reqs.optional.push("foreword")
      reqs.optional.push("introduction")
      reqs.optional.push("maintitle")
      reqs.optional.push("mainsubtitle")
      reqs.optional.push("maintitleaddon")
      reqs.optional.push("booksubtitle")
      reqs.optional.push("booktitleaddon")
      reqs.optional.push("isbn")
      reqs.forbidden.push("pagetotal")
      reqs.author_eds_field = AuthorMode::OneRequired
      reqs.page_chapter_field = PagesChapterMode::OneRequired
    }
    InCollection => {
      reqs.required.push("publisher")
      reqs.required.push("booktitle")
      reqs.optional.push("volume")
      reqs.optional.push("type")
      reqs.optional.push("series")
      reqs.optional.push("number")
      reqs.optional.push("edition")
      reqs.optional.push("annotator")
      reqs.optional.push("commentator")
      reqs.optional.push("translator")
      reqs.optional.push("origlanguage")
      reqs.optional.push("afterword")
      reqs.optional.push("foreword")
      reqs.optional.push("introduction")
      reqs.optional.push("maintitle")
      reqs.optional.push("mainsubtitle")
      reqs.optional.push("maintitleaddon")
      reqs.optional.push("booksubtitle")
      reqs.optional.push("booktitleaddon")
      reqs.optional.push("part")
      reqs.optional.push("volumes")
      reqs.optional.push("isbn")
      reqs.forbidden.push("pagetotal")
      reqs.author_eds_field = AuthorMode::BothRequired
      reqs.page_chapter_field = PagesChapterMode::BothOptional
    }
    InProceedings => {
      reqs.required.push("booktitle")
      reqs.optional.push("number")
      reqs.optional.push("organization")
      reqs.optional.push("series")
      reqs.optional.push("volume")
      reqs.optional.push("volumes")
      reqs.optional.push("part")
      reqs.optional.push("publisher")
      reqs.optional.push("maintitle")
      reqs.optional.push("mainsubtitle")
      reqs.optional.push("maintitleaddon")
      reqs.optional.push("booksubtitle")
      reqs.optional.push("booktitleaddon")
      reqs.optional.push("eventtitle")
      reqs.optional.push("eventsubtitle")
      reqs.optional.push("eventtitleaddon")
      reqs.optional.push("venue")
      reqs.optional.push("isbn")
      reqs.optional.push("publisher")
      reqs.forbidden.push("pagetotal")
      reqs.page_chapter_field = PagesChapterMode::BothOptional
      reqs.author_eds_field = AuthorMode::BothRequired
    }
    Manual => {
      reqs.optional.push("edition")
      reqs.optional.push("organization")
      reqs.optional.push("series")
      reqs.optional.push("version")
      reqs.optional.push("isbn")
      reqs.optional.push("publisher")
      reqs.optional.push("type")
      reqs.optional.push("pagetotal")
      reqs.author_eds_field = AuthorMode::OneRequired
      reqs.page_chapter_field = PagesChapterMode::BothOptional
      reqs.needs_date = false
    }
    MastersThesis => {
      reqs.required.push("school")
      reqs.optional.push("type")
      reqs.author_eds_field = AuthorMode::AuthorRequired
    }
    Misc => {
      ignore(reqs.optional.remove(1))
      reqs.optional.push("howpublished")
      reqs.optional.push("organization")
      reqs.optional.push("type")
      reqs.author_eds_field = AuthorMode::OneRequired
      reqs.needs_date = false
    }
    Proceedings => {
      reqs.optional.push("number")
      reqs.optional.push("organization")
      reqs.optional.push("series")
      reqs.optional.push("volume")
      reqs.optional.push("volumes")
      reqs.optional.push("part")
      reqs.optional.push("publisher")
      reqs.optional.push("maintitle")
      reqs.optional.push("mainsubtitle")
      reqs.optional.push("maintitleaddon")
      reqs.optional.push("isbn")
      reqs.optional.push("publisher")
      reqs.optional.push("pagetotal")
      reqs.author_eds_field = AuthorMode::EditorRequiredAuthorForbidden
      reqs.page_chapter_field = PagesChapterMode::BothOptional
    }
    TechReport => {
      reqs.required.push("institution")
      reqs.optional.push("number")
      reqs.optional.push("type")
    }
    Unpublished => {
      reqs.required.push("note")
      ignore(reqs.optional.remove(1))
      ignore(reqs.optional.remove(0))
      reqs.optional.push("isbn")
      reqs.optional.push("howpublished")
      reqs.needs_date = false
    }
    MvBook => {
      reqs.optional.push("annotator")
      reqs.optional.push("commentator")
      reqs.optional.push("translator")
      reqs.optional.push("origlanguage")
      reqs.optional.push("afterword")
      reqs.optional.push("foreword")
      reqs.optional.push("introduction")
      reqs.optional.push("edition")
      reqs.optional.push("number")
      reqs.optional.push("series")
      reqs.optional.push("volumes")
      reqs.optional.push("isbn")
      reqs.optional.push("publisher")
      reqs.optional.push("pagetotal")
      reqs.page_chapter_field = PagesChapterMode::BothOptional
      reqs.author_eds_field = AuthorMode::AuthorRequiredEditorOptional
    }
    Periodical => {
      reqs.optional.push("issue")
      reqs.optional.push("issuetitle")
      reqs.optional.push("issuesubtitle")
      reqs.optional.push("number")
      reqs.optional.push("series")
      reqs.optional.push("volume")
      reqs.optional.push("issn")
      reqs.author_eds_field = AuthorMode::EditorRequiredAuthorForbidden
    }
    Collection => {
      reqs.optional.push("annotator")
      reqs.optional.push("commentator")
      reqs.optional.push("translator")
      reqs.optional.push("origlanguage")
      reqs.optional.push("afterword")
      reqs.optional.push("foreword")
      reqs.optional.push("introduction")
      reqs.optional.push("maintitle")
      reqs.optional.push("mainsubtitle")
      reqs.optional.push("maintitleaddon")
      reqs.optional.push("edition")
      reqs.optional.push("number")
      reqs.optional.push("series")
      reqs.optional.push("part")
      reqs.optional.push("volume")
      reqs.optional.push("volumes")
      reqs.optional.push("isbn")
      reqs.optional.push("publisher")
      reqs.optional.push("pagetotal")
      reqs.author_eds_field = AuthorMode::EditorRequiredAuthorForbidden
      reqs.page_chapter_field = PagesChapterMode::BothOptional
    }
    MvCollection => {
      reqs.optional.push("annotator")
      reqs.optional.push("commentator")
      reqs.optional.push("translator")
      reqs.optional.push("origlanguage")
      reqs.optional.push("afterword")
      reqs.optional.push("foreword")
      reqs.optional.push("introduction")
      reqs.optional.push("edition")
      reqs.optional.push("number")
      reqs.optional.push("series")
      reqs.optional.push("volumes")
      reqs.optional.push("isbn")
      reqs.optional.push("publisher")
      reqs.optional.push("pagetotal")
      reqs.author_eds_field = AuthorMode::EditorRequiredAuthorForbidden
      reqs.page_chapter_field = PagesChapterMode::BothForbidden
    }
    MvProceedings => {
      reqs.optional.push("number")
      reqs.optional.push("series")
      reqs.optional.push("volumes")
      reqs.optional.push("publisher")
      reqs.optional.push("organization")
      reqs.optional.push("pagetotal")
      reqs.author_eds_field = AuthorMode::EditorRequiredAuthorForbidden
      reqs.page_chapter_field = PagesChapterMode::BothForbidden
    }
    Report => {
      reqs.required.push("institution")
      reqs.required.push("type")
      reqs.optional.push("number")
      reqs.optional.push("version")
      reqs.optional.push("isrn")
      reqs.optional.push("pagetotal")
      reqs.page_chapter_field = PagesChapterMode::BothOptional
    }
    Patent => {
      reqs.required.push("number")
      reqs.optional.push("holder")
      reqs.optional.push("type")
    }
    Thesis => {
      reqs.optional.push("isbn")
      reqs.required.push("institution")
      reqs.required.push("type")
      reqs.optional.push("pagetotal")
      reqs.page_chapter_field = PagesChapterMode::BothOptional
    }
    Online => {
      reqs.required.push("url")
      ignore(reqs.optional.remove(9))
      ignore(reqs.optional.remove(8))
      ignore(reqs.optional.remove(7))
      ignore(reqs.optional.remove(6))
      ignore(reqs.optional.remove(4))
      ignore(reqs.optional.remove(1))
      reqs.optional.push("organization")
      reqs.author_eds_field = AuthorMode::OneRequired
    }
    Dataset => {
      reqs.optional.push("edition")
      reqs.optional.push("type")
      reqs.optional.push("series")
      reqs.optional.push("number")
      reqs.optional.push("version")
      reqs.optional.push("organization")
      reqs.optional.push("publisher")
      reqs.author_eds_field = AuthorMode::OneRequired
    }
    PhdThesis => reqs = MastersThesis.requirements()
    SuppPeriodical => reqs = Article.requirements()
    BookInBook => reqs = InBook.requirements()
    SuppBook => reqs = InBook.requirements()
    SuppCollection => reqs = InCollection.requirements()
    Reference => reqs = Collection.requirements()
    MvReference => reqs = MvCollection.requirements()
    InReference => reqs = InCollection.requirements()
    Software => reqs = Misc.requirements()
    Set => {
      reqs.optional.clear()
      reqs.required.clear()
      reqs.required.push("entryset")
      reqs.author_eds_field = AuthorMode::NoneRequired
      reqs.needs_date = false
    }
    XData => {
      reqs.optional.clear()
      reqs.required.clear()
      reqs.author_eds_field = AuthorMode::NoneRequired
      reqs.needs_date = false
    }
    Unknown(_) => reqs = MvCollection.requirements()
  }
  reqs
}

///|
/// Whether a field with this key should be parsed with commands and most
/// escapes turned off.
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

///|
test "test_show" {
  assert_eq(EntryType::Unknown("custom").to_string(), "Unknown(custom)")
  assert_eq(EntryType::Article.to_string(), "article")
  assert_eq(EntryType::Book.to_string(), "book")
  assert_eq(EntryType::Booklet.to_string(), "booklet")
  assert_eq(EntryType::InBook.to_string(), "inbook")
  assert_eq(EntryType::InCollection.to_string(), "incollection")
  assert_eq(EntryType::InProceedings.to_string(), "inproceedings")
  assert_eq(EntryType::Manual.to_string(), "manual")
  assert_eq(EntryType::MastersThesis.to_string(), "mastersthesis")
  assert_eq(EntryType::PhdThesis.to_string(), "phdthesis")
  assert_eq(EntryType::Misc.to_string(), "misc")
  assert_eq(EntryType::Proceedings.to_string(), "proceedings")
  assert_eq(EntryType::TechReport.to_string(), "techreport")
  assert_eq(EntryType::Unpublished.to_string(), "unpublished")
  assert_eq(EntryType::MvBook.to_string(), "mvbook")
  assert_eq(EntryType::BookInBook.to_string(), "bookinbook")
  assert_eq(EntryType::SuppBook.to_string(), "suppbook")
  assert_eq(EntryType::Periodical.to_string(), "periodical")
  assert_eq(EntryType::SuppPeriodical.to_string(), "suppperiodical")
  assert_eq(EntryType::Collection.to_string(), "collection")
  assert_eq(EntryType::MvCollection.to_string(), "mvcollection")
  assert_eq(EntryType::SuppCollection.to_string(), "suppcollection")
  assert_eq(EntryType::Reference.to_string(), "reference")
  assert_eq(EntryType::MvReference.to_string(), "mvreference")
  assert_eq(EntryType::InReference.to_string(), "inreference")
  assert_eq(EntryType::MvProceedings.to_string(), "mvproceedings")
  assert_eq(EntryType::Report.to_string(), "report")
  assert_eq(EntryType::Patent.to_string(), "patent")
  assert_eq(EntryType::Thesis.to_string(), "thesis")
  assert_eq(EntryType::Online.to_string(), "online")
  assert_eq(EntryType::Software.to_string(), "software")
  assert_eq(EntryType::Dataset.to_string(), "dataset")
  assert_eq(EntryType::Set.to_string(), "set")
  assert_eq(EntryType::XData.to_string(), "xdata")
  let s = StringBuilder::new()
  let entry = XData
  entry.output(s)
  assert_eq(s.to_string(), "xdata\n")
}

///|
test "test_possible" {
  assert_eq(AuthorMode::possible(AuthorRequired), ["author"])
  assert_eq(AuthorMode::possible(EditorRequiredAuthorForbidden), ["editor"])
}

///|
test "test_entry_type" {
  let default_option = [
    "note", "location", "titleadddon", "subtitle", "url", "urldate", "doi", "eprint",
    "eprintclass", "eprinttype", "pubstate", "language", "addendum",
  ]
  let entry = EntryType::new("booklet")
  assert_eq(entry, Booklet)
  assert_eq(
    EntryType::requirements(entry).optional,
    default_option + ["howpublished", "type", "pagetotal"],
  )
  let entry = EntryType::new("inbook")
  assert_eq(entry, InBook)
  assert_eq(
    EntryType::requirements(entry).optional,
    default_option +
    [
      "bookauthor", "volume", "volumes", "part", "type", "series", "number", "edition",
      "annotator", "commentator", "translator", "origlanguage", "afterword", "foreword",
      "introduction", "maintitle", "mainsubtitle", "maintitleaddon", "booksubtitle",
      "booktitleaddon", "isbn",
    ],
  )
  let entry = EntryType::new("mastersthesis")
  assert_eq(entry, MastersThesis)
  assert_eq(entry.to_biblatex(), Thesis)
  let entry = EntryType::new("phdthesis")
  assert_eq(entry, PhdThesis)
  assert_eq(entry.to_biblatex(), Thesis)
  let entry = EntryType::new("proceedings")
  assert_eq(entry, Proceedings)
  let entry = EntryType::new("unpublished")
  assert_eq(entry, Unpublished)
  let entry = EntryType::new("mvbook")
  assert_eq(entry, MvBook)
  assert_eq(entry.to_bibtex(), Book)
  let entry = EntryType::new("bookinbook")
  assert_eq(entry, BookInBook)
  assert_eq(entry.to_bibtex(), InBook)
  let entry = EntryType::new("suppbook")
  assert_eq(entry, SuppBook)
  assert_eq(entry.to_bibtex(), InBook)
  let entry = EntryType::new("suppperiodical")
  assert_eq(entry, SuppPeriodical)
  assert_eq(entry.to_bibtex(), Article)
  let entry = EntryType::new("collection")
  assert_eq(entry, Collection)
  assert_true(entry.is_collection())
  assert_eq(entry.to_bibtex(), Proceedings)
  let entry = EntryType::new("mvcollection")
  assert_eq(entry, MvCollection)
  assert_eq(entry.to_bibtex(), Proceedings)
  let entry = EntryType::new("suppcollection")
  assert_eq(entry, SuppCollection)
  assert_eq(entry.to_bibtex(), InCollection)
  let entry = EntryType::new("reference")
  assert_eq(entry, Reference)
  let entry = EntryType::new("mvreference")
  assert_eq(entry, MvReference)
  let entry = EntryType::new("patent")
  assert_eq(entry, Patent)
  assert_eq(entry.to_bibtex(), Misc)
  let entry = EntryType::new("software")
  assert_eq(entry, Software)
  let entry = EntryType::new("dataset")
  assert_eq(entry, Dataset)
  assert_eq(entry.to_bibtex(), Misc)
  let entry = EntryType::new("set")
  assert_eq(entry, Set)
  assert_eq(entry.to_bibtex(), Misc)
  let entry = EntryType::new("conference")
  assert_eq(entry, InProceedings)
  let entry = EntryType::new("electronic")
  assert_eq(entry, Online)
  assert_eq(entry.to_bibtex(), Misc)
  let entry = EntryType::new("techreport")
  assert_eq(entry, TechReport)
  assert_eq(entry.to_biblatex(), Report)
  let entry = EntryType::new("unknown")
  assert_eq(entry.to_biblatex(), Misc)
  assert_eq(entry.to_bibtex(), Misc)
  ///
  assert_eq(EntryType::to_bibtex(Periodical), Misc)
  assert_eq(EntryType::to_bibtex(Reference), Misc)
  assert_eq(EntryType::to_bibtex(MvReference), Misc)
  assert_eq(EntryType::to_bibtex(InReference), InCollection)
  assert_eq(EntryType::to_bibtex(MvProceedings), Proceedings)
  assert_eq(EntryType::to_bibtex(Report), TechReport)
  assert_eq(EntryType::to_bibtex(Software), Misc)
  assert_eq(EntryType::to_bibtex(XData), Misc)
  assert_eq(EntryType::to_bibtex(InBook), InBook)
  ///
  assert_eq(
    EntryType::requirements(InCollection).optional,
    default_option +
    [
      "volume", "type", "series", "number", "edition", "annotator", "commentator",
      "translator", "origlanguage", "afterword", "foreword", "introduction", "maintitle",
      "mainsubtitle", "maintitleaddon", "booksubtitle", "booktitleaddon", "part",
      "volumes", "isbn",
    ],
  )
  assert_eq(
    EntryType::requirements(InProceedings).optional,
    default_option +
    [
      "number", "organization", "series", "volume", "volumes", "part", "publisher",
      "maintitle", "mainsubtitle", "maintitleaddon", "booksubtitle", "booktitleaddon",
      "eventtitle", "eventsubtitle", "eventtitleaddon", "venue", "isbn", "publisher",
    ],
  )
  assert_eq(
    EntryType::requirements(Manual).optional,
    default_option +
    [
      "edition", "organization", "series", "version", "isbn", "publisher", "type",
      "pagetotal",
    ],
  )
  assert_eq(
    EntryType::requirements(MastersThesis).optional,
    default_option + ["type"],
  )
  assert_eq(
    EntryType::requirements(Proceedings).optional,
    default_option +
    [
      "number", "organization", "series", "volume", "volumes", "part", "publisher",
      "maintitle", "mainsubtitle", "maintitleaddon", "isbn", "publisher", "pagetotal",
    ],
  )
  assert_eq(
    EntryType::requirements(TechReport).optional,
    default_option + ["number", "type"],
  )
  assert_eq(EntryType::requirements(Unpublished).optional, [
    "titleadddon", "subtitle", "url", "urldate", "doi", "eprint", "eprintclass",
    "eprinttype", "pubstate", "language", "addendum", "isbn", "howpublished",
  ])
  assert_eq(
    EntryType::requirements(MvBook).optional,
    default_option +
    [
      "annotator", "commentator", "translator", "origlanguage", "afterword", "foreword",
      "introduction", "edition", "number", "series", "volumes", "isbn", "publisher",
      "pagetotal",
    ],
  )
  assert_eq(
    EntryType::requirements(Periodical).optional,
    default_option +
    [
      "issue", "issuetitle", "issuesubtitle", "number", "series", "volume", "issn",
    ],
  )
  assert_eq(
    EntryType::requirements(Collection).optional,
    default_option +
    [
      "annotator", "commentator", "translator", "origlanguage", "afterword", "foreword",
      "introduction", "maintitle", "mainsubtitle", "maintitleaddon", "edition", "number",
      "series", "part", "volume", "volumes", "isbn", "publisher", "pagetotal",
    ],
  )
  assert_eq(
    EntryType::requirements(MvCollection).optional,
    default_option +
    [
      "annotator", "commentator", "translator", "origlanguage", "afterword", "foreword",
      "introduction", "edition", "number", "series", "volumes", "isbn", "publisher",
      "pagetotal",
    ],
  )
  assert_eq(
    EntryType::requirements(Report).optional,
    default_option + ["number", "version", "isrn", "pagetotal"],
  )
  assert_eq(
    EntryType::requirements(Patent).optional,
    default_option + ["holder", "type"],
  )
  assert_eq(EntryType::requirements(Online).optional, [
    "note", "titleadddon", "subtitle", "urldate", "pubstate", "language", "addendum",
    "organization",
  ])
  assert_eq(
    EntryType::requirements(Dataset).optional,
    default_option +
    [
      "edition", "type", "series", "number", "version", "organization", "publisher",
    ],
  )
  ///
  assert_eq(
    EntryType::requirements(PhdThesis),
    EntryType::requirements(MastersThesis),
  )
  assert_eq(
    EntryType::requirements(SuppPeriodical),
    EntryType::requirements(Article),
  )
  assert_eq(
    EntryType::requirements(BookInBook),
    EntryType::requirements(InBook),
  )
  assert_eq(EntryType::requirements(SuppBook), EntryType::requirements(InBook))
  assert_eq(
    EntryType::requirements(SuppCollection),
    EntryType::requirements(InCollection),
  )
  assert_eq(
    EntryType::requirements(Reference),
    EntryType::requirements(Collection),
  )
  assert_eq(
    EntryType::requirements(MvReference),
    EntryType::requirements(MvCollection),
  )
  assert_eq(
    EntryType::requirements(InReference),
    EntryType::requirements(InCollection),
  )
  assert_eq(EntryType::requirements(Software), EntryType::requirements(Misc))
  assert_eq(EntryType::requirements(Set).optional, [])
  assert_eq(EntryType::requirements(Set).required, ["entryset"])
  assert_eq(
    EntryType::requirements(Unknown("unknown")),
    EntryType::requirements(MvCollection),
  )
}
