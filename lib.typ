// lib.typ
// flamegold 的入口檔：只匯出下列公開名稱，其餘皆為內部實作，日後可能變動。
//
//   #import "@local/flamegold:0.1.0": *
//   #show: paper.with(bib: path("ref.bib"), csl: read("style.csl"), ...)

// 主函式 & 引註函式
#import "src/paper.typ": ncite, ncitef, paper

// 字型、行內引用與重點強調，皆沿用 yuhina 之設定（含替補字型），與 bluemagpie 一致
#import "@local/yuhina:0.1.0": font-fsong, font-hei, font-kai, font-song, font-yuan, inquote, keyword
