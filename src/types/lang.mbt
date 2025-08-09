///|
pub(all) enum Language {
  Basque
  Bulgarian
  Catalan
  Croatian
  Czech
  Danish
  Dutch
  EnglishUS
  EnglishUK
  EnglishCA
  EnglishAUS
  EnglishNZ
  Estonian
  Finnish
  French
  German
  GermanAT
  GermanCH
  GermanNew
  GermanATNew
  GermanCHNew
  Greek
  Hungarian
  Icelandic
  Italian
  Latvian
  Lithuanian
  Marathi
  NorwegianBokmal
  NorwegainNynorsk
  Polish
  PortugueseBR
  Portuguese
  Romanian
  Russian
  SerbianLatin
  SerbianCyrillic
  Slovak
  Slovene
  Spanish
  Swedish
  Turkish
  Ukrainian
} derive(Show, Eq)

///|
pub fn Language::from_str(s : String) -> Language? {
  match s {
    "basque" => Some(Basque)
    "bulgarian" => Some(Bulgarian)
    "catalan" => Some(Catalan)
    "croatian" => Some(Croatian)
    "czech" => Some(Czech)
    "danish" => Some(Danish)
    "dutch" => Some(Dutch)
    "american" | "usenglish" | "english" => Some(EnglishUS)
    "british" | "ukenglish" => Some(EnglishUK)
    "canadian" => Some(EnglishCA)
    "australian" => Some(EnglishAUS)
    "newzealand" => Some(EnglishNZ)
    "estonian" => Some(Estonian)
    "finnish" => Some(Finnish)
    "french" => Some(French)
    "german" => Some(German)
    "austrian" => Some(GermanAT)
    "swissgerman" => Some(GermanCH)
    "ngerman" => Some(GermanNew)
    "naustrian" => Some(GermanATNew)
    "nswissgerman" => Some(GermanCHNew)
    "greek" => Some(Greek)
    "magyar" | "hungarian" => Some(Hungarian)
    "icelandic" => Some(Icelandic)
    "italian" => Some(Italian)
    "latvian" => Some(Latvian)
    "lithuanian" => Some(Lithuanian)
    "marathi" => Some(Marathi)
    "norsk" => Some(NorwegianBokmal)
    "nynorsk" => Some(NorwegainNynorsk)
    "polish" => Some(Polish)
    "brazil" => Some(PortugueseBR)
    "portuguese" | "portuges" => Some(Portuguese)
    "romanian" => Some(Romanian)
    "russian" => Some(Russian)
    "serbian" => Some(SerbianLatin)
    "serbianc" => Some(SerbianCyrillic)
    "slovak" => Some(Slovak)
    "slovene" | "slovenian" => Some(Slovene)
    "spanish" => Some(Spanish)
    "swedish" => Some(Swedish)
    "turkish" => Some(Turkish)
    "ukrainian" => Some(Ukrainian)
    _ => None
  }
}

///|
pub impl Type for Language with from_chunks(chunks) {
  let span = ChunkExt::span(chunks)
  let language = Language::from_str(ChunkExt::format_verbatim(chunks))
  if language is Some(language) {
    language
  } else {
    raise TypeError((span, UnknownLangId))
  }
}

///|
pub impl Type for Language with to_chunks(self) {
  [Spanned::detached(Chunk::Verbatim(self.to_string()))]
}

///|
test "aliases" {
  assert_eq(Language::from_str("english"), Some(Language::EnglishUS))
  assert_eq(Language::from_str("portuges"), Some(Language::Portuguese))
}

