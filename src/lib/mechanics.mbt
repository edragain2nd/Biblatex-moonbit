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
} derive(Show, Eq, Compare)

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
}

///|
impl Default for AuthorMode with default() {
  AuthorRequired
}

///|
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
}

///|
impl Default for PagesChapterMode with default() {
  None
}

///|
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
} derive(Default)

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
