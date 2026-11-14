// src/paper.typ
// 學術論文模板的實作（仿《臺大法學論叢》）：中英封面、摘要、目錄、note 式 CSL 引註、分類參考文獻。
// 公開介面由 lib.typ 決定；文件請匯入 lib.typ，不要直接匯入本檔。
// Implementation of the paper template, modeled on the National Taiwan University Law Journal:
// bilingual cover, abstracts, outline, note-style CSL citations, and a categorized bibliography.
// lib.typ decides the public interface; documents should import lib.typ, not this file.
//
// 排版規則、註腳與標題編號沿用 yuhina 套件（@local/yuhina），字型則改用 fonts.typ
// 中加上替補字型的版本。
// Style rules, footnotes and heading numbering come from the yuhina package
// (@local/yuhina); fonts come from fonts.typ, which adds fallbacks.

#import "@local/yuhina:0.1.0": (
  document-style, figure-style, footnote-style, heading-style, list-style, normalize-authors, page-style,
  par-style, plain-links, quote-style, render-authors, text-style,
)
#import "fonts.typ": font-hei, font-kai, font-song
#import "heading.typ": heading-numbering, ref-style
// path 型別自 Typst 0.15 起才有 / The path type requires Typst 0.15
#assert(
  sys.version >= version(0, 15, 0),
  message: "flamegold: 需要 Typst 0.15 以上 / requires Typst 0.15 or later",
)

#import "../citrus/lib.typ": csl-bibliography, get-cited-entries, init-csl, init-csl-json, multicite

// ============================================================
// § 腳註內引用指令（非遞迴版）
// § Citations inside footnotes (non-recursive)
//
//   【背景】本模板採用 note 格式 CSL，引用時會自動產生腳註。若在
//   #footnote[...] 內再使用 @key，CSL 會再次插入腳註，造成「遞迴引註」。
//   [Background] With a note-style CSL, every citation produces a
//   footnote. Using @key inside #footnote[...] would nest footnotes.
//
//   【解法】以 cite(form: "prose") 輸出行內格式，不觸發 note-layout。
//   [Fix] cite(form: "prose") renders inline and does not create a footnote.
//
//   【用法 / Usage】
//   #ncite("bibKey")
//   #ncite("bibKey", "5")
//   #ncite("bibKey", "12-19", prefix: "可參照", suffix: "之不同語境")
//
//   【範例 / Example】
//   #footnote[
//     #ncite("WangZeJian2025", "12", prefix: "可參照")；
//     並請比對 #ncite("LiRenMiao2023", "7-13", suffix: "之不同語境")。
//   ]
// ============================================================
#let ncite(bibKey, ..args, prefix: none, suffix: none) = {
  let location = args.pos().at(0, default: none)
  if prefix != none { prefix }
  if location != none {
    cite(label(bibKey), supplement: location, form: "prose")
  } else {
    cite(label(bibKey), form: "prose")
  }
  if suffix != none { suffix }
}

// ============================================================
// § Footnote-citation shorthand
//
//   [Purpose] Equivalent to #footnote[#ncite(...)。]: a footnote that
//   contains exactly one citation.
//
//   【Usage】 Same arguments as ncite, plus period
//   #ncitef("bibKey")
//   #ncitef("bibKey", "5")
//   #ncitef("bibKey", "15-26, 37-48", prefix: "可參照", suffix: "之不同語境")
//   #ncitef(prefix: emph("See")+" ", "schauer2012", "36-54, 85-96", period: ".") // 英文信號詞需自帶空格 English signals need their own space
//   #ncitef("bibKey", "5", period: ".")   // 英文文獻：半形句號 / English source: half-width period
//   #ncitef("bibKey", period: none)          // 不加句號 / No trailing period
//
//   【注意】period 預設為全形「。」，會接在 suffix 之後；
//   若 suffix 已以標點結尾，請傳入 period: none，以免重複。
//   [Note] period defaults to "。" and follows suffix; if suffix already
//   ends with punctuation, pass period: none to avoid doubling.
// ============================================================
#let ncitef(bibKey, ..args, prefix: none, suffix: none, period: "。") = footnote[#ncite(
    bibKey,
    ..args,
    prefix: prefix,
    suffix: suffix,
  )#period]

