///|
typealias @types.(
  Person,
  ArrayPerson,
  PermissiveType,
  ArrayChunks,
  ArrayRange,
  Range,
  Date,
  EditorType,
  Pagination,
  Language,
  Gender
)

///|
/// Retrieves the author(s) of the entry as an array of Person.
pub fn Entry::author(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("author")
  if res is None {
    return Err(Missing("author"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the author(s) of the entry.
pub fn Entry::set_author(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("author", item.to_chunks())
}

///|
/// Retrieves the book_title of the entry as Chunks.
pub fn Entry::book_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("booktitle")
  if res is None {
    return Err(Missing("booktitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the book_title of the entry.
pub fn Entry::set_book_title(self : Entry, item : Chunks) -> Unit {
  self.set("booktitle", item)
}

///|
/// Retrieves the chapter of the entry as Chunks.
pub fn Entry::chapter(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("chapter")
  if res is None {
    return Err(Missing("chapter"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the chapter of the entry.
pub fn Entry::set_chapter(self : Entry, item : Chunks) -> Unit {
  self.set("chapter", item)
}

///|
/// Retrieves the edition of the entry as PermissiveType.
pub fn Entry::edition(
  self : Entry,
) -> Result[PermissiveType[Int64], RetrievalError] {
  let res = self.get("edition")
  if res is None {
    return Err(Missing("edition"))
  }
  let res : PermissiveType[Int64] = PermissiveType::from_chunks(res.unwrap())
  Ok(res)
}

///|
/// Sets or replaces the edition of the entry.
pub fn Entry::set_edition(self : Entry, item : PermissiveType[Int64]) -> Unit {
  self.set("edition", PermissiveType::to_chunks(item))
}

///|
/// Retrieves the how_published of the entry as Chunks.
pub fn Entry::how_published(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("howpublished")
  if res is None {
    return Err(Missing("howpublished"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the how_published of the entry.
pub fn Entry::set_how_published(self : Entry, item : Chunks) -> Unit {
  self.set("howpublished", item)
}

///|
/// Retrieves the note of the entry as Chunks.
pub fn Entry::note(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("note")
  if res is None {
    return Err(Missing("note"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the note of the entry.
pub fn Entry::set_note(self : Entry, item : Chunks) -> Unit {
  self.set("note", item)
}

///|
/// Retrieves the number of the entry as Chunks.
pub fn Entry::number(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("number")
  if res is None {
    return Err(Missing("number"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the number of the entry.
pub fn Entry::set_number(self : Entry, item : Chunks) -> Unit {
  self.set("number", item)
}

///|
/// /// Retrieves the organization of the entry as an array of Chunks.
pub fn Entry::organization(
  self : Entry,
) -> Result[Array[Chunks], RetrievalError] {
  let res = self.get("organization")
  if res is None {
    return Err(Missing("organization"))
  }
  // ArrayChunks's parse_chunks version never throws err 
  let res : ArrayChunks = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the organization of the entry.
pub fn Entry::set_organization(self : Entry, item : Array[Chunks]) -> Unit {
  let item : ArrayChunks = ArrayChunks(item)
  self.set("organization", item.to_chunks())
}

///|
/// Retrieves the pages of the entry as a PermissiveType array of Range.
pub fn Entry::pages(
  self : Entry,
) -> Result[PermissiveType[Array[Range]], RetrievalError] {
  let res = self.get("pages")
  if res is None {
    return Err(Missing("pages"))
  }
  let res : PermissiveType[ArrayRange] = PermissiveType::from_chunks(
    res.unwrap(),
  )
  let res : PermissiveType[Array[Range]] = match res {
    Typed(array_range) => Typed(array_range.0)
    Chunks(chunks) => Chunks(chunks)
  }
  Ok(res)
}

///|
/// Sets or replaces the pages of the entry.
pub fn Entry::set_pages(
  self : Entry,
  item : PermissiveType[Array[Range]],
) -> Unit {
  let item : PermissiveType[ArrayRange] = match item {
    Typed(a) => {
      let a : ArrayRange = ArrayRange(a)
      Typed(a)
    }
    Chunks(chunks) => Chunks(chunks)
  }
  self.set("pages", PermissiveType::to_chunks(item))
}

///|
/// Retrieves the publisher of the entry as an array of Chunks.
pub fn Entry::publisher(self : Entry) -> Result[Array[Chunks], RetrievalError] {
  let res = self.get("publisher")
  if res is None {
    return Err(Missing("publisher"))
  }
  // ArrayChunks's parse_chunks version never throws err 
  let res : ArrayChunks = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the publisher of the entry.
pub fn Entry::set_publisher(self : Entry, item : Array[Chunks]) -> Unit {
  let item : ArrayChunks = ArrayChunks(item)
  self.set("publisher", item.to_chunks())
}

///|
/// Retrieves the series of the entry as Chunks.
pub fn Entry::series(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("series")
  if res is None {
    return Err(Missing("series"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the series of the entry.
pub fn Entry::set_series(self : Entry, item : Chunks) -> Unit {
  self.set("series", item)
}

///|
/// Retrieves the title of the entry as Chunks.
pub fn Entry::title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("title")
  if res is None {
    return Err(Missing("title"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the title of the entry.
pub fn Entry::set_title(self : Entry, item : Chunks) -> Unit {
  self.set("title", item)
}

///|
/// Retrieves the type of the entry as String.
pub fn Entry::type_(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("type")
  if res is None {
    return Err(Missing("type"))
  }
  // String's parse_chunks version never throws err 
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the type of the entry.
pub fn Entry::set_type_(self : Entry, item : String) -> Unit {
  self.set("type", Type::to_chunks(item))
}

///|
/// Retrieves the volume of the entry as PermissiveType.
pub fn Entry::volume(
  self : Entry,
) -> Result[PermissiveType[Int64], RetrievalError] {
  let res = self.get("volume")
  if res is None {
    return Err(Missing("volume"))
  }
  let res : PermissiveType[Int64] = PermissiveType::from_chunks(res.unwrap())
  Ok(res)
}

///|
/// Sets or replaces the volume of the entry.
pub fn Entry::set_volume(self : Entry, item : PermissiveType[Int64]) -> Unit {
  self.set("volume", PermissiveType::to_chunks(item))
}

///|
/// Retrieves the address of the entry as Chunks.
pub fn Entry::address(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("address")
  if res is None {
    let res = self.get("location")
    if res is None {
      Err(Missing("address"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the address of the entry.
pub fn Entry::set_address(self : Entry, item : Chunks) -> Unit {
  self.set("address", item)
}

///|
/// Retrieves the location of the entry as Chunks.
pub fn Entry::location(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("location")
  if res is None {
    let res = self.get("address")
    if res is None {
      Err(Missing("location"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the location of the entry.
pub fn Entry::set_location(self : Entry, item : Chunks) -> Unit {
  self.set("location", item)
}

///|
/// Retrieves the annotation of the entry as Chunks.
pub fn Entry::annotation(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("annotation")
  if res is None {
    let res = self.get("annote")
    if res is None {
      Err(Missing("annotation"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the annotation of the entry.
pub fn Entry::set_annotation(self : Entry, item : Chunks) -> Unit {
  self.set("annotation", item)
}

///|
/// Retrieves the eprint_type of the entry as Chunks.
pub fn Entry::eprint_type(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eprinttype")
  if res is None {
    let res = self.get("archiveprefix")
    if res is None {
      Err(Missing("eprinttype"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the eprint_type of the entry.
pub fn Entry::set_eprint_type(self : Entry, item : Chunks) -> Unit {
  self.set("eprinttype", item)
}

///|
/// Retrieves the eprint_class of the entry as Chunks.
pub fn Entry::eprint_class(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eprintclass")
  if res is None {
    let res = self.get("primaryclass")
    if res is None {
      Err(Missing("eprintclass"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the eprint_class of the entry.
pub fn Entry::set_eprint_class(self : Entry, item : Chunks) -> Unit {
  self.set("eprintclass", item)
}

///|
/// Retrieves the journal of the entry as Chunks.
pub fn Entry::journal(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("journal")
  if res is None {
    let res = self.get("journaltitle")
    if res is None {
      Err(Missing("journal"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the journal of the entry.
pub fn Entry::set_journal(self : Entry, item : Chunks) -> Unit {
  self.set("journal", item)
}

///|
/// Retrieves the journal_title of the entry as Chunks.
pub fn Entry::journal_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("journaltitle")
  if res is None {
    let res = self.get("journal")
    if res is None {
      Err(Missing("journaltitle"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the journal_title of the entry.
pub fn Entry::set_journal_title(self : Entry, item : Chunks) -> Unit {
  self.set("journaltitle", item)
}

///|
/// Retrieves the sort_key of the entry as String.
pub fn Entry::sort_key(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("key")
  if res is None {
    let res = self.get("sortkey")
    if res is None {
      Err(Missing("key"))
    } else {
      // String's parse_chunks version never throws err 
      let res : String = parse_chunks(res.unwrap()) catch {
        err => return Err(TypeError(err))
      }
      Ok(res)
    }
  } else {
    // String's parse_chunks version never throws err 
    let res : String = parse_chunks(res.unwrap()) catch {
      err => return Err(TypeError(err))
    }
    Ok(res)
  }
}

///|
/// Sets or replaces the sort_key of the entry.
pub fn Entry::set_sort_key(self : Entry, item : String) -> Unit {
  self.set("key", Type::to_chunks(item))
}

///|
/// Retrieves the file of the entry as String.
pub fn Entry::file(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("file")
  if res is None {
    let res = self.get("pdf")
    if res is None {
      Err(Missing("file"))
    } else {
      // String's parse_chunks version never throws err 
      let res : String = parse_chunks(res.unwrap()) catch {
        err => return Err(TypeError(err))
      }
      Ok(res)
    }
  } else {
    // String's parse_chunks version never throws err 
    let res : String = parse_chunks(res.unwrap()) catch {
      err => return Err(TypeError(err))
    }
    Ok(res)
  }
}

///|
/// Sets or replaces the file of the entry.
pub fn Entry::set_file(self : Entry, item : String) -> Unit {
  self.set("file", Type::to_chunks(item))
}

///|
/// Retrieves the school of the entry as Chunks.
pub fn Entry::school(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("school")
  if res is None {
    let res = self.get("institution")
    if res is None {
      Err(Missing("school"))
    } else {
      Ok(res.unwrap())
    }
  } else {
    Ok(res.unwrap())
  }
}

///|
/// Sets or replaces the school of the entry.
pub fn Entry::set_school(self : Entry, item : Chunks) -> Unit {
  self.set("school", item)
}

///|
/// Retrieves the institution of the entry as String.
pub fn Entry::institution(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("institution")
  if res is None {
    let res = self.get("school")
    if res is None {
      Err(Missing("institution"))
    } else {
      // String's parse_chunks version never throws err 
      let res : String = parse_chunks(res.unwrap()) catch {
        err => return Err(TypeError(err))
      }
      Ok(res)
    }
  } else {
    // String's parse_chunks version never throws err 
    let res : String = parse_chunks(res.unwrap()) catch {
      err => return Err(TypeError(err))
    }
    Ok(res)
  }
}

///|
/// Sets or replaces the institution of the entry.
pub fn Entry::set_institution(self : Entry, item : String) -> Unit {
  self.set("institution", Type::to_chunks(item))
}

///|
/// Retrieves the date of the entry as PermissiveType[Date].
pub fn Entry::date(
  self : Entry,
) -> Result[PermissiveType[Date], RetrievalError] {
  let res = self.get("date")
  if res is Some(chunks) {
    let date : PermissiveType[Date] = PermissiveType::from_chunks(chunks)
    Ok(date)
  } else {
    let year = self.get("year")
    if year is None {
      return Err(Missing("year"))
    }
    let year = year.unwrap()
    let date = Date::parse_three_fields(
      year,
      self.get("month"),
      self.get("day"),
    ) catch {
      err => return Err(TypeError(err))
    }
    Ok(Typed(date))
  }
}

///|
/// Sets or replaces the date of the entry.
pub fn Entry::set_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("date", PermissiveType::to_chunks(item))
  ignore(self.remove("year"))
  ignore(self.remove("month"))
  ignore(self.remove("day"))
}

///|
/// Retrieves the eventdate of the entry as PermissiveType[Date].
pub fn Entry::event_date(
  self : Entry,
) -> Result[PermissiveType[Date], RetrievalError] {
  let res = self.get("eventdate")
  if res is Some(chunks) {
    let date : PermissiveType[Date] = PermissiveType::from_chunks(chunks)
    Ok(date)
  } else {
    let year = self.get("eventyear")
    if year is None {
      return Err(Missing("year"))
    }
    let year = year.unwrap()
    let date = Date::parse_three_fields(
      year,
      self.get("eventmonth"),
      self.get("eventday"),
    ) catch {
      err => return Err(TypeError(err))
    }
    Ok(Typed(date))
  }
}

///|
/// Sets or replaces the event_date of the entry.
pub fn Entry::set_event_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("eventdate", PermissiveType::to_chunks(item))
  ignore(self.remove("eventyear"))
  ignore(self.remove("eventmonth"))
  ignore(self.remove("eventday"))
}

///|
/// Retrieves the orig_date of the entry as PermissiveType[Date].
pub fn Entry::orig_date(
  self : Entry,
) -> Result[PermissiveType[Date], RetrievalError] {
  let res = self.get("origdate")
  if res is Some(chunks) {
    let date : PermissiveType[Date] = PermissiveType::from_chunks(chunks)
    Ok(date)
  } else {
    let year = self.get("origyear")
    if year is None {
      return Err(Missing("year"))
    }
    let year = year.unwrap()
    let date = Date::parse_three_fields(
      year,
      self.get("origmonth"),
      self.get("origday"),
    ) catch {
      err => return Err(TypeError(err))
    }
    Ok(Typed(date))
  }
}

///|
/// Sets or replaces the orig_date of the entry.
pub fn Entry::set_orig_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("origdate", PermissiveType::to_chunks(item))
  ignore(self.remove("origyear"))
  ignore(self.remove("origmonth"))
  ignore(self.remove("origday"))
}

///|
/// Retrieves the url_date of the entry as PermissiveType[Date].
pub fn Entry::url_date(
  self : Entry,
) -> Result[PermissiveType[Date], RetrievalError] {
  let res = self.get("urldate")
  if res is Some(chunks) {
    let date : PermissiveType[Date] = PermissiveType::from_chunks(chunks)
    Ok(date)
  } else {
    let year = self.get("urlyear")
    if year is None {
      return Err(Missing("year"))
    }
    let year = year.unwrap()
    let date = Date::parse_three_fields(
      year,
      self.get("urlmonth"),
      self.get("urlday"),
    ) catch {
      err => return Err(TypeError(err))
    }
    Ok(Typed(date))
  }
}

///|
/// Sets or replaces the url_date of the entry.
pub fn Entry::set_url_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("urldate", PermissiveType::to_chunks(item))
  ignore(self.remove("urlyear"))
  ignore(self.remove("urlmonth"))
  ignore(self.remove("urlday"))
}

///|
/// Retrieves the editors of the entry as an nest array of Person.
pub fn Entry::editors(
  self : Entry,
) -> Result[Array[(Array[Person], EditorType)], TypeError] {
  let editors = []
  let parse = fn(
    name_field : String,
    editor_field : String,
  ) -> Unit raise TypeError {
    let array_person : Result[ArrayPerson, RetrievalError] = self.get_as(
      name_field,
    )
    let res = convert_result(array_person).unwrap_or_error()
    if res is Some(persons) {
      let chunks = self.get(editor_field)
      if chunks is None {
        editors.push((persons, EditorType::Editor))
        return
      }
      // Due to EditorType has Unknown(_)
      // it never throws error
      let editor_type : EditorType = parse_chunks(chunks.unwrap()) catch {
        err => raise err
      }
      editors.push((persons, editor_type))
    }
  }
  let _ = parse("editor", "editortype") catch { err => return Err(err) }
  let _ = parse("editora", "editoratype") catch { err => return Err(err) }
  let _ = parse("editorb", "editorbtype") catch { err => return Err(err) }
  let _ = parse("editorc", "editorctype") catch { err => return Err(err) }
  let editors = editors.map(pe => (pe.0.0, pe.1))
  Ok(editors)
}

///|
/// Retrieves the abstract of the entry as Chunks.
pub fn Entry::abstract_(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("abstract")
  if res is None {
    return Err(Missing("abstract"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the abstract of the entry.
pub fn Entry::set_abstract_(self : Entry, item : Chunks) -> Unit {
  self.set("abstract", item)
}

///|
/// Retrieves the addendum of the entry as Chunks.
pub fn Entry::addendum(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("addendum")
  if res is None {
    return Err(Missing("addendum"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the addendum of the entry.
pub fn Entry::set_addendum(self : Entry, item : Chunks) -> Unit {
  self.set("addendum", item)
}

///|
/// Retrieves the afterword of the entry as an array of Person.
pub fn Entry::afterword(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("afterword")
  if res is None {
    return Err(Missing("afterword"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the afterword of the entry.
pub fn Entry::set_afterword(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("afterword", item.to_chunks())
}

///|
/// Retrieves the annotator of the entry as an array of Person.
pub fn Entry::annotator(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("annotator")
  if res is None {
    return Err(Missing("annotator"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the annotator of the entry.
pub fn Entry::set_annotator(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("annotator", item.to_chunks())
}

///|
/// Retrieves the author_type of the entry as String.
pub fn Entry::author_type(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("authortype")
  if res is None {
    return Err(Missing("authortype"))
  }
  // String's parse_chunks version never throws err 
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the author_type of the entry.
pub fn Entry::set_author_type(self : Entry, item : String) -> Unit {
  self.set("authortype", Type::to_chunks(item))
}

///|
/// Retrieves the book_author of the entry as an array of Person.
pub fn Entry::book_author(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("bookauthor")
  if res is None {
    return Err(Missing("bookauthor"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the book_author of the entry.
pub fn Entry::set_book_author(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("bookauthor", item.to_chunks())
}

///|
/// Retrieves the book_pagination of the entry as Pagination.
pub fn Entry::book_pagination(
  self : Entry,
) -> Result[Pagination, RetrievalError] {
  let res = self.get("bookpagination")
  if res is None {
    return Err(Missing("bookpagination"))
  }
  let res : Pagination = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the book_pagination of the entry.
pub fn Entry::set_book_pagination(self : Entry, item : Pagination) -> Unit {
  self.set("bookpagination", Type::to_chunks(item))
}

///|
/// Retrieves the book_subtitle of the entry as Chunks.
pub fn Entry::book_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("booksubtitle")
  if res is None {
    return Err(Missing("booksubtitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the book_subtitle of the entry.
pub fn Entry::set_book_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("booksubtitle", item)
}

///|
/// Retrieves the book_title_addon of the entry as Chunks.
pub fn Entry::book_title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("booktitleaddon")
  if res is None {
    return Err(Missing("booktitleaddon"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the book_title_addon of the entry.
pub fn Entry::set_book_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("booktitleaddon", item)
}

///|
/// Retrieves the commentator of the entry as an array of Person.
pub fn Entry::commentator(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("commentator")
  if res is None {
    return Err(Missing("commentator"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the commentator of the entry.
pub fn Entry::set_commentator(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("commentator", item.to_chunks())
}

///|
/// Retrieves the doi of the entry as String.
pub fn Entry::doi(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("doi")
  if res is None {
    return Err(Missing("doi"))
  }
  // String's parse_chunks version never throws err 
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the doi of the entry.
pub fn Entry::set_doi(self : Entry, item : String) -> Unit {
  self.set("doi", Type::to_chunks(item))
}

///|
/// Retrieves the eid of the entry as Chunks.
pub fn Entry::eid(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eid")
  if res is None {
    return Err(Missing("eid"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the eid of the entry.
pub fn Entry::set_eid(self : Entry, item : Chunks) -> Unit {
  self.set("eid", item)
}

///|
/// Retrieves the entry_subtype of the entry as Chunks.
pub fn Entry::entry_subtype(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("entrysubtype")
  if res is None {
    return Err(Missing("entrysubtype"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the entry_subtype of the entry.
pub fn Entry::set_entry_subtype(self : Entry, item : Chunks) -> Unit {
  self.set("entrysubtype", item)
}

///|
/// Retrieves the eprint of the entry as String.
pub fn Entry::eprint(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("eprint")
  if res is None {
    return Err(Missing("eprint"))
  }
  // String's parse_chunks version never throws err 
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the eprint of the entry.
pub fn Entry::set_eprint(self : Entry, item : String) -> Unit {
  self.set("eprint", Type::to_chunks(item))
}

///|
/// Retrieves the enenttitle of the entry as Chunks.
pub fn Entry::eventtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eventtitle")
  if res is None {
    return Err(Missing("eventtitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the eventtitle of the entry.
pub fn Entry::set_eventtitle(self : Entry, item : Chunks) -> Unit {
  self.set("eventtitle", item)
}

///|
/// Retrieves the eventtitle_addon of the entry as Chunks.
pub fn Entry::eventtitle_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eventtitleaddon")
  if res is None {
    return Err(Missing("eventtitleaddon"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the eventtitle_addon of the entry.
pub fn Entry::set_eventtitle_addon(self : Entry, item : Chunks) -> Unit {
  self.set("eventtitleaddon", item)
}

///|
/// Retrieves the foreword of the entry as Chunks.
pub fn Entry::foreword(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("foreword")
  if res is None {
    return Err(Missing("foreword"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the foreword of the entry.
pub fn Entry::set_foreword(self : Entry, item : Chunks) -> Unit {
  self.set("foreword", item)
}

///|
/// Retrieves the holder of the entry as Chunks.
pub fn Entry::holder(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("holder")
  if res is None {
    return Err(Missing("holder"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the holder of the entry.
pub fn Entry::set_holder(self : Entry, item : Chunks) -> Unit {
  self.set("holder", item)
}

///|
/// Retrieves the index_title of the entry as Chunks.
pub fn Entry::index_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("indextitle")
  if res is None {
    return Err(Missing("indextitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the index_title of the entry.
pub fn Entry::set_index_title(self : Entry, item : Chunks) -> Unit {
  self.set("indextitle", item)
}

///|
/// Retrieves the introduction of the entry as an array of Person.
pub fn Entry::introduction(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("introduction")
  if res is None {
    return Err(Missing("introduction"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the introduction of the entry.
pub fn Entry::set_introduction(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("introduction", item.to_chunks())
}

///|
/// Retrieves the isan of the entry as Chunks.
pub fn Entry::isan(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("isan")
  if res is None {
    return Err(Missing("isan"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the isan of the entry.
pub fn Entry::set_isan(self : Entry, item : Chunks) -> Unit {
  self.set("isan", item)
}

///|
/// Retrieves the isbn of the entry as Chunks.
pub fn Entry::isbn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("isbn")
  if res is None {
    return Err(Missing("isbn"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the isbn of the entry.
pub fn Entry::set_isbn(self : Entry, item : Chunks) -> Unit {
  self.set("isbn", item)
}

///|
/// Retrieves the ismn of the entry as Chunks.
pub fn Entry::ismn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("ismn")
  if res is None {
    return Err(Missing("ismn"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the ismn of the entry.
pub fn Entry::set_ismn(self : Entry, item : Chunks) -> Unit {
  self.set("ismn", item)
}

///|
/// Retrieves the isrn of the entry as Chunks.
pub fn Entry::isrn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("isrn")
  if res is None {
    return Err(Missing("isrn"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the isrn of the entry.
pub fn Entry::set_isrn(self : Entry, item : Chunks) -> Unit {
  self.set("isrn", item)
}

///|
/// Retrieves the issn of the entry as Chunks.
pub fn Entry::issn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issn")
  if res is None {
    return Err(Missing("issn"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the issn of the entry.
pub fn Entry::set_issn(self : Entry, item : Chunks) -> Unit {
  self.set("issn", item)
}

///|
/// Retrieves the issue of the entry as Chunks. 
pub fn Entry::issue(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issue")
  if res is None {
    return Err(Missing("issue"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the issue of the entry.
pub fn Entry::set_issue(self : Entry, item : Chunks) -> Unit {
  self.set("issue", item)
}

///|
/// Retrieves the issue_subtitle of the entry as Chunks.
pub fn Entry::issue_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issuesubtitle")
  if res is None {
    return Err(Missing("issuesubtitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the issue_subtitle of the entry.
pub fn Entry::set_issue_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("issuesubtitle", item)
}

///|
/// Retrieves the issue_title of the entry as Chunks.
pub fn Entry::issue_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issuetitle")
  if res is None {
    return Err(Missing("issuetitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the issue_title of the entry.
pub fn Entry::set_issue_title(self : Entry, item : Chunks) -> Unit {
  self.set("issuetitle", item)
}

///|
/// Retrieves the issue_title_addon of the entry as Chunks.
pub fn Entry::issue_title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issuetitleaddon")
  if res is None {
    return Err(Missing("issuetitleaddon"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the issue_title_addon of the entry.
pub fn Entry::set_issue_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("issuetitleaddon", item)
}

///|
/// Retrieves the iswc of the entry as Chunks.
pub fn Entry::iswc(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("iswc")
  if res is None {
    return Err(Missing("iswc"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the iswc of the entry.
pub fn Entry::set_iswc(self : Entry, item : Chunks) -> Unit {
  self.set("iswc", item)
}

///|
/// Retrieves the journal_subtitle of the entry as Chunks.
pub fn Entry::journal_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("journalsubtitle")
  if res is None {
    return Err(Missing("journalsubtitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the journaltitle of the entry.
pub fn Entry::set_journal_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("journalsubtitle", item)
}

///|
/// Retrieves the journal_title_addon of the entry as Chunks.
pub fn Entry::journal_title_addon(
  self : Entry,
) -> Result[Chunks, RetrievalError] {
  let res = self.get("journaltitleaddon")
  if res is None {
    return Err(Missing("journaltitleaddon"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the journal_title_addon of the entry.
pub fn Entry::set_journal_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("journaltitleaddon", item)
}

///|
/// Retrieves the keywords of the entry as Chunks.
pub fn Entry::keywords(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("keywords")
  if res is None {
    return Err(Missing("keywords"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the keyswords of the entry.
pub fn Entry::set_keywords(self : Entry, item : Chunks) -> Unit {
  self.set("keywords", item)
}

///|
/// Retrieves the label of the entry as Chunks.
pub fn Entry::label(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("label")
  if res is None {
    return Err(Missing("label"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the label of the entry.
pub fn Entry::set_label(self : Entry, item : Chunks) -> Unit {
  self.set("label", item)
}

///|
/// Retrieves the lagid of the entry as PermissiveType.
pub fn Entry::langid(
  self : Entry,
) -> Result[PermissiveType[Language], RetrievalError] {
  let res = self.get("langid")
  if res is None {
    return Err(Missing("langid"))
  }
  let res : PermissiveType[Language] = PermissiveType::from_chunks(res.unwrap())
  Ok(res)
}

///|
/// Sets or replaces the langid of the entry.
pub fn Entry::set_langid(self : Entry, item : PermissiveType[Language]) -> Unit {
  self.set("langid", PermissiveType::to_chunks(item))
}

///|
/// Retrieves the language of the entry as an array of PermissiveType[Language].
pub fn Entry::language(
  self : Entry,
) -> Result[Array[PermissiveType[Language]], RetrievalError] {
  let res = self.get("language")
  if res is None {
    return Err(Missing("language"))
  }
  // PermissiveType[Language] never throws error
  let res : Array[PermissiveType[Language]] = Type::from_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the language of the entry.
pub fn Entry::set_language(
  self : Entry,
  item : Array[PermissiveType[Language]],
) -> Unit {
  self.set("language", Type::to_chunks(item))
}

///|
/// Retrieves the library of the entry as Chunks.
pub fn Entry::library(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("library")
  if res is None {
    return Err(Missing("library"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the library of the entry.
pub fn Entry::set_library(self : Entry, item : Chunks) -> Unit {
  self.set("library", item)
}

///|
/// Retrieves the main_subtitle of the entry as Chunks.
pub fn Entry::main_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("mainsubtitle")
  if res is None {
    return Err(Missing("mainsubtitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the main_subtitle of the entry.
pub fn Entry::set_main_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("mainsubtitle", item)
}

///|
/// Retrieves the main_title of the entry as Chunks.
pub fn Entry::main_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("maintitle")
  if res is None {
    return Err(Missing("maintitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the main_title of the entry.
pub fn Entry::set_main_title(self : Entry, item : Chunks) -> Unit {
  self.set("maintitle", item)
}

///|
/// Retrieves the mian_title_addon of the entry as Chunks.
pub fn Entry::main_title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("maintitleaddon")
  if res is None {
    return Err(Missing("maintitleaddon"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the main_title_addon of the entry.
pub fn Entry::set_main_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("maintitleaddon", item)
}

///|
/// Retrieves the name_addon of the entry as Chunks.
pub fn Entry::name_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("nameaddon")
  if res is None {
    return Err(Missing("nameaddon"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the name_addon of the entry.
pub fn Entry::set_name_addon(self : Entry, item : Chunks) -> Unit {
  self.set("nameaddon", item)
}

///|
/// Retrieves the options of the entry as Chunks.
pub fn Entry::options(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("options")
  if res is None {
    return Err(Missing("options"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the options of the entry.
pub fn Entry::set_options(self : Entry, item : Chunks) -> Unit {
  self.set("options", item)
}

///|
/// Retrieves the orig_location of the entry as an array of String.
pub fn Entry::orig_language(
  self : Entry,
) -> Result[Array[String], RetrievalError] {
  let res = self.get("origlanguage")
  if res is None {
    return Err(Missing("origlanguage"))
  }
  // ArrayString's parse_chunks version never throws err 
  let res : ArrayString = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the orig_language of the entry.
pub fn Entry::set_orig_language(self : Entry, item : Array[String]) -> Unit {
  let item : ArrayString = ArrayString(item)
  self.set("origlanguage", item.to_chunks())
}

///|
/// Retrieves the orig_location of the entry as an array of Chunks.
pub fn Entry::orig_location(
  self : Entry,
) -> Result[Array[Chunks], RetrievalError] {
  let res = self.get("origlocation")
  if res is None {
    return Err(Missing("origlocation"))
  }
  // ArrayChunks's parse_chunks version never throws err 
  let res : ArrayChunks = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the orig_location of the entry.
pub fn Entry::set_orig_location(self : Entry, item : Array[Chunks]) -> Unit {
  let item : ArrayChunks = ArrayChunks(item)
  self.set("origlocation", item.to_chunks())
}

///|
/// Retrieves the page_total of the entry as Chunks.
pub fn Entry::page_total(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("pagetotal")
  if res is None {
    return Err(Missing("pagetotal"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the page_total of the entry.
pub fn Entry::set_page_total(self : Entry, item : Chunks) -> Unit {
  self.set("pagetotal", item)
}

///|
/// Retrieves the pagination of the entry as Pagination.
pub fn Entry::pagination(self : Entry) -> Result[Pagination, RetrievalError] {
  let res = self.get("pagination")
  if res is None {
    return Err(Missing("pagination"))
  }
  let res : Pagination = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the pagination of the entry.
pub fn Entry::set_pagination(self : Entry, item : Pagination) -> Unit {
  self.set("pagination", Type::to_chunks(item))
}

///|
/// Retrieves the part of the entry as Chunks.
pub fn Entry::part(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("part")
  if res is None {
    return Err(Missing("part"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the part of the entry.
pub fn Entry::set_part(self : Entry, item : Chunks) -> Unit {
  self.set("part", item)
}

///|
/// Retrieves the pubstate of the entry as Chunks.
pub fn Entry::pubstate(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("pubstate")
  if res is None {
    return Err(Missing("pubstate"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the pubstate of the entry.
pub fn Entry::set_pubstate(self : Entry, item : Chunks) -> Unit {
  self.set("pubstate", item)
}

///|
/// Retrieves the reprint_title of the entry as Chunks.
pub fn Entry::reprint_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("reprinttitle")
  if res is None {
    return Err(Missing("reprinttitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the reprint_title of the entry.
pub fn Entry::set_reprint_title(self : Entry, item : Chunks) -> Unit {
  self.set("reprinttitle", item)
}

///|
/// Retrieves the short_author of the entry as an array of Person.
pub fn Entry::short_author(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("shortauthor")
  if res is None {
    return Err(Missing("shortauthor"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the short_author of the entry.
pub fn Entry::set_short_author(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("shortauthor", item.to_chunks())
}

///|
/// Retrieves the short_editor of the entry as an array of Person.
pub fn Entry::short_editor(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("shorteditor")
  if res is None {
    return Err(Missing("shorteditor"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the short_editor of the entry.
pub fn Entry::set_short_editor(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("shorteditor", item.to_chunks())
}

///|
/// Retrieves the shorthand of the entry as Chunks.
pub fn Entry::shorthand(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shorthand")
  if res is None {
    return Err(Missing("shorthand"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the shorthand of the entry.
pub fn Entry::set_shorthand(self : Entry, item : Chunks) -> Unit {
  self.set("shorthand", item)
}

///|
/// Retrieves the shorthand_intro of the entry as Chunks.
pub fn Entry::shorthand_intro(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shorthandintro")
  if res is None {
    return Err(Missing("shorthandintro"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the shorthand_intro of the entry.
pub fn Entry::set_shorthand_intro(self : Entry, item : Chunks) -> Unit {
  self.set("shorthandintro", item)
}

///|
/// Retrieves the short_journal of the entry as Chunks.
pub fn Entry::short_journal(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shortjournal")
  if res is None {
    return Err(Missing("shortjournal"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the short_journal of the entry.
pub fn Entry::set_short_journal(self : Entry, item : Chunks) -> Unit {
  self.set("shortjournal", item)
}

///|
/// Retrieves the short_series of the entry as Chunks.
pub fn Entry::short_series(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shortseries")
  if res is None {
    return Err(Missing("shortseries"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the short_series of the entry.
pub fn Entry::set_short_series(self : Entry, item : Chunks) -> Unit {
  self.set("shortseries", item)
}

///|
/// Retrieves the short_title of the entry as Chunks.
pub fn Entry::short_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shorttitle")
  if res is None {
    return Err(Missing("shorttitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the short_title of the entry.
pub fn Entry::set_short_title(self : Entry, item : Chunks) -> Unit {
  self.set("shorttitle", item)
}

///|
/// Retrieves the subtitle of the entry as Chunks.
pub fn Entry::subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("subtitle")
  if res is None {
    return Err(Missing("subtitle"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the subtitle of the entry.
pub fn Entry::set_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("subtitle", item)
}

///|
/// Retrieves the title_addon of the entry as Chunks.
pub fn Entry::title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("titleaddon")
  if res is None {
    return Err(Missing("titleaddon"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the title_addon of the entry.
pub fn Entry::set_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("titleaddon", item)
}

///|
/// Retrieves the translator of the entry as an array of Person.
pub fn Entry::translator(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("translator")
  if res is None {
    return Err(Missing("translator"))
  }
  // ArrayPerson's parse_chunks version never throws err 
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.0)
}

///|
/// Sets or replaces the translator of the entry.
pub fn Entry::set_translator(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("translator", item.to_chunks())
}

///|
/// Retrieves the url of the entry as String.
pub fn Entry::url(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("url")
  if res is None {
    return Err(Missing("url"))
  }
  // String's parse_chunks version never throws err 
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the url of the entry.
pub fn Entry::set_url(self : Entry, item : String) -> Unit {
  self.set("url", Type::to_chunks(item))
}

///|
/// Retrieves the venue of the entry as Chunks.
pub fn Entry::venue(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("venue")
  if res is None {
    return Err(Missing("venue"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the venue of the entry.
pub fn Entry::set_venue(self : Entry, item : Chunks) -> Unit {
  self.set("venue", item)
}

///|
/// Retrieves the version of the entry as Chunks.
pub fn Entry::version(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("version")
  if res is None {
    return Err(Missing("version"))
  }
  Ok(res.unwrap())
}

///|
/// Sets or replaces the version of the entry.
pub fn Entry::set_version(self : Entry, item : Chunks) -> Unit {
  self.set("version", item)
}

///|
/// Retrieves the volumes of the entry as Int64.
pub fn Entry::volumes(self : Entry) -> Result[Int64, RetrievalError] {
  let res = self.get("volumes")
  if res is None {
    return Err(Missing("volumes"))
  }
  let res : Int64 = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the volumes of the entry.
pub fn Entry::set_volumes(self : Entry, item : Int64) -> Unit {
  self.set("volumes", Type::to_chunks(item))
}

///|
/// Retrieves the gender of the entry as Gender.
pub fn Entry::gender(self : Entry) -> Result[Gender, RetrievalError] {
  let res = self.get("gender")
  if res is None {
    return Err(Missing("gender"))
  }
  let res : Gender = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
/// Sets or replaces the gender of the entry.
pub fn Entry::set_gender(self : Entry, item : Gender) -> Unit {
  self.set("gender", Type::to_chunks(item))
}

///|
test "test_getter_setter" {
  let entry : Entry = Entry::new("", Article)
  assert_eq(entry.author(), Err(Missing("author")))
  assert_eq(entry.book_title(), Err(Missing("booktitle")))
  entry.set_book_title([Spanned::detached(Normal("booktitle"))])
  assert_eq(entry.book_title(), Ok([Spanned::detached(Normal("booktitle"))]))
  assert_eq(entry.chapter(), Err(Missing("chapter")))
  entry.set_chapter([Spanned::detached(Normal("chapter"))])
  assert_eq(entry.chapter(), Ok([Spanned::detached(Normal("chapter"))]))
  assert_eq(entry.edition(), Err(Missing("edition")))
  let typed : PermissiveType[Int64] = Typed(259997)
  entry.set_edition(typed)
  assert_eq(entry.edition(), Ok(typed))
  assert_eq(entry.how_published(), Err(Missing("howpublished")))
  entry.set_how_published([Spanned::detached(Normal("howpublished"))])
  assert_eq(
    entry.how_published(),
    Ok([Spanned::detached(Normal("howpublished"))]),
  )
  assert_eq(entry.note(), Err(Missing("note")))
  entry.set_note([Spanned::detached(Normal("note"))])
  assert_eq(entry.note(), Ok([Spanned::detached(Normal("note"))]))
  assert_eq(entry.number(), Err(Missing("number")))
  entry.set_number([Spanned::detached(Normal("number"))])
  assert_eq(entry.number(), Ok([Spanned::detached(Normal("number"))]))
  assert_eq(entry.organization(), Err(Missing("organization")))
  entry.set_organization([[Spanned::detached(Normal("organization"))]])
  assert_eq(
    entry.organization(),
    Ok([[Spanned::detached(Normal("organization"))]]),
  )
  entry.set_pages(Chunks([Spanned::detached(Normal("pages"))]))
  assert_eq(entry.pages(), Ok(Chunks([Spanned::detached(Normal("pages"))])))
  entry.set_pages(Typed([{ start: 1, end: 2 }]))
  assert_eq(entry.pages(), Ok(Typed([{ start: 1, end: 2 }])))
  assert_eq(entry.publisher(), Err(Missing("publisher")))
  entry.set_publisher([[Spanned::detached(Normal("publisher"))]])
  assert_eq(entry.publisher(), Ok([[Spanned::detached(Normal("publisher"))]]))
  assert_eq(entry.series(), Err(Missing("series")))
  entry.set_series([Spanned::detached(Normal("series"))])
  assert_eq(entry.series(), Ok([Spanned::detached(Normal("series"))]))
  assert_eq(entry.title(), Err(Missing("title")))
  entry.set_title([Spanned::detached(Normal("title"))])
  assert_eq(entry.title(), Ok([Spanned::detached(Normal("title"))]))
  assert_eq(entry.type_(), Err(Missing("type")))
  entry.set_type_("type")
  assert_eq(entry.type_(), Ok("type"))
  assert_eq(entry.volume(), Err(Missing("volume")))
  entry.set_volume(Typed(299997))
  assert_eq(entry.volume(), Ok(Typed(299997)))
  assert_eq(entry.address(), Err(Missing("address")))
  entry.set_location([Spanned::detached(Normal("location"))])
  assert_eq(entry.address(), Ok([Spanned::detached(Normal("location"))]))
  entry.set_address([Spanned::detached(Normal("address"))])
  assert_eq(entry.address(), Ok([Spanned::detached(Normal("address"))]))
  let entry = Entry::new("", Article)
  assert_eq(entry.location(), Err(Missing("location")))
  entry.set_address([Spanned::detached(Normal("address"))])
  assert_eq(entry.location(), Ok([Spanned::detached(Normal("address"))]))
  entry.set_location([Spanned::detached(Normal("location"))])
  assert_eq(entry.location(), Ok([Spanned::detached(Normal("location"))]))
  assert_eq(entry.annotation(), Err(Missing("annotation")))
  entry.fields.set("annote", [Spanned::detached(Normal("annote"))])
  assert_eq(entry.annotation(), Ok([Spanned::detached(Normal("annote"))]))
  entry.set_annotation([Spanned::detached(Normal("annotation"))])
  assert_eq(entry.annotation(), Ok([Spanned::detached(Normal("annotation"))]))
  assert_eq(entry.eprint_type(), Err(Missing("eprinttype")))
  entry.fields.set("archiveprefix", [Spanned::detached(Normal("archiveprefix"))])
  assert_eq(
    entry.eprint_type(),
    Ok([Spanned::detached(Normal("archiveprefix"))]),
  )
  entry.set_eprint_type([Spanned::detached(Normal("eprinttype"))])
  assert_eq(entry.eprint_type(), Ok([Spanned::detached(Normal("eprinttype"))]))
  assert_eq(entry.eprint_class(), Err(Missing("eprintclass")))
  entry.fields.set("primaryclass", [Spanned::detached(Normal("primaryclass"))])
  assert_eq(
    entry.eprint_class(),
    Ok([Spanned::detached(Normal("primaryclass"))]),
  )
  entry.set_eprint_class([Spanned::detached(Normal("eprintclass"))])
  assert_eq(
    entry.eprint_class(),
    Ok([Spanned::detached(Normal("eprintclass"))]),
  )
  assert_eq(entry.journal(), Err(Missing("journal")))
  entry.fields.set("journaltitle", [Spanned::detached(Normal("journaltitle"))])
  assert_eq(entry.journal(), Ok([Spanned::detached(Normal("journaltitle"))]))
  entry.set_journal([Spanned::detached(Normal("journal"))])
  assert_eq(entry.journal(), Ok([Spanned::detached(Normal("journal"))]))
  let entry = Entry::new("", Article)
  assert_eq(entry.journal_title(), Err(Missing("journaltitle")))
  entry.set_journal([Spanned::detached(Normal("journal"))])
  assert_eq(entry.journal_title(), Ok([Spanned::detached(Normal("journal"))]))
  entry.set_journal_title([Spanned::detached(Normal("journaltitle"))])
  assert_eq(
    entry.journal_title(),
    Ok([Spanned::detached(Normal("journaltitle"))]),
  )
  assert_eq(entry.sort_key(), Err(Missing("key")))
  entry.fields.set("sortkey", [Spanned::detached(Normal("sortkey"))])
  assert_eq(entry.sort_key(), Ok("sortkey"))
  entry.set_sort_key("key")
  assert_eq(entry.sort_key(), Ok("key"))
  assert_eq(entry.file(), Err(Missing("file")))
  entry.fields.set("pdf", [Spanned::detached(Normal("pdf"))])
  assert_eq(entry.file(), Ok("pdf"))
  entry.set_file("file")
  assert_eq(entry.file(), Ok("file"))
  assert_eq(entry.school(), Err(Missing("school")))
  entry.set_institution("institution")
  assert_eq(entry.school(), Ok([Spanned::detached(Verbatim("institution"))]))
  entry.set_school([Spanned::detached(Normal("school"))])
  assert_eq(entry.school(), Ok([Spanned::detached(Normal("school"))]))
  let entry = Entry::new("", Article)
  assert_eq(entry.institution(), Err(Missing("institution")))
  entry.set_school([Spanned::detached(Normal("school"))])
  assert_eq(entry.institution(), Ok("school"))
  entry.set_institution("institution")
  assert_eq(entry.institution(), Ok("institution"))
  entry.fields.set("eventyear", [Spanned::detached(Normal("1944"))])
  entry.fields.set("eventmonth", [Spanned::detached(Normal("March"))])
  entry.fields.set("eventday", [Spanned::detached(Normal("64"))])
  let type_error : TypeError = TypeError(
    ({ start: 2147483647, end: 2147483647 }, DayOutOfRange),
  )
  assert_eq(entry.event_date(), Err(TypeError(type_error)))
  entry.fields.set("eventday", [Spanned::detached(Normal("20"))])
  let date = Date::parse_three_fields(
    [Spanned::detached(Normal("1944"))],
    Some([Spanned::detached(Normal("March"))]),
    Some([Spanned::detached(Normal("20"))]),
  )
  assert_eq(entry.event_date(), Ok(Typed(date)))
  entry.set_event_date(Chunks([Spanned::detached(Normal("eventdate"))]))
  assert_eq(
    entry.event_date(),
    Ok(Chunks([Spanned::detached(Normal("eventdate"))])),
  )
  entry.fields.set("origyear", [Spanned::detached(Normal("1944"))])
  entry.fields.set("origmonth", [Spanned::detached(Normal("March"))])
  entry.fields.set("origday", [Spanned::detached(Normal("64"))])
  let type_error : TypeError = TypeError(
    ({ start: 2147483647, end: 2147483647 }, DayOutOfRange),
  )
  assert_eq(entry.orig_date(), Err(TypeError(type_error)))
  entry.fields.set("origday", [Spanned::detached(Normal("20"))])
  let date = Date::parse_three_fields(
    [Spanned::detached(Normal("1944"))],
    Some([Spanned::detached(Normal("March"))]),
    Some([Spanned::detached(Normal("20"))]),
  )
  assert_eq(entry.orig_date(), Ok(Typed(date)))
  entry.set_orig_date(Chunks([Spanned::detached(Normal("origdate"))]))
  assert_eq(
    entry.orig_date(),
    Ok(Chunks([Spanned::detached(Normal("origdate"))])),
  )
  entry.fields.set("urlyear", [Spanned::detached(Normal("1944"))])
  entry.fields.set("urlmonth", [Spanned::detached(Normal("March"))])
  entry.fields.set("urlday", [Spanned::detached(Normal("64"))])
  let type_error : TypeError = TypeError(
    ({ start: 2147483647, end: 2147483647 }, DayOutOfRange),
  )
  assert_eq(entry.url_date(), Err(TypeError(type_error)))
  entry.fields.set("urlday", [Spanned::detached(Normal("20"))])
  let date = Date::parse_three_fields(
    [Spanned::detached(Normal("1944"))],
    Some([Spanned::detached(Normal("March"))]),
    Some([Spanned::detached(Normal("20"))]),
  )
  assert_eq(entry.url_date(), Ok(Typed(date)))
  entry.set_url_date(Chunks([Spanned::detached(Normal("urldate"))]))
  assert_eq(
    entry.url_date(),
    Ok(Chunks([Spanned::detached(Normal("urldate"))])),
  )
  assert_eq(entry.abstract_(), Err(Missing("abstract")))
  entry.set_abstract_([Spanned::detached(Normal("abstract"))])
  assert_eq(entry.abstract_(), Ok([Spanned::detached(Normal("abstract"))]))
  assert_eq(entry.addendum(), Err(Missing("addendum")))
  entry.set_addendum([Spanned::detached(Normal("addendum"))])
  assert_eq(entry.addendum(), Ok([Spanned::detached(Normal("addendum"))]))
  assert_eq(entry.afterword(), Err(Missing("afterword")))
  entry.set_afterword([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }])
  assert_eq(
    entry.afterword(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.annotator(), Err(Missing("annotator")))
  entry.set_annotator([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }])
  assert_eq(
    entry.annotator(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.author_type(), Err(Missing("authortype")))
  entry.set_author_type("authortype")
  assert_eq(entry.author_type(), Ok("authortype"))
  assert_eq(entry.book_author(), Err(Missing("bookauthor")))
  entry.set_book_author([
    { suffix: "t", name: "e", given_name: "s", prefix: "t" },
  ])
  assert_eq(
    entry.book_author(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.book_pagination(), Err(Missing("bookpagination")))
  entry.set_book_pagination(Pagination::Page)
  assert_eq(entry.book_pagination(), Ok(Page))
  entry.fields.set("bookpagination", [Spanned::detached(Normal("unknown"))])
  let type_error : TypeError = TypeError(
    ({ start: 2147483647, end: 2147483647 }, UnknownPagination),
  )
  assert_eq(entry.book_pagination(), Err(TypeError(type_error)))
  assert_eq(entry.book_subtitle(), Err(Missing("booksubtitle")))
  entry.set_book_subtitle([Spanned::detached(Normal("booksubtitle"))])
  assert_eq(
    entry.book_subtitle(),
    Ok([Spanned::detached(Normal("booksubtitle"))]),
  )
  assert_eq(entry.book_title_addon(), Err(Missing("booktitleaddon")))
  entry.set_book_title_addon([Spanned::detached(Normal("booktitleaddon"))])
  assert_eq(
    entry.book_title_addon(),
    Ok([Spanned::detached(Normal("booktitleaddon"))]),
  )
  assert_eq(entry.commentator(), Err(Missing("commentator")))
  entry.set_commentator([
    { suffix: "t", name: "e", given_name: "s", prefix: "t" },
  ])
  assert_eq(
    entry.commentator(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.doi(), Err(Missing("doi")))
  entry.set_doi("doi")
  assert_eq(entry.doi(), Ok("doi"))
  assert_eq(entry.eid(), Err(Missing("eid")))
  entry.set_eid([Spanned::detached(Normal("eid"))])
  assert_eq(entry.eid(), Ok([Spanned::detached(Normal("eid"))]))
  assert_eq(entry.entry_subtype(), Err(Missing("entrysubtype")))
  entry.set_entry_subtype([Spanned::detached(Normal("entrysubtype"))])
  assert_eq(
    entry.entry_subtype(),
    Ok([Spanned::detached(Normal("entrysubtype"))]),
  )
  assert_eq(entry.eprint(), Err(Missing("eprint")))
  entry.set_eprint("eprint")
  assert_eq(entry.eprint(), Ok("eprint"))
  assert_eq(entry.eventtitle(), Err(Missing("eventtitle")))
  entry.set_eventtitle([Spanned::detached(Normal("eventtitle"))])
  assert_eq(entry.eventtitle(), Ok([Spanned::detached(Normal("eventtitle"))]))
  assert_eq(entry.eventtitle_addon(), Err(Missing("eventtitleaddon")))
  entry.set_eventtitle_addon([Spanned::detached(Normal("eventtitleaddon"))])
  assert_eq(
    entry.eventtitle_addon(),
    Ok([Spanned::detached(Normal("eventtitleaddon"))]),
  )
  assert_eq(entry.foreword(), Err(Missing("foreword")))
  entry.set_foreword([Spanned::detached(Normal("foreword"))])
  assert_eq(entry.foreword(), Ok([Spanned::detached(Normal("foreword"))]))
  assert_eq(entry.holder(), Err(Missing("holder")))
  entry.set_holder([Spanned::detached(Normal("holder"))])
  assert_eq(entry.holder(), Ok([Spanned::detached(Normal("holder"))]))
  assert_eq(entry.index_title(), Err(Missing("indextitle")))
  entry.set_index_title([Spanned::detached(Normal("indextitle"))])
  assert_eq(entry.index_title(), Ok([Spanned::detached(Normal("indextitle"))]))
  assert_eq(entry.introduction(), Err(Missing("introduction")))
  entry.set_introduction([
    { suffix: "t", name: "e", given_name: "s", prefix: "t" },
  ])
  assert_eq(
    entry.introduction(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.isan(), Err(Missing("isan")))
  entry.set_isan([Spanned::detached(Normal("isan"))])
  assert_eq(entry.isan(), Ok([Spanned::detached(Normal("isan"))]))
  assert_eq(entry.isbn(), Err(Missing("isbn")))
  entry.set_isbn([Spanned::detached(Normal("isbn"))])
  assert_eq(entry.isbn(), Ok([Spanned::detached(Normal("isbn"))]))
  assert_eq(entry.ismn(), Err(Missing("ismn")))
  entry.set_ismn([Spanned::detached(Normal("ismn"))])
  assert_eq(entry.ismn(), Ok([Spanned::detached(Normal("ismn"))]))
  assert_eq(entry.isrn(), Err(Missing("isrn")))
  entry.set_isrn([Spanned::detached(Normal("isrn"))])
  assert_eq(entry.isrn(), Ok([Spanned::detached(Normal("isrn"))]))
  assert_eq(entry.issn(), Err(Missing("issn")))
  entry.set_issn([Spanned::detached(Normal("issn"))])
  assert_eq(entry.issn(), Ok([Spanned::detached(Normal("issn"))]))
  assert_eq(entry.issue(), Err(Missing("issue")))
  entry.set_issue([Spanned::detached(Normal("issue"))])
  assert_eq(entry.issue(), Ok([Spanned::detached(Normal("issue"))]))
  assert_eq(entry.issue_subtitle(), Err(Missing("issuesubtitle")))
  entry.set_issue_subtitle([Spanned::detached(Normal("issuesubtitle"))])
  assert_eq(
    entry.issue_subtitle(),
    Ok([Spanned::detached(Normal("issuesubtitle"))]),
  )
  assert_eq(entry.issue_title(), Err(Missing("issuetitle")))
  entry.set_issue_title([Spanned::detached(Normal("issuetitle"))])
  assert_eq(entry.issue_title(), Ok([Spanned::detached(Normal("issuetitle"))]))
  assert_eq(entry.issue_title_addon(), Err(Missing("issuetitleaddon")))
  entry.set_issue_title_addon([Spanned::detached(Normal("issuetitleaddon"))])
  assert_eq(
    entry.issue_title_addon(),
    Ok([Spanned::detached(Normal("issuetitleaddon"))]),
  )
  assert_eq(entry.iswc(), Err(Missing("iswc")))
  entry.set_iswc([Spanned::detached(Normal("iswc"))])
  assert_eq(entry.iswc(), Ok([Spanned::detached(Normal("iswc"))]))
  assert_eq(entry.journal_subtitle(), Err(Missing("journalsubtitle")))
  entry.set_journal_subtitle([Spanned::detached(Normal("journalsubtitle"))])
  assert_eq(
    entry.journal_subtitle(),
    Ok([Spanned::detached(Normal("journalsubtitle"))]),
  )
  assert_eq(entry.journal_title_addon(), Err(Missing("journaltitleaddon")))
  entry.set_journal_title_addon([Spanned::detached(Normal("journaltitleaddon"))])
  assert_eq(
    entry.journal_title_addon(),
    Ok([Spanned::detached(Normal("journaltitleaddon"))]),
  )
  assert_eq(entry.keywords(), Err(Missing("keywords")))
  entry.set_keywords([Spanned::detached(Normal("keywords"))])
  assert_eq(entry.keywords(), Ok([Spanned::detached(Normal("keywords"))]))
  assert_eq(entry.label(), Err(Missing("label")))
  entry.set_label([Spanned::detached(Normal("label"))])
  assert_eq(entry.label(), Ok([Spanned::detached(Normal("label"))]))
  assert_eq(entry.langid(), Err(Missing("langid")))
  entry.set_langid(Chunks([Spanned::detached(Normal("langid"))]))
  assert_eq(entry.langid(), Ok(Chunks([Spanned::detached(Normal("langid"))])))
  let entry = Entry::new("", Article)
  assert_eq(entry.language(), Err(Missing("language")))
  entry.set_language([Typed(French), Typed(EnglishAUS)])
  assert_eq(
    entry.language(),
    Ok([
      Chunks([
        Spanned::detached(Verbatim("French")),
        Spanned::detached(Verbatim(" and ")),
        Spanned::detached(Verbatim("EnglishAUS")),
      ]),
    ]),
  )
  assert_eq(entry.library(), Err(Missing("library")))
  entry.set_library([Spanned::detached(Normal("library"))])
  assert_eq(entry.library(), Ok([Spanned::detached(Normal("library"))]))
  assert_eq(entry.main_subtitle(), Err(Missing("mainsubtitle")))
  entry.set_main_subtitle([Spanned::detached(Normal("mainsubtitle"))])
  assert_eq(
    entry.main_subtitle(),
    Ok([Spanned::detached(Normal("mainsubtitle"))]),
  )
  assert_eq(entry.main_title(), Err(Missing("maintitle")))
  entry.set_main_title([Spanned::detached(Normal("maintitle"))])
  assert_eq(entry.main_title(), Ok([Spanned::detached(Normal("maintitle"))]))
  assert_eq(entry.name_addon(), Err(Missing("nameaddon")))
  entry.set_name_addon([Spanned::detached(Normal("nameaddon"))])
  assert_eq(entry.name_addon(), Ok([Spanned::detached(Normal("nameaddon"))]))
  assert_eq(entry.options(), Err(Missing("options")))
  entry.set_options([Spanned::detached(Normal("options"))])
  assert_eq(entry.options(), Ok([Spanned::detached(Normal("options"))]))
  assert_eq(entry.orig_language(), Err(Missing("origlanguage")))
  entry.set_orig_language(["a day in a life", "help!"])
  assert_eq(entry.orig_language(), Ok(["a day in a life", "help!"]))
  assert_eq(entry.orig_location(), Err(Missing("origlocation")))
  entry.set_orig_location([[Spanned::detached(Normal("origlocation"))]])
  assert_eq(
    entry.orig_location(),
    Ok([[Spanned::detached(Normal("origlocation"))]]),
  )
  assert_eq(entry.page_total(), Err(Missing("pagetotal")))
  entry.set_page_total([Spanned::detached(Normal("pagetotal"))])
  assert_eq(entry.page_total(), Ok([Spanned::detached(Normal("pagetotal"))]))
  assert_eq(entry.pagination(), Err(Missing("pagination")))
  entry.set_pagination(Pagination::Page)
  assert_eq(entry.pagination(), Ok(Page))
  assert_eq(entry.part(), Err(Missing("part")))
  entry.set_part([Spanned::detached(Normal("part"))])
  assert_eq(entry.part(), Ok([Spanned::detached(Normal("part"))]))
  assert_eq(entry.pubstate(), Err(Missing("pubstate")))
  entry.set_pubstate([Spanned::detached(Normal("pubstate"))])
  assert_eq(entry.pubstate(), Ok([Spanned::detached(Normal("pubstate"))]))
  assert_eq(entry.reprint_title(), Err(Missing("reprinttitle")))
  entry.set_reprint_title([Spanned::detached(Normal("reprinttitle"))])
  assert_eq(
    entry.reprint_title(),
    Ok([Spanned::detached(Normal("reprinttitle"))]),
  )
  assert_eq(entry.short_author(), Err(Missing("shortauthor")))
  entry.set_short_author([
    { suffix: "t", name: "e", given_name: "s", prefix: "t" },
  ])
  assert_eq(
    entry.short_author(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.short_editor(), Err(Missing("shorteditor")))
  entry.set_short_editor([
    { suffix: "t", name: "e", given_name: "s", prefix: "t" },
  ])
  assert_eq(
    entry.short_editor(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.shorthand(), Err(Missing("shorthand")))
  entry.set_shorthand([Spanned::detached(Normal("shorthand"))])
  assert_eq(entry.shorthand(), Ok([Spanned::detached(Normal("shorthand"))]))
  assert_eq(entry.shorthand_intro(), Err(Missing("shorthandintro")))
  entry.set_shorthand_intro([Spanned::detached(Normal("shorthandintro"))])
  assert_eq(
    entry.shorthand_intro(),
    Ok([Spanned::detached(Normal("shorthandintro"))]),
  )
  assert_eq(entry.short_journal(), Err(Missing("shortjournal")))
  entry.set_short_journal([Spanned::detached(Normal("shortjournal"))])
  assert_eq(
    entry.short_journal(),
    Ok([Spanned::detached(Normal("shortjournal"))]),
  )
  assert_eq(entry.short_series(), Err(Missing("shortseries")))
  entry.set_short_series([Spanned::detached(Normal("shortseries"))])
  assert_eq(
    entry.short_series(),
    Ok([Spanned::detached(Normal("shortseries"))]),
  )
  assert_eq(entry.short_title(), Err(Missing("shorttitle")))
  entry.set_short_title([Spanned::detached(Normal("shorttitle"))])
  assert_eq(entry.short_title(), Ok([Spanned::detached(Normal("shorttitle"))]))
  assert_eq(entry.subtitle(), Err(Missing("subtitle")))
  entry.set_subtitle([Spanned::detached(Normal("subtitle"))])
  assert_eq(entry.subtitle(), Ok([Spanned::detached(Normal("subtitle"))]))
  assert_eq(entry.title_addon(), Err(Missing("titleaddon")))
  entry.set_title_addon([Spanned::detached(Normal("titleaddon"))])
  assert_eq(entry.title_addon(), Ok([Spanned::detached(Normal("titleaddon"))]))
  assert_eq(entry.translator(), Err(Missing("translator")))
  entry.set_translator([
    { suffix: "t", name: "e", given_name: "s", prefix: "t" },
  ])
  assert_eq(
    entry.translator(),
    Ok([{ suffix: "t", name: "e", given_name: "s", prefix: "t" }]),
  )
  assert_eq(entry.url(), Err(Missing("url")))
  entry.set_url("url")
  assert_eq(entry.url(), Ok("url"))
  assert_eq(entry.venue(), Err(Missing("venue")))
  entry.set_venue([Spanned::detached(Normal("venue"))])
  assert_eq(entry.venue(), Ok([Spanned::detached(Normal("venue"))]))
  assert_eq(entry.version(), Err(Missing("version")))
  entry.set_version([Spanned::detached(Normal("version"))])
  assert_eq(entry.version(), Ok([Spanned::detached(Normal("version"))]))
  assert_eq(entry.volumes(), Err(Missing("volumes")))
  entry.set_volumes(299997)
  assert_eq(entry.volumes(), Ok(299997))
  entry.fields.set("volumes", [Spanned::detached(Normal("1.3544"))])
  assert_eq(
    entry.volumes(),
    Err(
      TypeError(
        TypeError(({ start: 2147483647, end: 2147483647 }, MissingNumber)),
      ),
    ),
  )
  assert_eq(entry.gender(), Err(Missing("gender")))
  entry.set_gender(Gender::PluralMale)
  assert_eq(
    entry.gender(),
    Err(
      TypeError(
        TypeError(({ start: 2147483647, end: 2147483647 }, UnknownGender)),
      ),
    ),
  )
  entry.fields.set("gender", [Spanned::detached(Normal("pf"))])
  assert_eq(entry.gender(), Ok(PluralFemale))
  assert_eq(entry.main_title_addon(), Err(Missing("maintitleaddon")))
  entry.set_main_title_addon([Spanned::detached(Normal("maintitleaddon"))])
  assert_eq(
    entry.main_title_addon(),
    Ok([Spanned::detached(Normal("maintitleaddon"))]),
  )
}
