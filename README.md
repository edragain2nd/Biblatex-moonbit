# Biblatex

A moonbit cake for parsing and writing BibTeX and BibLaTeX files.

This moonbit implementation is derived from the Rust version [rust-biblatex](https://github.com/typst/biblatex)

BibLaTeX can help you to parse .bib bibliography files. As opposed to other available crates, this crate attempts to parse the data within the fields into easily usable structs and enums like Person and Date for downstream consumption.

## Usage

Parsing a bibliography and getting the author of an item is as simple as:

```moonbit
  let src : String = "@book{tolkien1937, author = {J. R. R. Tolkien}}"
  let biblliography = Bibliography::parse(src).unwrap()
  let entry = biblliography.get("tolkien1937").unwrap()
  let author = entry.author().unwrap()
  assert_eq(author[0].name, "Tolkien")
```

This library operates on a `Bibliography` struct, which is a collection of entries (the items in your `.bib` file that start with an `@` and are wrapped in curly braces). The entries may hold multiple fields. Entries have getter methods for each of the possible fields in a Bib(La)TeX file which handle possible field aliases, composition and type conversion automatically.