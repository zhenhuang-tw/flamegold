# typst-ntulj

A Traditional Chinese template for journal papers in [Typst](https://typst.app/), modeled on the National Taiwan University Law Journal (臺大法學論叢): bilingual cover, abstracts, outline, note-style CSL citations, and a bibliography grouped by language and type.

Fonts, inline styles, footnotes, and heading numbering come from `common.typ` in [typst-basic-zh](https://github.com/zhenhuang-tw/typst-basic-zh), included as a submodule, so papers look the same as the note templates. Citations use [citrus](https://typst.app/universe/package/citrus), pinned to a fork branch that fixes footnote numbering (`fix/note-number-from-footnote-counter`).

The Chinese README, [README-zh.md](README-zh.md), is the full manual. This file covers the essentials.

## Requirements

1. [Typst](https://github.com/typst/typst#installation) 0.14 or later (required by citrus 0.2.1).
2. The fonts listed in the typst-basic-zh README, except TaiwanPearl and Zhuque Fangsong, which only the note-only `#hypo` and `#thought` use.

Typst downloads `@preview/cuti` and `@preview/citegeist` on first compile.

## Installation

In your paper project root:

```powershell
git submodule add https://github.com/zhenhuang-tw/typst-ntulj.git typst-ntulj
git submodule update --init --recursive
```

This repository has submodules of its own (`typst-basic-zh`, `citrus`), so `--recursive` is required. Without it, `typst-ntulj/typst-basic-zh/` and `typst-ntulj/citrus/` stay empty and compilation fails. Clone the paper project with `git clone --recurse-submodules` for the same reason.

## Quick start

```typ
#import "typst-ntulj/ntulj.typ": *

#show: project.with(
  bib: "/ref.bib",                  // or "/references.json"
  csl: read("law-journals-citation-guide.csl"),
  title: "中小學生參與學校行政的保障",
  authors: (name: "王小明", thanks: "國立臺灣大學法律學系碩士班學生。"),
  abstract-zh: [...],
  keywords-zh: "比例原則",
  title-en: "Protection of Primary and High School Students’ Participation in School Administration",
  abstract-en: [...],
  keywords-en: "Proportionality",
  even-header: "臺大法學論叢",       // optional
)
```

`bib` is a path starting with `/`, which resolves against the project root; its extension decides the format: `.json` is CSL-JSON, anything else is BibTeX. A leading UTF-8 BOM is stripped. `csl` takes the contents of a note-style CSL file read by your document.

Inside a footnote, cite with `#ncite("key", "5", prefix: "...", suffix: "...")` instead of `@key`, which would nest a footnote inside the footnote. `#ncitef(...)` takes the same arguments and is equivalent to `#footnote[#ncite(...)。]`; pass `period: "."` for English sources or `period: none` for no period.

Running heads start on page 2: even pages show the page number and then `even-header` on the left; odd pages show `title` (without subtitle) and then the page number on the right. They use the sans-serif font at regular weight. The centered page number in the footer stays.

The bibliography is grouped into 英文文獻, then 中文文獻 with 期刊論文 and 其他. Empty groups are omitted.

## Inline styles

Of the inline style functions in typst-basic-zh, this template exports only `keyword` and `inquote`. The note-only `very-keyword`, `hypo`, `thought`, and `rightNote` are not available.

## Migrating from typst-basic-zh

Replace `#import "typst-basic-zh/academic-paper.typ": *` with `#import "typst-ntulj/ntulj.typ": *`. `project`, `ncite`, and `ncitef` take the same arguments as before.

## Updating the submodule

```powershell
git submodule update --remote --merge typst-ntulj
git -C typst-ntulj submodule update --init --recursive
git add typst-ntulj
git commit -m "chore(tpl): update typst-ntulj submodule"
```

The second command checks out the versions of `typst-basic-zh` and `citrus` that the new `typst-ntulj` commit pins; `--remote` alone does not. Run it inside `typst-ntulj` as shown: a plain `git submodule update` in the project root, before `git add typst-ntulj`, would move `typst-ntulj` back to the commit the project still records.
