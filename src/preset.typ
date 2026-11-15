// src/preset.typ
// 預設格式（preset）：各期刊的版面預設值。paper 的 preset 參數以縮寫選擇其一；
// 使用者明確傳入的參數一律優先於 preset 的值。
//
// 引註格式由 CSL 處理；preset 只處理版面。

#import "@local/yuhina:0.1.0": font-hei, font-kai, font-song

// 泛用格式（preset: none）
#let generic = (
  // 中文摘要標題；none 時以一般無編號標題置中輸出，字型同其他標題
  abstract-title: none,
  // 中文關鍵字：label-font、label-weight 用於「關鍵字：」，body-font 用於各關鍵字
  // （none 沿用內文字型）。各 preset 的關鍵字行一律凸排。
  keywords: (label-font: font-hei, label-weight: "bold", body-font: none),
  // 文章標題（含副標題）：字型、粗細
  title: (font: font-hei, weight: "bold"),
  // 標題：字型、粗細，以及第一層起各層的字級（未列出的層級沿用內文字級）
  heading: (font: font-hei, weight: "bold", sizes: ()),
  // 註腳：label-font 為註腳編號（內文的上標與頁底的編號）的字型；size、line-height 為
  // 字級與行高（相鄰基線的距離），none 沿用 yuhina 的設定
  footnote: (label-font: font-hei, size: none, line-height: none),
  // 參考文獻分組的順序；"other" 為其他外文
  bib-order: ("en", "ja", "de", "fr", "other", "zh"),
)

// 各期刊的 preset：以泛用格式為基礎，只覆寫不同之處。
#let presets = (
  // 《臺大法學論叢》NTULJ
  ntulj: generic
    + (
      abstract-title: text(font: font-kai, size: 13pt, weight: "regular", "<摘要>"),
      keywords: (label-font: font-kai, label-weight: "regular", body-font: font-kai),
      footnote: (label-font: font-song, size: none, line-height: none),
    ),
  // 《臺北大學法學論叢》/ Taipei University Law Review
  // 文章標題與各層標題皆為標楷體不加粗；標題「壹、」為 18 級、「一、」為 14 級，
  // 其餘為內文字級；引註為新細明體 9 級、最小行高 12pt；中日文參考文獻在前。
  ntpu: generic
    + (
      title: (font: font-kai, weight: "regular"),
      heading: (font: font-kai, weight: "regular", sizes: (18pt, 14pt)),
      footnote: (label-font: font-song, size: 9pt, line-height: 12pt),
      bib-order: ("zh", "ja", "en", "de", "fr", "other"),
    ),
)

// 依 preset 參數取得設定；none 為泛用格式。
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
