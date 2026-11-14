# flamegold

A Traditional Chinese template for journal papers in [Typst](https://typst.app/), modeled on the National Taiwan University Law Journal (臺大法學論叢): bilingual cover, abstracts, outline, note-style CSL citations, and a bibliography grouped by language and type.

Fonts, inline styles, footnotes, and heading numbering come from `common.typ` in [typst-basic-zh](https://github.com/zhenhuang-tw/typst-basic-zh), included as a submodule, so papers look the same as the note templates. Citations use [citrus](https://typst.app/universe/package/citrus), pinned to the `ntu-adapted` branch of a fork that fixes footnote numbering, locator ranges, name variables and `shorttitle`.

The Chinese README, [README-zh.md](README-zh.md), is the full manual. This file covers the essentials.

## Requirements

1. [Typst](https://github.com/typst/typst#installation) 0.15 or later (`bib` takes the `path` type added in 0.15).
2. The fonts listed in the typst-basic-zh README, except TaiwanPearl and Zhuque Fangsong, which only the note-only `#hypo` and `#thought` use.

Typst downloads `@preview/cuti` and `@preview/citegeist` on first compile.

## Installation

In your paper project root:

```powershell
git submodule add https://github.com/zhenhuang-tw/flamegold.git flamegold
git submodule update --init --recursive
```

This repository has submodules of its own (`typst-basic-zh`, `citrus`), so `--recursive` is required. Without it, `flamegold/typst-basic-zh/` and `flamegold/citrus/` stay empty and compilation fails. Clone the paper project with `git clone --recurse-submodules` for the same reason.

## Usage

See the Chinese README, [README-zh.md](README-zh.md) as the full manual.

## Migrating from typst-basic-zh

Replace `#import "typst-basic-zh/academic-paper.typ": *` with `#import "flamegold/lib.typ": *`. The main function is now called `paper` instead of `project`; `ncite` and `ncitef` are unchanged.

## Updating the submodule

```powershell
git submodule update --remote --merge flamegold
git -C flamegold submodule update --init --recursive
git add flamegold
git commit -m "chore(tpl): update flamegold submodule"
```

The second command checks out the versions of `typst-basic-zh` and `citrus` that the new `flamegold` commit pins; `--remote` alone does not. Run it inside `flamegold` as shown: a plain `git submodule update` in the project root, before `git add flamegold`, would move `flamegold` back to the commit the project still records.
