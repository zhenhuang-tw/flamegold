// src/heading.typ
// 標題編號與交互參照：在 yuhina 的五層編號「壹、一、(一)、1.、(1)」之後加上第六層「①」。
// Heading numbering and cross-references: yuhina's five levels 壹、一、(一)、1.、(1)
// plus a sixth level, ①.

#import "@local/yuhina:0.1.0" as yuhina

// 單一標題的編號；前五層交給 yuhina，第六層為圈號數字「①」。
// The number of one heading; yuhina numbers the first five levels, and the
// sixth uses circled numbers such as ①.
#let heading-number(n) = {
  if n.len() == 6 { numbering("①", n.last()) } else { yuhina.heading-number(n) }
}

// 交互參照用的完整路徑，例如「壹、一、(一)1.(1)①」；去掉結尾的「、」或「.」。
// The full path for cross-references, e.g. 壹、一、(一)1.(1)①, without a
// trailing 、 or ".".
#let heading-path(n) = {
  let parts = range(1, n.len() + 1).map(i => heading-number(n.slice(0, i)))
  parts.filter(p => p != none).map(p => p.trim()).join().trim(regex("[、.]"), at: end)
}

// 套用上列編號，須在 yuhina 的 heading-style 之後套用，才能覆寫其編號。
// Applies the numbering above; it must come after yuhina's heading-style to
// override that numbering.
#let heading-numbering(body) = {
  set heading(numbering: (..nums) => heading-number(nums.pos()))
  body
}

// 交互參照：與 yuhina 的 ref-style 相同，但改用上列 heading-path，第六層才有路徑。
// Cross-references: the same as yuhina's ref-style, but with heading-path above
// so that sixth-level headings get a path too.
#let ref-style(body) = {
  show ref: it => {
    if it.form != "normal" { return it }
    let el = it.element
    if el == none or el.func() != heading or el.numbering == none { return it }
    let path = heading-path(counter(heading).at(el.location()))
    let supplement = if it.supplement == auto { none } else { it.supplement }
    link(el.location(), [#supplement#path])
  }
  body
}
