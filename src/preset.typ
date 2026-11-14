// src/preset.typ
// 預設格式（preset）：各期刊的版面預設值。paper 的 preset 參數以縮寫選擇其一；
// 使用者明確傳入的參數一律優先於 preset 的值。
// Presets: layout defaults for each journal. paper's preset parameter picks one
// by its short id; parameters the user passes always win over the preset.
//
// 引註格式依國科會《法學期刊引註格式凡例》，各期刊差異不大，由 CSL 處理；
// preset 只處理版面。
// Citations follow the NSTC citation guide shared by Taiwanese law journals and
// are left to the CSL style; presets only handle the layout.

#import "fonts.typ": font-hei, font-kai, font-song

// 泛用格式（preset: none），接近臺灣頂尖大學法學院的出版品。
// The generic layout (preset: none), close to the publications of Taiwan's
// leading law schools.
#let generic = (
  // 中文摘要標題；none 時以一般無編號標題置中輸出，字型同其他標題
  // The Chinese abstract heading; none centers it as an ordinary unnumbered
  // heading, in the same font as the other headings
  abstract-title: none,
  // 中文關鍵字：label-font、label-weight 用於「關鍵字：」，body-font 用於各關鍵字
  // （none 沿用內文字型）。各 preset 的關鍵字行一律凸排。
  // Chinese keywords: label-font and label-weight for 關鍵字：, body-font for
  // the keywords (none keeps the body font). Every preset sets the keywords line
  // with a hanging indent.
  keywords: (label-font: font-hei, label-weight: "bold", body-font: none),
  // 標題：字型、粗細，以及第一層起各層的字級（未列出的層級沿用內文字級）
  // Headings: font, weight, and font sizes from level 1 down (levels not listed
  // keep the body size)
  heading: (font: font-hei, weight: "bold", sizes: ()),
  // 註腳：label-font 為註腳編號（內文的上標與頁底的編號）的字型；size、line-height 為
  // 字級與行高（相鄰基線的距離），none 沿用 yuhina 的設定
  // Footnotes: label-font for footnote numbers (the superscripts in the text
  // and the numbers at the bottom); size and line-height for the font size and
  // the line height (distance between baselines), where none keeps yuhina's
  // settings
  footnote: (label-font: font-hei, size: none, line-height: none),
  // 參考文獻分組的順序；"other" 為其他外文 / Order of bibliography groups; "other" is any other language
  bib-order: ("en", "ja", "de", "fr", "other", "zh"),
)

// 各期刊的 preset：以泛用格式為基礎，只覆寫不同之處。
// Journal presets: the generic layout with their differences on top.
#let presets = (
  // 《臺大法學論叢》/ National Taiwan University Law Journal
  ntulj: generic
    + (
      abstract-title: text(font: font-kai, size: 13pt, weight: "regular", "<摘要>"),
      keywords: (label-font: font-kai, label-weight: "regular", body-font: font-kai),
      footnote: (label-font: font-song, size: none, line-height: none),
    ),
  // 《臺北大學法學論叢》/ Taipei University Law Review
  // 依該刊〈投稿論文參考格式〉：標題「壹、」為標楷體 18 級、「一、」為標楷體 14 級，其餘
  // 標題為標楷體；引註為新細明體 9 級、最小行高 12pt；中日文參考文獻在前。「級」即 Word
  // 的點（pt）。
  // Following the review's submission guidelines: 壹、 headings in Kai at 18pt,
  // 一、 headings in Kai at 14pt, other headings in Kai; footnotes in Ming at
  // 9pt with a 12pt minimum line height; Chinese and Japanese references first.
  ntpu: generic
    + (
      heading: (font: font-kai, weight: "regular", sizes: (18pt, 14pt)),
      footnote: (label-font: font-song, size: 9pt, line-height: 12pt),
      bib-order: ("zh", "ja", "en", "de", "fr", "other"),
    ),
)

// 依 preset 參數取得設定；none 為泛用格式。
// The settings for a preset parameter; none is the generic layout.
#let resolve-preset(preset) = {
  if preset == none { return generic }
  assert(
    type(preset) == str and preset in presets,
    message: "flamegold: preset 只接受 none 或 "
      + presets.keys().map(k => "\"" + k + "\"").join("、")
      + " / preset must be none or one of "
      + presets.keys().map(k => "\"" + k + "\"").join(", "),
  )
  presets.at(preset)
}