///|
test "test_language" {
  assert_eq(Language::from_str("basque"), Some(Language::Basque))
  assert_eq(Language::from_str("bulgarian"), Some(Language::Bulgarian))
  assert_eq(Language::from_str("catalan"), Some(Language::Catalan))
  assert_eq(Language::from_str("croatian"), Some(Language::Croatian))
  assert_eq(Language::from_str("czech"), Some(Language::Czech))
  assert_eq(Language::from_str("danish"), Some(Language::Danish))
  assert_eq(Language::from_str("dutch"), Some(Language::Dutch))
  assert_eq(Language::from_str("american"), Some(Language::EnglishUS))
  assert_eq(Language::from_str("usenglish"), Some(Language::EnglishUS))
  assert_eq(Language::from_str("english"), Some(Language::EnglishUS))
  assert_eq(Language::from_str("british"), Some(Language::EnglishUK))
  assert_eq(Language::from_str("ukenglish"), Some(Language::EnglishUK))
  assert_eq(Language::from_str("canadian"), Some(Language::EnglishCA))
  assert_eq(Language::from_str("australian"), Some(Language::EnglishAUS))
  assert_eq(Language::from_str("newzealand"), Some(Language::EnglishNZ))
  assert_eq(Language::from_str("estonian"), Some(Language::Estonian))
  assert_eq(Language::from_str("finnish"), Some(Language::Finnish))
  assert_eq(Language::from_str("french"), Some(Language::French))
  assert_eq(Language::from_str("german"), Some(Language::German))
  assert_eq(Language::from_str("austrian"), Some(Language::GermanAT))
  assert_eq(Language::from_str("swissgerman"), Some(Language::GermanCH))
  assert_eq(Language::from_str("ngerman"), Some(Language::GermanNew))
  assert_eq(Language::from_str("naustrian"), Some(Language::GermanATNew))
  assert_eq(Language::from_str("nswissgerman"), Some(Language::GermanCHNew))
  assert_eq(Language::from_str("greek"), Some(Language::Greek))
  assert_eq(Language::from_str("magyar"), Some(Language::Hungarian))
  assert_eq(Language::from_str("hungarian"), Some(Language::Hungarian))
  assert_eq(Language::from_str("icelandic"), Some(Language::Icelandic))
  assert_eq(Language::from_str("italian"), Some(Language::Italian))
  assert_eq(Language::from_str("latvian"), Some(Language::Latvian))
  assert_eq(Language::from_str("lithuanian"), Some(Language::Lithuanian))
  assert_eq(Language::from_str("marathi"), Some(Language::Marathi))
  assert_eq(Language::from_str("norsk"), Some(Language::NorwegianBokmal))
  assert_eq(Language::from_str("nynorsk"), Some(Language::NorwegainNynorsk))
  assert_eq(Language::from_str("polish"), Some(Language::Polish))
  assert_eq(Language::from_str("brazil"), Some(Language::PortugueseBR))
  assert_eq(Language::from_str("portuguese"), Some(Language::Portuguese))
  assert_eq(Language::from_str("portuges"), Some(Language::Portuguese))
  assert_eq(Language::from_str("romanian"), Some(Language::Romanian))
  assert_eq(Language::from_str("russian"), Some(Language::Russian))
  assert_eq(Language::from_str("serbian"), Some(Language::SerbianLatin))
  assert_eq(Language::from_str("serbianc"), Some(Language::SerbianCyrillic))
  assert_eq(Language::from_str("slovak"), Some(Language::Slovak))
  assert_eq(Language::from_str("slovene"), Some(Language::Slovene))
  assert_eq(Language::from_str("slovenian"), Some(Language::Slovene))
  assert_eq(Language::from_str("spanish"), Some(Language::Spanish))
  assert_eq(Language::from_str("swedish"), Some(Language::Swedish))
  assert_eq(Language::from_str("turkish"), Some(Language::Turkish))
  assert_eq(Language::from_str("ukrainian"), Some(Language::Ukrainian))
  assert_eq(Language::from_str("unknown"), None)
}

///|
test "test_chunk_ext" {
  let c : Spanned[Chunk] = {
    v: Verbatim("swedish"),
    span: { start: 1, end: 8 },
  }
  let chunks = []
  chunks.push(c)
  let lang : Language = Type::from_chunks(chunks)
  let chunk = lang.to_chunks()
  assert_eq(chunk, [
    { v: Verbatim("Swedish"), span: { start: 2147483647, end: 2147483647 } },
  ])
}

///|
test "panic_from_chunk" {
  let c : Spanned[Chunk] = {
    v: Verbatim("unknown"),
    span: { start: 1, end: 8 },
  }
  let chunks = []
  chunks.push(c)
  let _ : Language = Type::from_chunks(chunks)

}
