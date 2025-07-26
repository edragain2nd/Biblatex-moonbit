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
} derive(Show,Eq)

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

test "aliases"{
  assert_eq(Language::from_str("english"),Some(Language::EnglishUS))
  assert_eq(Language::from_str("portuges"),Some(Language::Portuguese))
}