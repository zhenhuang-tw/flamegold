// lib.typ
// flamegold 的入口檔：只匯出下列公開名稱，其餘皆為內部實作，日後可能變動。
// Entry point of flamegold: only the names below are public; everything else
// is internal and may change.
//
//   #import "@local/flamegold:0.1.0": *
//   #show: paper.with(bib: path("ref.bib"), csl: read("style.csl"), ...)

// 主函式與引註函式 / Main function and citation functions
#import "src/paper.typ": ncite, ncitef, paper

// 行內樣式與字型，沿用 yuhina / Inline styles and fonts from yuhina
#import "@local/yuhina:0.1.0": (
  font-fsong, font-hei, font-kai, font-song, font-yuan, inquote, keyword,
)
