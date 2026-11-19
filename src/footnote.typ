// src/footnote.typ
// 註腳：與 yuhina 的 footnote-style 相同（文內標籤黑體上標、頁底懸掛縮排），另可指定
// 字級與固定行高，供 preset 使用。

#import "@local/yuhina:0.1.0": font-hei, font-song

// 移除註腳內文中「CJK 字元或全形標點之後」的換行空白。
// 原始碼中 CJK 文字之間的換行會被 Typst 當成空白（typst#792），例如
//   #ncite("甲")；
//   #ncite("乙")
// 會排成「甲；␣乙」。cjk-unbreak 等套件只處理兩個 text 元素之間的空白，
// 而 ncite 輸出的是 cite 元素，所以在此自行處理：
// 若空白的前一個子元素是 text，且以 CJK 字元或全形標點結尾，就略去該空白。
// 前一個子元素以拉丁字母結尾時（例如英文單字之間的換行）保留空白。
// 限制：只處理最外層的子元素，不深入 strong、emph 等元素內部。
#let cjk-break-end = regex("[\p{Han}\p{Bopomofo}\u{3000}-\u{303F}\u{FF00}-\u{FFEF}…—]$")
#let strip-cjk-break(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let children = body.children
  let out = ()
  for (i, child) in children.enumerate() {
    let prev = if i > 0 { children.at(i - 1) } else { none }
    let after-cjk = (
      prev != none and prev.func() == text and prev.text.contains(cjk-break-end)
    )
    if child == [ ] and after-cjk { continue }
    out.push(child)
  }
  out.sum(default: [])
}

// - size：註腳文字的字級；none 沿用 Typst 預設的註腳字級。
// - line-height：行高，即相鄰兩行基線的距離，例如 12pt；none 沿用 yuhina 的行距。
//   設定時，各則註腳之間也採相同行高，模仿 Word 的「最小行高」。
#let footnote-style(font: font-song, label-font: font-hei, size: none, line-height: none, body) = {
  show footnote: set text(font: label-font)
  // 有 line-height 時，各則註腳之間（以及分隔線與第一則之間）只留行距，使行高一致。
  // footnote.entry 的 gap 在註腳區之外解析，所以 em 以內文字級計算；size 有值時改用它。
  let entry-gap = if line-height == none { 0.5em } else { line-height - if size != none { size } else { 1em } }
  set footnote.entry(gap: entry-gap) if line-height != none

  show footnote.entry: it => {
    set text(font: font, weight: "regular")
    set text(size: size) if size != none
    // 行盒固定為 1em (the CJK em box) 再以行距補足行高；較高的行內內容仍會撐開該行。
    set text(top-edge: 0.88em, bottom-edge: -0.12em) if line-height != none
    let leading = if line-height == none { 0.9em } else { line-height - 1em }
    set par(leading: leading, spacing: leading)

    let loc = it.note.location()

    // 以 grid 切兩欄實現懸掛縮排；以 block 的 bottom inset 控制註腳間距
    block(
      width: 100%,
      inset: (bottom: if line-height == none { 0.6em } else { 0pt }),
      grid(
        columns: (1.25em, 1fr),
        // Left: number, right: 內文
        text(font: label-font)[#super[#counter(footnote).display(at: loc)]], strip-cjk-break(it.note.body),
      ),
    )
  }

  body
}