// ============================================================
// § 頁首用標題 / Title for the running head
// ============================================================
// 只取第一行：字串取第一個換行前的部分；內容取第一個 linebreak（\）前的部分，
// 並去掉結尾空白，以免長標題在頁首折成兩行。
// Keep only the first line: for a string, the part before the first newline; for
// content, the part before the first linebreak (\), without trailing spaces, so
// that a long title does not wrap the running head onto two lines.
#let first-line(title) = {
  if type(title) == str { return title.split("\n").first().trim() }
  if type(title) != content { return title }
  if title.func() == linebreak { return none }
  if not title.has("children") { return title }
  let children = title.children
  let cut = children.position(c => c.func() == linebreak)
  if cut == none { return title }
  let kept = children.slice(0, cut)
  while kept.len() > 0 and kept.last() == [ ] { kept = kept.slice(0, -1) }
  kept.join()
}

// ============================================================
// § 標題區塊 / Title block
// ============================================================
// 與 yuhina 的 title-block 相同，但使用 fonts.typ 的黑體，以便替補字型生效。
// The same as yuhina's title-block, but with the sans stack from fonts.typ so
// that its fallbacks apply.
#let title-block(title, title-thanks: none, subtitle: none, authors: ()) = align(center)[
  #block(
    text(font: font-hei, weight: 700, size: 1.75em)[
      #title#if title-thanks != none and title-thanks != "" { footnote(title-thanks) }
    ],
  )

  #if subtitle != none and subtitle != "" [
    #v(0.5em)
    #block(text(font: font-hei, weight: "bold", size: 1.25em, subtitle))
  ]

  #v(1em)

  #render-authors(authors)
]

// ============================================================
// § 裁判之判斷 / Detecting cases
// ============================================================
// CSL-JSON 的 type 為 legal_case，或 BibTeX 以 mark = {LEGAL_CASE} 標示者（citegeist
// 不認得 @case 等類型，見 README-zh）。
// A CSL-JSON entry of type legal_case, or a BibTeX entry marked with
// mark = {LEGAL_CASE} (citegeist does not recognize @case and similar types).
#let is-case(e) = {
  let fields = e.fields
  let mark = fields.at("mark", default: none)
  (
    fields.at("csl-type", default: none) == "legal_case"
      or (mark != none and upper(str(mark)) == "LEGAL_CASE")
  )
}

