// src/footnote.typ
// 註腳：與 yuhina 的 footnote-style 相同（文內標籤黑體上標、頁底懸掛縮排），另可指定
// 字級與固定行高，供 preset 使用。
// Footnotes: the same as yuhina's footnote-style (sans superscript labels in the
// text, hanging indent at the bottom), plus a font size and a line height for
// presets.

#import "fonts.typ": font-hei, font-song

// - size：註腳文字的字級；none 沿用 Typst 預設的註腳字級。
//   Font size of footnote text; none keeps Typst's default footnote size.
// - line-height：行高，即相鄰兩行基線的距離，例如 12pt；none 沿用 yuhina 的行距。
//   設定時，各則註腳之間也採相同行高，模仿 Word 的「最小行高」。
//   Line height, the distance between adjacent baselines, e.g. 12pt; none keeps
//   yuhina's spacing. When set, consecutive footnotes are spaced the same way,
//   imitating Word's "at least" line spacing.
#let footnote-style(font: font-song, label-font: font-hei, size: none, line-height: none, body) = {
  show footnote: set text(font: label-font)
  // 有 line-height 時，各則註腳之間（以及分隔線與第一則之間）只留行距，使行高一致。
  // footnote.entry 的 gap 在註腳區之外解析，所以 em 以內文字級計算；size 有值時改用它。
  // With line-height, footnotes (and the separator and the first footnote) are
  // spaced by the leading only, so the line height stays the same. The gap of
  // footnote.entry resolves outside the footnote area, where em is the body
  // size, so size is used when given.
  let entry-gap = if line-height == none { 0.5em } else { line-height - if size != none { size } else { 1em } }
  set footnote.entry(gap: entry-gap) if line-height != none

  show footnote.entry: it => {
    set text(font: font, weight: "regular")
    set text(size: size) if size != none
    // 行盒固定為 1em（中日文字身框），再以行距補足行高；較高的行內內容仍會撐開該行。
    // A 1em line box (the CJK em box) plus leading makes up the line height;
    // taller inline content still makes its line taller.
    set text(top-edge: 0.88em, bottom-edge: -0.12em) if line-height != none
    let leading = if line-height == none { 0.9em } else { line-height - 1em }
    set par(leading: leading, spacing: leading)

    let loc = it.note.location()

    // 以 grid 切兩欄實現懸掛縮排；以 block 的 bottom inset 控制註腳間距
    // A two-column grid gives the hanging indent; the block's bottom inset sets spacing between footnotes
    block(
      width: 100%,
      inset: (bottom: if line-height == none { 0.6em } else { 0pt }),
      grid(
        columns: (1.25em, 1fr),
        // 左欄放編號、右欄放內文 / Left: number, right: body
        text(font: label-font)[#super[#counter(footnote).display(at: loc)]], it.note.body,
      ),
    )
  }

  body
}
