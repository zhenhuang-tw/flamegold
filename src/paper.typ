// src/paper.typ
// 學術論文模板的實作（仿臺灣法學期刊，版面由 preset.typ 選擇）：中英封面、摘要、目次、
// note 式 CSL 引註、分類參考文獻。
// 公開介面由 lib.typ 決定；文件請匯入 lib.typ，不要直接匯入本檔。
//
// 排版規則、註腳、標題編號與字型（含替補字型）皆沿用 yuhina 套件（@local/yuhina）。

#import "@local/yuhina:0.1.0": (
  document-style, figure-style, font-hei, font-kai, font-song, heading-style, list-style, normalize-authors, page-style,
  par-style, plain-links, quote-style, ref-style, text-style, title-block,
)
#import "footnote.typ": footnote-style
#import "preset.typ": resolve-preset
// path 型別自 Typst 0.15 起才有
#assert(
  sys.version >= version(0, 15, 0),
  message: "flamegold requires Typst 0.15 or later.",
)

#import "../citrus/lib.typ": csl-bibliography, get-cited-entries, init-csl, init-csl-json, multicite

// ============================================================
// § 腳註內引用指令（避免遞迴）
//
//   【背景】本模板採用 note 格式 CSL，引用時會自動產生腳註。若在
//   #footnote[...] 內再使用 @key，CSL 會再次插入腳註，造成「遞迴引註」之情形。
//
//   【解法】以 cite(form: "prose") 輸出行內格式，不觸發 note-layout。
//
//   【用法】
//   #ncite("bibKey")
//   #ncite("bibKey", "5")
//   #ncite("bibKey", "12-19", prefix: "可參照", suffix: "之不同語境")
//
//   【範例】
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
//   若 suffix 已以標點結尾，請傳入 `period: none` 以免重複。
// ============================================================
#let ncitef(bibKey, ..args, prefix: none, suffix: none, period: "。") = footnote[#ncite(
    bibKey,
    ..args,
    prefix: prefix,
    suffix: suffix,
  )#period]

// ============================================================
// § 頁首用標題
// ============================================================
// 只取第一行：字串取第一個換行前的部分；內容取第一個 linebreak（\）前的部分，
// 並去掉結尾空白，以免長標題在頁首折成兩行。
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
// § 關鍵字行
// ============================================================
// 凸排：首行不縮排，續行縮排標籤（如「關鍵字：」）的寬度，與第一個關鍵字對齊。
#let keywords-line(label, words) = context {
  set par(first-line-indent: 0em, hanging-indent: measure(label).width)
  [#label#words]
}

// ============================================================
// § 裁判之判斷
// ============================================================
// CSL-JSON 的 type 為 legal_case，或 BibTeX 以 mark = {LEGAL_CASE} 標示者（citegeist
// 不認得 @case 等類型，見 README-zh）。
#let is-case(e) = {
  let fields = e.fields
  let mark = fields.at("mark", default: none)
  (
    fields.at("csl-type", default: none) == "legal_case" or (mark != none and upper(str(mark)) == "LEGAL_CASE")
  )
}

