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
  // 雙數頁頁首於頁碼後輸出的字串 / Text after the page number in even-page headers
  even-header: none,
  // 中文摘要標題；none 時以一般無編號標題置中輸出，字型同其他標題
  // The Chinese abstract heading; none centers it as an ordinary unnumbered
  // heading, in the same font as the other headings
  abstract-title: none,
  // 中文關鍵字：label-font 用於「關鍵字：」，body-font 用於各關鍵字（none 沿用內文字型）；
  // hanging 為 true 時採凸排（首行凸出、續行對齊關鍵字），否則與內文同樣首行縮排
  // Chinese keywords: label-font for 關鍵字：, body-font for the keywords
  // (none keeps the body font); hanging sets a hanging indent so that wrapped
  // lines align with the first keyword, otherwise the line is indented like
  // body text
  keywords: (label-font: font-hei, body-font: none, hanging: false),
  // 參考文獻分組的順序；"other" 為其他外文 / Order of bibliography groups; "other" is any other language
  bib-order: ("en", "ja", "de", "fr", "other", "zh"),
)

// 各期刊的 preset：以泛用格式為基礎，只覆寫不同之處。
// Journal presets: the generic layout with their differences on top.
#let presets = (
  // 《臺大法學論叢》/ National Taiwan University Law Journal
  ntulj: generic
    + (
      even-header: "臺大法學論叢",
      abstract-title: text(font: font-kai, size: 13pt, weight: "regular", "<摘要>"),
      keywords: (label-font: font-kai, body-font: font-kai, hanging: false),
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
