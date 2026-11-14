// src/fonts.typ
// 字體組合：在 yuhina 的字型之後加上替補字型。
// Font stacks: yuhina's fonts followed by fallbacks.
//
// 新細明體、標楷體、微軟正黑體是 Windows 隨附的商用字型，Typst web app 與
// macOS、Linux 通常沒有。缺少時，Typst 依序改用清單中下一個字型：
//   - 宋體（明體）：Noto Serif TC，其次 Noto Serif CJK TC
//   - 黑體：Noto Sans TC，其次 Noto Sans CJK TC
//   - 楷體：教育部標準楷書（TW-MOE-Std-Kai）
// Noto Serif TC 與 Noto Sans TC 是 Google Fonts 發行的版本；Typst web app 預裝的是
// 同一字型的 Pan-CJK 版本，名稱帶有 CJK，因此兩種名稱都列入。web app 也預裝教育部標準楷書。
// PMingLiU, DFKai-SB and Microsoft JhengHei are commercial fonts that ship with
// Windows; the Typst web app, macOS and Linux usually lack them. When one is
// missing, Typst moves on to the next font in the list: Noto Serif TC, then
// Noto Serif CJK TC, for Ming; Noto Sans TC, then Noto Sans CJK TC, for sans;
// and the Ministry of Education standard Kai (TW-MOE-Std-Kai) for Kai. Noto
// Serif TC and Noto Sans TC are the Google Fonts releases; the Typst web app
// ships the Pan-CJK releases of the same fonts, whose names include CJK, so
// both names are listed. The web app also ships TW-MOE-Std-Kai.

#let font-song = ("Times New Roman", "PMingLiU", "Noto Serif TC", "Noto Serif CJK TC")
#let font-hei = ("Arial", "Microsoft JhengHei UI", "Noto Sans TC", "Noto Sans CJK TC")
#let font-kai = ("Times New Roman", "DFKai-SB", "TW-MOE-Std-Kai")
// 筆記用字型，為與 yuhina 相容而保留 / Note fonts, kept for compatibility with yuhina
#let font-yuan = ("TaiwanPearl", "Arial", "Microsoft JhengHei UI", "Noto Sans TC", "Noto Sans CJK TC")
#let font-fsong = ("Zhuque Fangsong (technical preview)", "Times New Roman", "PMingLiU", "Noto Serif TC", "Noto Serif CJK TC")

// 行內引用（楷體）；與 yuhina 的 inquote 相同，但使用上列替補字型。
// Inline quoting in Kai; the same as yuhina's inquote, with the fallbacks above.
#let inquote(content) = {
  set text(font: font-kai)
  content
}