// ============================================================
// § Main template function
// ============================================================
#let paper(
  // ── 引註資料（必填） ──
  // bib：書目檔，以 path() 傳入，例如 bib: path("ref.bib")。path() 在呼叫端的檔案中
  //   解析路徑，因此相對路徑以你的文件為準。
  // bib-format：書目格式，"csl-json"、"biblatex"（含 BibTeX）或 "hayagriva"；
  //   預設 auto 依內容判斷：以「[」或「{」開頭者為 CSL-JSON，含「@類型{」條目者為
  //   BibLaTeX，都不是則報錯。"hayagriva" 目前不支援，因 citrus 無法解析 YAML。

  // csl：由呼叫端讀檔後傳入內容，例如 csl: read("tssci-q1-law.csl")。
  bib: none,
  bib-format: auto,
  csl: none,

  // ── 預設格式 / Preset ──
  // 要模仿的期刊版面，以縮寫指定："ntulj"（臺大法學論叢）、"ntpu"（臺北大學法學論叢）；
  // none 為泛用格式。preset 只提供預設值：下列預設為 auto 的參數，明確傳入時一律優先。
  preset: none,

  // ── Chinese title ──
  title: "",
  title-thanks: none,
  subtitle: none,

  // ── English title (all optional) ──
  title-en: none,
  title-en-thanks: none,
  subtitle-en: none,

  // ── Authors ──
  authors: (),
  authors-en: (),

  // ── 頁首 ──
  // 雙數頁頁首於頁碼後輸出的字串，例如課程名稱；none 則只輸出頁碼。preset 不設定此項。
  even-header: none,

  // ── 參考文獻 / Bibliography ──
  // 裁判原則上不列入參考文獻；設為 true 時，依語言列入各分組（中文裁判列於「其他」）。
  list-cases: false,
  // 參考文獻分組的順序，為 "en"、"ja"、"de"、"fr"、"other"（其他外文）、"zh" 組成的陣列；
  // 未列出的分組不輸出。auto 取 preset 的值。
  bib-order: auto,

  // ── 摘要與關鍵字 ──
  abstract-zh: [],
  keywords-zh: none, // 例如 "學生參與、民主國原則、正當行政程序、兒童權利公約、兒童陳述意見的權利"
  abstract-en: [],
  keywords-en: none, // e.g. "Student participation, Principle of the democratic state, Due administrative procedure, Convention on the Rights of the Child, Right of the child to be heard"

  body,
) = {
  assert(
    type(bib) == path,
    message: "flamegold: pass bib as a path, e.g. bib: path(\"ref.bib\")",
  )
  assert(csl != none, message: "flamegold: pass csl: read(\"style.csl\")")

  // preset 只提供預設值；明確傳入的參數優先
  let layout = resolve-preset(preset)
  let bib-order = if bib-order == auto { layout.bib-order } else { bib-order }
  let bib-groups = ("en", "ja", "de", "fr", "other", "zh")
  assert(
    type(bib-order) == array and bib-order.all(g => g in bib-groups),
    message: "flamegold: bib-order must be an array of \"en\", \"ja\", \"de\", \"fr\", \"other\" and \"zh\"",
  )

  // 去除開頭的 UTF-8 BOM：
  // Windows 上部分工具（如 Windows PowerShell 5.1 的
  // Out-File -Encoding utf8）會寫入 BOM，citrus 解析 JSON 時會因此失敗。
  let data = read(bib).trim("\u{feff}", at: start)
  // path 型別無法取得副檔名，改依內容判斷：CSL-JSON 是 JSON 陣列（少數工具輸出物件），
  // BibTeX 則以「@」或註解開頭，不會以「[」「{」開頭。
  let formats = ("csl-json", "biblatex", "hayagriva")
  assert(
    bib-format == auto or bib-format in formats,
    message: "flamegold: bib-format must be auto, \"csl-json\", \"biblatex\" or \"hayagriva\"",
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
      panic("flamegold: cannot detect the bibliography format; set bib-format")
    }
  }
  assert(
    format != "hayagriva",
    message: "flamegold: Hayagriva YAML is not supported yet, because citrus only parses BibLaTeX and CSL-JSON",
  )
  let init = if format == "csl-json" { init-csl-json } else { init-csl }

  // auto-links 會把整筆註腳加上連結到參考文獻區
  show: init.with(data, csl, locales: (:), auto-links: false)

  // 等同 yuhina 的 common-style，但各規則改傳入 preset 的設定
  show: document-style.with(title: title, authors: authors)
  show: page-style
  show: text-style.with(font: font-song)
  show: par-style
  show: quote-style.with(font: font-kai)
  show: list-style
  show: figure-style.with(font: font-kai)
  show: footnote-style.with(
    font: font-song,
    label-font: layout.footnote.label-font,
    size: layout.footnote.size,
    line-height: layout.footnote.line-height,
  )
  show: heading-style.with(font: layout.heading.font)
  // preset 的標題粗細；各層字級見摘要標題的規則之後
  show heading: set text(weight: layout.heading.weight)
  show: ref-style

  // 論文段落：首行縮排、行距較寬
  set par(first-line-indent: 2em, leading: 1.2em)

  // 頁首：第一頁不輸出；雙數頁靠左「頁碼　even-header」，單數頁靠右「標題　頁碼」；
  // 標題只取換行前的第一行。
  // 黑體不加粗；font-hei 以 Arial 排英數字，即為無襯線體。頁尾置中頁碼由 page-style 提供，維持不變。
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
  show quote.where(block: true): it => {
    it
    v(-1em) // 抵銷多餘間距
    par(text(size: 0pt, "")) // 不可見的假段落
  }

  // 中文摘要標題置中，字型與粗細同其他標題；preset 有 abstract-title 時改輸出該內容，
  // 例如臺大的楷體「<摘要>」。只輸出標題文字而非整個標題區塊，以免其後第一段失去首行縮排。
  show heading.where(numbering: none, body: [摘要]): it => align(
    center,
    if layout.abstract-title == none { it.body } else { layout.abstract-title },
  )

  // preset 的各層標題字級。須寫在摘要標題的規則之後：較晚定義的 show 規則先套用，
  // 字級才會在摘要標題改寫之前生效。
  show heading: it => {
    let size = layout.heading.sizes.at(it.level - 1, default: none)
    set text(size: size) if size != none
    it
  }

  let authors-arr = normalize-authors(authors)
  let authors-en-arr = normalize-authors(authors-en)

  // ── 中文封面頁 ──
  title-block(
    title,
    title-thanks: title-thanks,
    subtitle: subtitle,
    authors: authors-arr,
    font: layout.title.font,
    weight: layout.title.weight,
  )

  if abstract-zh != [] {
    v(1.5em)
    heading(level: 1, numbering: none, outlined: false)[摘要]
    v(0.5em)
    abstract-zh
    if keywords-zh != none {
      v(0.5em)
      let style = layout.keywords
      let label = text(font: style.label-font, weight: style.label-weight)[關鍵字：]
      let words = if style.body-font == none { keywords-zh } else { text(font: style.body-font, keywords-zh) }
      keywords-line(label, words)
    }
  }

  pagebreak()

  // ── 英文封面頁 ──
  if title-en != none and title-en != "" {
    title-block(
      title-en,
      title-thanks: title-en-thanks,
      subtitle: subtitle-en,
      authors: if authors-en-arr.len() > 0 { authors-en-arr } else { authors-arr },
      font: layout.title.font,
      weight: layout.title.weight,
    )

    if abstract-en != [] {
      v(1.5em)
      heading(level: 1, numbering: none, outlined: false)[Abstract]
      v(0.5em)
      pad(x: 2em)[
        #set text(size: 10pt)
        #set par(leading: 0.8em, first-line-indent: 0em)
        #abstract-en
        #if keywords-en != none {
          v(0.3em)
          keywords-line(text(weight: "bold")[Keywords: ], keywords-en)
        }
      ]
    }

    pagebreak()
  }

  // ── 目次（獨立一頁） ──
  // 標題依法學期刊慣例為「目次」，各 preset 相同
  // depth: 3 只收錄到「(一)」層
  // target 只查詢 outlined 的標題：參考文獻的分組標題在 context 中產生，若一併查詢，
  // 查詢結果在五次排版內無法穩定，編譯時會出現 did not converge 警告。
  outline(title: [目次], indent: auto, depth: 3, target: heading.where(outlined: true))

  pagebreak()

  show: plain-links

  body

  // ── Bibliography ──
  // 先依語言、中文文獻再依類型分組；語言的順序由 bib-order 決定。沒有任何文獻的
  // 分組不輸出標題；完全沒有引用時，整個參考文獻章節都不輸出。除非 list-cases 為 true，
  // 裁判不列入。
  //
  // 語言取自 citrus：優先讀書目的 language 欄位（如 japanese、de、fr），
  // 沒有時，標題含漢字者視為中文，其餘視為英文。日文文獻因此必須填 language。
  context {
    let entries = get-cited-entries()
    if not list-cases { entries = entries.filter(e => not is-case(e)) }
    if entries.len() == 0 { return }

    let group(level, title, items) = if items.len() > 0 {
      heading(level: level, outlined: false, title)
      // 各筆文獻凸排 2 字元，前後不加段落間距：段距等於行距，相鄰兩筆的間隔與
      // 同一筆內換行相同。只作用於文獻本身，分組標題的間距不受影響。
      set par(first-line-indent: 0em, hanging-indent: 2em, spacing: par.leading)
      for e in items [
        #e.rendered-body #e.ref-label
        #parbreak()
      ]
    }

    // 以語言代碼分組的標題；"other" 收錄上列以外語言的文獻（例如韓文、義大利文）
    let lang-titles = (
      en: [英文文獻],
      ja: [日文文獻],
      de: [德文文獻],
      fr: [法文文獻],
      other: [其他外文文獻],
      zh: [中文文獻],
    )
    let known-langs = lang-titles.keys().filter(k => k != "other")
    // 中文文獻的類型分組，以 BibTeX 類型比對；CSL-JSON 的 book、chapter、
    // article-journal、thesis 會由 citrus 對應為 book、incollection、article、phdthesis。
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
    counter(heading).update(0)

    // 依 bib-order 輸出各分組；中文文獻再依類型分組
    for lang in bib-order {
      if lang == "zh" {
        let zh-items = entries.filter(e => e.lang == "zh")
        if zh-items.len() > 0 {
          heading(level: 2, outlined: false, lang-titles.zh)
          for (type-title, types) in zh-type-groups {
            group(3, type-title, zh-items.filter(e => type-of(e) in types))
          }
          group(3, [其他], zh-items.filter(e => type-of(e) not in zh-grouped-types))
        }
      } else if lang == "other" {
        group(2, lang-titles.other, entries.filter(e => e.lang not in known-langs))
      } else {
        group(2, lang-titles.at(lang), entries.filter(e => e.lang == lang))
      }
    }
  }
}
