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
pub fn Entry::author(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("author")
  if res is None {
    return Err(Missing("author"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_author(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("author", item.to_chunks())
}

///|
pub fn Entry::book_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("booktitle")
  if res is None {
    return Err(Missing("booktitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_book_title(self : Entry, item : Chunks) -> Unit {
  self.set("booktitle", item)
}

///|
pub fn Entry::chapter(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("chapter")
  if res is None {
    return Err(Missing("chapter"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_chapter(self : Entry, item : Chunks) -> Unit {
  self.set("chapter", item)
}

///|
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
pub fn Entry::set_edition(self : Entry, item : PermissiveType[Int64]) -> Unit {
  self.set("edition", PermissiveType::to_chunks(item))
}

///|
pub fn Entry::how_published(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("howpublished")
  if res is None {
    return Err(Missing("howpublished"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_how_published(self : Entry, item : Chunks) -> Unit {
  self.set("howpublished", item)
}

///|
pub fn Entry::note(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("note")
  if res is None {
    return Err(Missing("note"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_note(self : Entry, item : Chunks) -> Unit {
  self.set("note", item)
}

///|
pub fn Entry::number(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("number")
  if res is None {
    return Err(Missing("number"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_number(self : Entry, item : Chunks) -> Unit {
  self.set("number", item)
}

///|
pub fn Entry::organization(
  self : Entry,
) -> Result[Array[Chunks], RetrievalError] {
  let res = self.get("organization")
  if res is None {
    return Err(Missing("organization"))
  }
  let res : ArrayChunks = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_organization(self : Entry, item : Array[Chunks]) -> Unit {
  let item : ArrayChunks = ArrayChunks(item)
  self.set("organization", item.to_chunks())
}

///|
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
    Typed(array_range) => Typed(array_range.inner())
    Chunks(chunks) => Chunks(chunks)
  }
  Ok(res)
}

///|
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
pub fn Entry::publisher(self : Entry) -> Result[Array[Chunks], RetrievalError] {
  let res = self.get("publisher")
  if res is None {
    return Err(Missing("publisher"))
  }
  let res : ArrayChunks = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_publisher(self : Entry, item : Array[Chunks]) -> Unit {
  let item : ArrayChunks = ArrayChunks(item)
  self.set("publisher", item.to_chunks())
}

///|
pub fn Entry::series(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("series")
  if res is None {
    return Err(Missing("series"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_series(self : Entry, item : Chunks) -> Unit {
  self.set("series", item)
}

///|
pub fn Entry::title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("title")
  if res is None {
    return Err(Missing("title"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_title(self : Entry, item : Chunks) -> Unit {
  self.set("title", item)
}

///|
pub fn Entry::type_(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("type")
  if res is None {
    return Err(Missing("type"))
  }
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
pub fn Entry::set_type_(self : Entry, item : String) -> Unit {
  self.set("type", Type::to_chunks(item))
}

///|
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
pub fn Entry::set_volume(self : Entry, item : PermissiveType[Int64]) -> Unit {
  self.set("volume", PermissiveType::to_chunks(item))
}

///|
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
pub fn Entry::set_address(self : Entry, item : Chunks) -> Unit {
  self.set("address", item)
}

///|
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
pub fn Entry::set_location(self : Entry, item : Chunks) -> Unit {
  self.set("location", item)
}

///|
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
pub fn Entry::set_annotation(self : Entry, item : Chunks) -> Unit {
  self.set("annotation", item)
}

///|
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
pub fn Entry::set_eprint_type(self : Entry, item : Chunks) -> Unit {
  self.set("eprinttype", item)
}

///|
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
pub fn Entry::set_eprint_class(self : Entry, item : Chunks) -> Unit {
  self.set("eprintclass", item)
}

///|
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
pub fn Entry::set_journal(self : Entry, item : Chunks) -> Unit {
  self.set("journal", item)
}

///|
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
pub fn Entry::set_journal_title(self : Entry, item : Chunks) -> Unit {
  self.set("journaltitle", item)
}

///|
pub fn Entry::sort_key(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("key")
  if res is None {
    let res = self.get("sortkey")
    if res is None {
      Err(Missing("key"))
    } else {
      let res : String = parse_chunks(res.unwrap()) catch {
        err => return Err(TypeError(err))
      }
      Ok(res)
    }
  } else {
    let res : String = parse_chunks(res.unwrap()) catch {
      err => return Err(TypeError(err))
    }
    Ok(res)
  }
}

///|
pub fn Entry::set_sort_key(self : Entry, item : String) -> Unit {
  self.set("key", Type::to_chunks(item))
}

///|
pub fn Entry::file(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("file")
  if res is None {
    let res = self.get("pdf")
    if res is None {
      Err(Missing("file"))
    } else {
      let res : String = parse_chunks(res.unwrap()) catch {
        err => return Err(TypeError(err))
      }
      Ok(res)
    }
  } else {
    let res : String = parse_chunks(res.unwrap()) catch {
      err => return Err(TypeError(err))
    }
    Ok(res)
  }
}

///|
pub fn Entry::set_file(self : Entry, item : String) -> Unit {
  self.set("file", Type::to_chunks(item))
}

///|
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
pub fn Entry::set_school(self : Entry, item : Chunks) -> Unit {
  self.set("school", item)
}

///|
pub fn Entry::institution(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("institution")
  if res is None {
    let res = self.get("school")
    if res is None {
      Err(Missing("institution"))
    } else {
      let res : String = parse_chunks(res.unwrap()) catch {
        err => return Err(TypeError(err))
      }
      Ok(res)
    }
  } else {
    let res : String = parse_chunks(res.unwrap()) catch {
      err => return Err(TypeError(err))
    }
    Ok(res)
  }
}

///|
pub fn Entry::set_institution(self : Entry, item : String) -> Unit {
  self.set("institution", Type::to_chunks(item))
}

///|
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
pub fn Entry::set_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("date", PermissiveType::to_chunks(item))
  ignore(self.remove("year"))
  ignore(self.remove("month"))
  ignore(self.remove("day"))
}

///|
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
pub fn Entry::set_event_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("eventdate", PermissiveType::to_chunks(item))
  ignore(self.remove("eventyear"))
  ignore(self.remove("eventmonth"))
  ignore(self.remove("eventday"))
}

///|
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
pub fn Entry::set_orig_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("origdate", PermissiveType::to_chunks(item))
  ignore(self.remove("origyear"))
  ignore(self.remove("origmonth"))
  ignore(self.remove("origday"))
}

///|
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
pub fn Entry::set_url_date(self : Entry, item : PermissiveType[Date]) -> Unit {
  self.set("urldate", PermissiveType::to_chunks(item))
  ignore(self.remove("urlyear"))
  ignore(self.remove("urlmonth"))
  ignore(self.remove("urlday"))
}

///|
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
  let editors = editors.map(pe => (pe.0.inner(), pe.1))
  Ok(editors)
}

///|
pub fn Entry::abstract_(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("abstract")
  if res is None {
    return Err(Missing("abstract"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_abstract_(self : Entry, item : Chunks) -> Unit {
  self.set("abstract", item)
}

///|
pub fn Entry::addendum(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("addendum")
  if res is None {
    return Err(Missing("addendum"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_addendum(self : Entry, item : Chunks) -> Unit {
  self.set("addendum", item)
}

///|
pub fn Entry::afterword(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("afterword")
  if res is None {
    return Err(Missing("afterword"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_afterword(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("afterword", item.to_chunks())
}

///|
pub fn Entry::annotator(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("annotator")
  if res is None {
    return Err(Missing("annotator"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_annotator(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("annotator", item.to_chunks())
}

///|
pub fn Entry::author_type(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("authortype")
  if res is None {
    return Err(Missing("authortype"))
  }
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
pub fn Entry::set_author_type(self : Entry, item : String) -> Unit {
  self.set("authortype", Type::to_chunks(item))
}

///|
pub fn Entry::book_author(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("bookauthor")
  if res is None {
    return Err(Missing("bookauthor"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_book_author(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("bookauthor", item.to_chunks())
}

///|
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
pub fn Entry::set_book_pagination(self : Entry, item : Pagination) -> Unit {
  self.set("bookpagination", Type::to_chunks(item))
}

///|
pub fn Entry::book_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("booksubtitle")
  if res is None {
    return Err(Missing("booksubtitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_book_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("booksubtitle", item)
}

///|
pub fn Entry::book_title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("booktitleaddon")
  if res is None {
    return Err(Missing("booktitleaddon"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_book_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("booktitleaddon", item)
}

///|
pub fn Entry::commentator(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("commentator")
  if res is None {
    return Err(Missing("commentator"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_commentator(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("commentator", item.to_chunks())
}

///|
pub fn Entry::doi(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("doi")
  if res is None {
    return Err(Missing("doi"))
  }
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
pub fn Entry::set_doi(self : Entry, item : String) -> Unit {
  self.set("doi", Type::to_chunks(item))
}

///|
pub fn Entry::eid(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eid")
  if res is None {
    return Err(Missing("eid"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_eid(self : Entry, item : Chunks) -> Unit {
  self.set("eid", item)
}

///|
pub fn Entry::entry_subtype(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("entrysubtype")
  if res is None {
    return Err(Missing("entrysubtype"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_entry_subtype(self : Entry, item : Chunks) -> Unit {
  self.set("entrysubtype", item)
}

///|
pub fn Entry::eprint(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("eprint")
  if res is None {
    return Err(Missing("eprint"))
  }
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
pub fn Entry::set_eprint(self : Entry, item : String) -> Unit {
  self.set("eprint", Type::to_chunks(item))
}

///|
pub fn Entry::eventtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eventtitle")
  if res is None {
    return Err(Missing("eventtitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_eventtitle(self : Entry, item : Chunks) -> Unit {
  self.set("eventtitle", item)
}

///|
pub fn Entry::eventtitle_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("eventtitleaddon")
  if res is None {
    return Err(Missing("eventtitleaddon"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_eventtitle_addon(self : Entry, item : Chunks) -> Unit {
  self.set("eventtitleaddon", item)
}

///|
pub fn Entry::foreword(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("foreword")
  if res is None {
    return Err(Missing("foreword"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_foreword(self : Entry, item : Chunks) -> Unit {
  self.set("foreword", item)
}

///|
pub fn Entry::holder(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("holder")
  if res is None {
    return Err(Missing("holder"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_holder(self : Entry, item : Chunks) -> Unit {
  self.set("holder", item)
}

///|
pub fn Entry::index_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("indextitle")
  if res is None {
    return Err(Missing("indextitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_index_title(self : Entry, item : Chunks) -> Unit {
  self.set("indextitle", item)
}

///|
pub fn Entry::introduction(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("introduction")
  if res is None {
    return Err(Missing("introduction"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_introduction(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("introduction", item.to_chunks())
}

///|
pub fn Entry::isan(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("isan")
  if res is None {
    return Err(Missing("isan"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_isan(self : Entry, item : Chunks) -> Unit {
  self.set("isan", item)
}

///|
pub fn Entry::isbn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("isbn")
  if res is None {
    return Err(Missing("isbn"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_isbn(self : Entry, item : Chunks) -> Unit {
  self.set("isbn", item)
}

///|
pub fn Entry::ismn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("ismn")
  if res is None {
    return Err(Missing("ismn"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_ismn(self : Entry, item : Chunks) -> Unit {
  self.set("ismn", item)
}

///|
pub fn Entry::isrn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("isrn")
  if res is None {
    return Err(Missing("isrn"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_isrn(self : Entry, item : Chunks) -> Unit {
  self.set("isrn", item)
}

///|
pub fn Entry::issn(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issn")
  if res is None {
    return Err(Missing("issn"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_issn(self : Entry, item : Chunks) -> Unit {
  self.set("issn", item)
}

///|
pub fn Entry::issue(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issue")
  if res is None {
    return Err(Missing("issue"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_issue(self : Entry, item : Chunks) -> Unit {
  self.set("issue", item)
}

///|
pub fn Entry::issue_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issuesubtitle")
  if res is None {
    return Err(Missing("issuesubtitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_issue_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("issuesubtitle", item)
}

///|
pub fn Entry::issue_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issuetitle")
  if res is None {
    return Err(Missing("issuetitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_issue_title(self : Entry, item : Chunks) -> Unit {
  self.set("issuetitle", item)
}

///|
pub fn Entry::issue_title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("issuetitleaddon")
  if res is None {
    return Err(Missing("issuetitleaddon"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_issue_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("issuetitleaddon", item)
}

///|
pub fn Entry::iswc(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("iswc")
  if res is None {
    return Err(Missing("iswc"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_iswc(self : Entry, item : Chunks) -> Unit {
  self.set("iswc", item)
}

///|
pub fn Entry::journal_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("journalsubtitle")
  if res is None {
    return Err(Missing("journalsubtitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_journal_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("journalsubtitle", item)
}

///|
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
pub fn Entry::set_journal_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("journaltitleaddon", item)
}

///|
pub fn Entry::keywords(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("keywords")
  if res is None {
    return Err(Missing("keywords"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_keywords(self : Entry, item : Chunks) -> Unit {
  self.set("keywords", item)
}

///|
pub fn Entry::label(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("label")
  if res is None {
    return Err(Missing("label"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_label(self : Entry, item : Chunks) -> Unit {
  self.set("label", item)
}

///|
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
pub fn Entry::set_langid(self : Entry, item : PermissiveType[Language]) -> Unit {
  self.set("langid", PermissiveType::to_chunks(item))
}

///|
pub fn Entry::language(
  self : Entry,
) -> Result[Array[PermissiveType[Language]], RetrievalError] {
  let res = self.get("language")
  if res is None {
    return Err(Missing("language"))
  }
  let res : Array[PermissiveType[Language]] = Type::from_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
pub fn Entry::set_language(
  self : Entry,
  item : Array[PermissiveType[Language]],
) -> Unit {
  self.set("language", Type::to_chunks(item))
}

///|
pub fn Entry::library(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("library")
  if res is None {
    return Err(Missing("library"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_library(self : Entry, item : Chunks) -> Unit {
  self.set("library", item)
}

///|
pub fn Entry::main_subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("mainsubtitle")
  if res is None {
    return Err(Missing("mainsubtitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_main_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("mainsubtitle", item)
}

///|
pub fn Entry::main_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("maintitle")
  if res is None {
    return Err(Missing("maintitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_main_title(self : Entry, item : Chunks) -> Unit {
  self.set("maintitle", item)
}

///|
pub fn Entry::main_title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("maintitleaddon")
  if res is None {
    return Err(Missing("maintitleaddon"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_main_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("maintitleaddon", item)
}

///|
pub fn Entry::name_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("nameaddon")
  if res is None {
    return Err(Missing("nameaddon"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_name_addon(self : Entry, item : Chunks) -> Unit {
  self.set("nameaddon", item)
}

///|
pub fn Entry::options(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("options")
  if res is None {
    return Err(Missing("options"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_options(self : Entry, item : Chunks) -> Unit {
  self.set("options", item)
}

///|
pub fn Entry::orig_language(
  self : Entry,
) -> Result[Array[String], RetrievalError] {
  let res = self.get("origlanguage")
  if res is None {
    return Err(Missing("origlanguage"))
  }
  let res : ArrayString = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_orig_language(self : Entry, item : Array[String]) -> Unit {
  let item : ArrayString = ArrayString(item)
  self.set("origlanguage", item.to_chunks())
}

///|
pub fn Entry::orig_location(
  self : Entry,
) -> Result[Array[Chunks], RetrievalError] {
  let res = self.get("origlocation")
  if res is None {
    return Err(Missing("origlocation"))
  }
  let res : ArrayChunks = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_orig_location(self : Entry, item : Array[Chunks]) -> Unit {
  let item : ArrayChunks = ArrayChunks(item)
  self.set("origlocation", item.to_chunks())
}

///|
pub fn Entry::page_total(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("pagetotal")
  if res is None {
    return Err(Missing("pagetotal"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_page_total(self : Entry, item : Chunks) -> Unit {
  self.set("pagetotal", item)
}

///|
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
pub fn Entry::set_pagination(self : Entry, item : Pagination) -> Unit {
  self.set("pagination", Type::to_chunks(item))
}

///|
pub fn Entry::part(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("part")
  if res is None {
    return Err(Missing("part"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_part(self : Entry, item : Chunks) -> Unit {
  self.set("part", item)
}

///|
pub fn Entry::pubstate(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("pubstate")
  if res is None {
    return Err(Missing("pubstate"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_pubstate(self : Entry, item : Chunks) -> Unit {
  self.set("pubstate", item)
}

///|
pub fn Entry::reprint_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("reprinttitle")
  if res is None {
    return Err(Missing("reprinttitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_reprint_title(self : Entry, item : Chunks) -> Unit {
  self.set("reprinttitle", item)
}

///|
pub fn Entry::short_author(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("shortauthor")
  if res is None {
    return Err(Missing("shortauthor"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_short_author(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("shortauthor", item.to_chunks())
}

///|
pub fn Entry::short_editor(
  self : Entry,
) -> Result[Array[Person], RetrievalError] {
  let res = self.get("shorteditor")
  if res is None {
    return Err(Missing("shorteditor"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_short_editor(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("shorteditor", item.to_chunks())
}

///|
pub fn Entry::shorthand(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shorthand")
  if res is None {
    return Err(Missing("shorthand"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_shorthand(self : Entry, item : Chunks) -> Unit {
  self.set("shorthand", item)
}

///|
pub fn Entry::shorthand_intro(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shorthandintro")
  if res is None {
    return Err(Missing("shorthandintro"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_shorthand_intro(self : Entry, item : Chunks) -> Unit {
  self.set("shorthandintro", item)
}

///|
pub fn Entry::short_journal(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shortjournal")
  if res is None {
    return Err(Missing("shortjournal"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_short_journal(self : Entry, item : Chunks) -> Unit {
  self.set("shortjournal", item)
}

///|
pub fn Entry::short_series(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shortseries")
  if res is None {
    return Err(Missing("shortseries"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_short_series(self : Entry, item : Chunks) -> Unit {
  self.set("shortseries", item)
}

///|
pub fn Entry::short_title(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("shorttitle")
  if res is None {
    return Err(Missing("shorttitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_short_title(self : Entry, item : Chunks) -> Unit {
  self.set("shorttitle", item)
}

///|
pub fn Entry::subtitle(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("subtitle")
  if res is None {
    return Err(Missing("subtitle"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_subtitle(self : Entry, item : Chunks) -> Unit {
  self.set("subtitle", item)
}

///|
pub fn Entry::title_addon(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("titleaddon")
  if res is None {
    return Err(Missing("titleaddon"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_title_addon(self : Entry, item : Chunks) -> Unit {
  self.set("titleaddon", item)
}

///|
pub fn Entry::translator(self : Entry) -> Result[Array[Person], RetrievalError] {
  let res = self.get("translator")
  if res is None {
    return Err(Missing("translator"))
  }
  let res : ArrayPerson = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res.inner())
}

///|
pub fn Entry::set_translator(self : Entry, item : Array[Person]) -> Unit {
  let item : ArrayPerson = ArrayPerson(item)
  self.set("translator", item.to_chunks())
}

///|
pub fn Entry::url(self : Entry) -> Result[String, RetrievalError] {
  let res = self.get("url")
  if res is None {
    return Err(Missing("url"))
  }
  let res : String = parse_chunks(res.unwrap()) catch {
    err => return Err(TypeError(err))
  }
  Ok(res)
}

///|
pub fn Entry::set_url(self : Entry, item : String) -> Unit {
  self.set("url", Type::to_chunks(item))
}

///|
pub fn Entry::venue(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("venue")
  if res is None {
    return Err(Missing("venue"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_venue(self : Entry, item : Chunks) -> Unit {
  self.set("venue", item)
}

///|
pub fn Entry::version(self : Entry) -> Result[Chunks, RetrievalError] {
  let res = self.get("version")
  if res is None {
    return Err(Missing("version"))
  }
  Ok(res.unwrap())
}

///|
pub fn Entry::set_version(self : Entry, item : Chunks) -> Unit {
  self.set("version", item)
}

///|
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
pub fn Entry::set_volumes(self : Entry, item : Int64) -> Unit {
  self.set("volumes", Type::to_chunks(item))
}

///|
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
pub fn Entry::set_gender(self : Entry, item : Gender) -> Unit {
  self.set("gender", Type::to_chunks(item))
}