// ============================================================
// § 主模板函式
// § Main template function
// ============================================================
#let paper(
  // ── 引註資料（必填）/ Citation data (required) ──
  // bib：書目檔，以 path() 傳入，例如 bib: path("ref.bib")。path() 在呼叫端的檔案中
  //   解析路徑，因此相對路徑以你的文件為準。
  // bib-format：書目格式，"csl-json"、"biblatex"（含 BibTeX）或 "hayagriva"；
  //   預設 auto 依內容判斷：以「[」或「{」開頭者為 CSL-JSON，含「@類型{」條目者為
  //   BibLaTeX，都不是則報錯。"hayagriva" 目前不支援，因 citrus 無法解析 YAML。
  // bib: the bibliography file as a path, e.g. bib: path("ref.bib"). path() resolves
  //   in the caller's file, so relative paths are relative to your document.
  // bib-format: "csl-json", "biblatex" (BibTeX included) or "hayagriva"; the
  //   default, auto, detects it: CSL-JSON if the text starts with "[" or "{",
  //   BibLaTeX if it has "@type{" entries, an error otherwise. "hayagriva" is not
  //   supported yet, because citrus cannot parse YAML.
  // csl：由呼叫端讀檔後傳入內容，例如 csl: read("tssci-q1-law.csl")。
  // csl: file contents read by the caller, e.g. csl: read("style.csl").
  bib: none,
  bib-format: auto,
  csl: none,

  // ── 中文標題區 / Chinese title ──
  title: "",
  title-thanks: none,
  subtitle: none,

  // ── 英文標題區（均得免填）/ English title (all optional) ──
  title-en: none,
  title-en-thanks: none,
  subtitle-en: none,

  // ── 作者 / Authors ──
  authors: (),
  authors-en: (),

  // ── 頁首 / Running head ──
  // 雙數頁頁首於頁碼後輸出的字串，例如期刊名稱 "臺大法學論叢"；none 則只輸出頁碼。
  // Text after the page number in even-page headers, e.g. the journal name; none prints the page number only.
  even-header: none,

  // ── 參考文獻 / Bibliography ──
  // 裁判原則上不列入參考文獻；設為 true 時，依語言列入各分組（中文裁判列於「其他」）。
  // Cases are left out of the bibliography by default; when true, they are listed
  // in their language group (Chinese cases under 其他).
  list-cases: false,

  // ── 摘要與關鍵字 / Abstracts and keywords ──
  abstract-zh: [],
  keywords-zh: none, // 例如 "學生參與、民主國原則、正當行政程序、兒童權利公約、兒童陳述意見的權利"
  abstract-en: [],
  keywords-en: none, // e.g. "Student participation, Principle of the democratic state, Due administrative procedure, Convention on the Rights of the Child, Right of the child to be heard"

  body,
) = {
  assert(
    type(bib) == path,
    message: "flamegold: bib 請以 path() 傳入，例如 bib: path(\"ref.bib\") / pass bib as a path, e.g. bib: path(\"ref.bib\")",
  )
  assert(csl != none, message: "flamegold: 請傳入 csl: read(\"style.csl\") / pass csl: read(\"style.csl\")")

  // 去除開頭的 UTF-8 BOM：Windows 上部分工具（如 Windows PowerShell 5.1 的
  // Out-File -Encoding utf8）會寫入 BOM，citrus 解析 JSON 時會因此失敗。
  // Strip a leading UTF-8 BOM: some Windows tools write one, and citrus
  // then fails to parse the JSON.
  let data = read(bib).trim("\u{feff}", at: start)
  // path 型別無法取得副檔名，改依內容判斷：CSL-JSON 是 JSON 陣列（少數工具輸出物件），
  // BibTeX 則以「@」或註解開頭，不會以「[」「{」開頭。
  // A path has no accessible extension, so detect the format from the contents:
  // CSL-JSON is a JSON array (a few tools write an object), while BibTeX starts
  // with "@" or a comment, never with "[" or "{".
  let formats = ("csl-json", "biblatex", "hayagriva")
  assert(
    bib-format == auto or bib-format in formats,
    message: "flamegold: bib-format 只接受 auto、\"csl-json\"、\"biblatex\"、\"hayagriva\" / bib-format must be auto, \"csl-json\", \"biblatex\" or \"hayagriva\"",
  )
  let format = bib-format
  if format == auto {
    let head = data.trim(at: start)
    let entry = regex("@\\s*[A-Za-z]+\\s*[{(]")
    format = if head.starts-with("[") or head.starts-with("{") {
      "csl-json"
    } else if data.contains(entry) {
      "biblatex"
    } else {
      panic("flamegold: 無法判斷書目格式，請以 bib-format 指定 / cannot detect the bibliography format; set bib-format")
    }
  }
  assert(
    format != "hayagriva",
    message: "flamegold: 目前不支援 Hayagriva YAML，因 citrus 只能解析 BibLaTeX 與 CSL-JSON；請改用這兩種格式 / Hayagriva YAML is not supported yet, because citrus only parses BibLaTeX and CSL-JSON",
  )
  let init = if format == "csl-json" { init-csl-json } else { init-csl }

  // auto-links 會把整筆註腳加上連結到參考文獻區
  // auto-links would link each whole footnote to the bibliography
  show: init.with(data, csl, locales: (:), auto-links: false)

  // 等同 yuhina 的 common-style，但各規則改傳入 fonts.typ 的字型
  // Equivalent to yuhina's common-style, with the fonts from fonts.typ
  show: document-style.with(title: title, authors: authors)
  show: page-style
  show: text-style.with(font: font-song)
  show: par-style
  show: quote-style.with(font: font-kai)
  show: list-style
  show: figure-style.with(font: font-kai)
  show: footnote-style.with(font: font-song, label-font: font-hei)
  show: heading-style.with(font: font-hei)
  show: heading-numbering // 第六層「①」/ Sixth level ①
  show: ref-style

  // 論文段落：首行縮排、行距較寬 / Paper paragraphs: first-line indent, wider leading
  set par(first-line-indent: 2em, leading: 1.2em)

  // 頁首：第一頁不輸出；雙數頁靠左「頁碼　even-header」，單數頁靠右「標題　頁碼」；
  // 標題只取換行前的第一行。
  // 黑體不加粗；font-hei 以 Arial 排英數字，即為無襯線體。頁尾置中頁碼由 page-style 提供，維持不變。
  // Running head: none on page 1; even pages "number  even-header" on the left, odd pages
  // "title  number" on the right, with only the first line of the title.
  // Regular-weight sans: font-hei sets Latin text in Arial.
  // The centered page number in the footer comes from page-style and is kept.
  let running-title = first-line(title)
  set page(header: context {
    if here().page() > 1 {
      set text(font: font-hei, weight: "regular", size: 10pt)
      let number = counter(page).display()
      let gap = h(2em)
      if calc.even(counter(page).get().first()) {
        align(left)[#number#if even-header != none { gap + even-header }]
      } else {
        align(right)[#running-title#gap#number]
      }
    }
  })

  // 區塊引用後，迫使下一段恢復首行縮排
  // After a block quote, force the next paragraph to keep its first-line indent
  show quote.where(block: true): it => {
    it
    v(-1em) // 抵銷多餘間距 / Cancel the extra spacing
    par(text(size: 0pt, "")) // 不可見的假段落 / Invisible dummy paragraph
  }

  // 仿《臺大法學論叢》：中文摘要標題顯示為楷體置中的「<摘要>」
  // Following National Taiwan University Law Journal: the Chinese abstract heading shows "<摘要>" in Kai, centered
  show heading.where(numbering: none, body: [摘要]): _ => align(
    center,
    text(font: font-kai, size: 13pt, weight: "regular", "<摘要>"),
  )

  let authors-arr = normalize-authors(authors)
  let authors-en-arr = normalize-authors(authors-en)

  // ── 中文封面頁 / Chinese cover page ──
  title-block(title, title-thanks: title-thanks, subtitle: subtitle, authors: authors-arr)

  if abstract-zh != [] {
    v(1.5em)
    heading(level: 1, numbering: none)[摘要]
    v(0.5em)
    abstract-zh
    if keywords-zh != none {
      v(0.5em)
      text(font: font-kai)[#text(weight: "bold")[關鍵字：]#keywords-zh]
    }
  }

  pagebreak()

  // ── 英文封面頁 / English cover page ──
  if title-en != none and title-en != "" {
    title-block(
      title-en,
      title-thanks: title-en-thanks,
      subtitle: subtitle-en,
      authors: if authors-en-arr.len() > 0 { authors-en-arr } else { authors-arr },
    )

    if abstract-en != [] {
      v(1.5em)
      heading(level: 1, numbering: none)[Abstract]
      v(0.5em)
      pad(x: 2em)[
        #set text(size: 10pt)
        #set par(leading: 0.8em, first-line-indent: 0em)
        #abstract-en
        #if keywords-en != none {
          v(0.3em)
          text(weight: "bold")[Keywords: ]
          keywords-en
        }
      ]
    }

    pagebreak()
  }

  // ── 目錄（獨立一頁）/ Table of contents (own page) ──
  // depth: 3 只收錄到「(一)」層 / depth: 3 stops at the "(one)" level
  // target 只查詢 outlined 的標題：參考文獻的分組標題在 context 中產生，若一併查詢，
  // 查詢結果在五次排版內無法穩定，編譯時會出現 did not converge 警告。
  // target queries outlined headings only: the bibliography group headings are made
  // inside context, and querying them too keeps the query from stabilizing within
  // five layout passes, which ends in a "did not converge" warning.
  outline(indent: auto, depth: 3, target: heading.where(outlined: true))

  pagebreak()

  show: plain-links

  body

  // ── 參考文獻 / Bibliography ──
  // 先依語言、中文文獻再依類型分組；外文文獻在前，中文文獻在後。沒有任何文獻的
  // 分組不輸出標題；完全沒有引用時，整個參考文獻章節都不輸出。除非 list-cases 為 true，
  // 裁判不列入。
  // Grouped by language, foreign-language groups first and Chinese last, and
  // Chinese entries also by type. Groups without entries are omitted; with no
  // citations at all, the whole section is omitted. Cases are left out unless
  // list-cases is true.
  //
  // 語言取自 citrus：優先讀書目的 language 欄位（如 japanese、de、fr），
  // 沒有時，標題含漢字者視為中文，其餘視為英文。日文文獻因此必須填 language。
  // The language comes from citrus: the entry's language field if present
  // (e.g. japanese, de, fr); otherwise titles with Han characters count as
  // Chinese and everything else as English. Japanese entries must set language.
  context {
    let entries = get-cited-entries()
    if not list-cases { entries = entries.filter(e => not is-case(e)) }
    if entries.len() == 0 { return }

    let group(level, title, items) = if items.len() > 0 {
      heading(level: level, outlined: false, title)
      for e in items [
        #e.rendered-body #e.ref-label
        #parbreak()
      ]
    }

    // 外文分組及其順序；其後依序為其他外文文獻、中文文獻
    // Foreign-language groups in output order, followed by other languages and then Chinese
    let foreign-groups = (
      ("en", [英文文獻]),
      ("ja", [日文文獻]),
      ("de", [德文文獻]),
      ("fr", [法文文獻]),
    )
    let known-langs = foreign-groups.map(g => g.at(0)) + ("zh",)
    // 中文文獻的類型分組，以 BibTeX 類型比對；CSL-JSON 的 book、chapter、
    // article-journal、thesis 會由 citrus 對應為 book、incollection、article、phdthesis。
    // Type groups for Chinese entries, matched on BibTeX types; citrus maps the
    // CSL-JSON types book, chapter, article-journal and thesis to these.
    let zh-type-groups = (
      ([專書], ("book", "mvbook", "collection")),
      ([專書論文], ("incollection",)),
      ([期刊論文], ("article",)),
      ([未出版之學位論文], ("thesis", "phdthesis", "mastersthesis")),
    )
    let zh-grouped-types = zh-type-groups.map(g => g.at(1)).flatten()
    let type-of(e) = lower(e.entry-type)

    heading(level: 1, numbering: none, outlined: false)[參考文獻]
    // 無編號的第一層標題不會推進計數器；歸零後，下方分類才會從「一、」「(一)」重新起算
    // An unnumbered level-1 heading does not step the counter; reset it so the groups below restart at 一、 and (一)
    counter(heading).update(0)

    for (lang, title) in foreign-groups {
      group(2, title, entries.filter(e => e.lang == lang))
    }
    // 上列以外語言的文獻（例如韓文、義大利文）/ Entries in any other language
    group(2, [其他外文文獻], entries.filter(e => e.lang not in known-langs))

    let zh-items = entries.filter(e => e.lang == "zh")
    if zh-items.len() > 0 {
      heading(level: 2, outlined: false)[中文文獻]
      for (type-title, types) in zh-type-groups {
        group(3, type-title, zh-items.filter(e => type-of(e) in types))
      }
      group(3, [其他], zh-items.filter(e => type-of(e) not in zh-grouped-types))
    }
  }
}
