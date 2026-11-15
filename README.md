# flamegold

> **Unofficial.** This is a personal project. It is not affiliated with or endorsed by any university, law school, or journal whose layout it imitates.

A [Typst](https://typst.app/) template for Traditional Chinese law papers, modeled on the journals of Taiwan's law schools: bilingual cover, abstracts, outline, note-style CSL citations, and a bibliography grouped by language and type. A `preset` parameter picks the journal layout to imitate, such as `"ntulj"` (National Taiwan University Law Journal) or `"ntpu"` (Taipei University Law Review); without it, the template uses a generic layout. The name comes from the Taiwan flamegold rain tree.

Requirements, installation, usage, parameters, and examples are documented only in Chinese below:

---

> **非官方**：本模板為個人製作，與所模仿的任何大學、法學院或期刊均無關，亦未經其認可。投稿前請以各期刊最新公布的撰稿格式為準。

適用於 [Typst](https://typst.app/) 的繁體中文法學論文模板，版面仿臺灣頂尖大學法學院的期刊：中英封面、摘要、目次、腳註式 CSL 引註，以及依語言與類型分組的參考文獻。以 `preset` 參數選擇要模仿的期刊，目前支援《臺大法學論叢》（`"ntulj"`）與《臺北大學法學論叢》（`"ntpu"`）；不指定時為泛用格式。

排版規則、行內樣式、註腳與標題編號沿用 [yuhina](https://github.com/zhenhuang-tw/yuhina) 套件，因此與筆記套件 [bluemagpie](https://github.com/zhenhuang-tw/bluemagpie) 外觀一致。引註使用 [citrus](https://typst.app/universe/package/citrus)，以 Git 子模組（submodule）固定於 fork 的 `ntu-adapted` 分支，其中修正了腳註編號、引用頁範圍、姓名變數與 `shorttitle`。

本套件的名稱 `flamegold` 得名於臺灣特有種臺灣欒樹（flamegold rain tree）。

## 環境需求

1. [Typst](https://github.com/typst/typst#installation) 0.15 以上（`bib` 參數使用 0.15 新增的 `path` 型別）。
2. 建議安裝下列字型：Times New Roman、Arial、新細明體（`PMingLiU`）、標楷體（`DFKai-SB`）、微軟正黑體（`Microsoft JhengHei UI`）。Windows 皆已內建。

新細明體、標楷體與微軟正黑體是 Windows 隨附的商用字型，Linux 通常沒有；本模板不支援 macOS。缺少時，字型會依 yuhina 的降級清單改用可免費取得的字型：拉丁字母與數字用 Libertinus Serif（內文、楷體）與 Libertinus Sans（黑體），中文用 Noto Serif／Sans CJK TC、教育部標準楷書（`TW-MOE-Std-Kai`）等。完整清單與安裝建議見 yuhina 的[字型降級](https://github.com/zhenhuang-tw/yuhina#字型降級)。Libertinus Serif 由 Typst 內建，Libertinus Sans 則須自行安裝。

使用替補字型時，Typst 仍會對找不到的首選字型顯示 `unknown font family` 警告，不影響輸出。

首次編譯時，Typst 會自動下載 `@preview/cuti` 與 `@preview/citegeist`。

> Typst web app 無法使用本機套件（`@local`），因此在 yuhina 與本套件上架 Typst Universe 前，請以本機的 Typst 編譯。

## 安裝

本套件與 yuhina 都尚未上架 Typst Universe，須安裝為本機套件（local package）。Typst 會在 `%APPDATA%\typst\packages\local\<名稱>\<版本>` 尋找本機套件。clone 本 repo 後執行 `install.ps1`，會為本套件與 yuhina 各建立一個指向 clone 的目錄連結（junction）；之後 clone 內容變動，不必重新複製。建立 junction 不需要系統管理員權限。

```powershell
git clone --recurse-submodules https://github.com/zhenhuang-tw/flamegold.git
cd flamegold
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

腳本的行為：

- 若 `citrus` 子模組尚未取出（clone 時少了 `--recurse-submodules`），先執行 `git submodule update --init` 取出。
- 在本 repo 旁邊的 `..\yuhina` 尋找 yuhina 的 clone；找不到就 clone 到那裡（需要 git）。已依 bluemagpie 的說明安裝過 yuhina 者，會沿用同一個 clone。
- 從各自的 `typst.toml` 讀取套件名稱與版本來決定資料夾，不會對不上。
- 可重複執行：已正確連結的會略過；該路徑上已有真實資料夾時會中止，不會刪除；已有指向別處的 junction 時，加上 `-Force` 才會替換（只移除 junction，不動它所指向的資料夾）。
- `-YuhinaPath` 指定 yuhina clone 的位置，`-PackageRoot` 指定本機套件目錄。

`-ExecutionPolicy Bypass` 只對這一次執行有效。Windows 用戶端預設的執行原則不允許執行 `.ps1`；若您已調整過，可直接執行 `.\install.ps1`。使用 PowerShell 7 時，將 `powershell` 換成 `pwsh`。

安裝後，文件即可 `#import "@local/flamegold:0.1.0": *`。未安裝時，編譯會出現 `package not found (searched for @local/flamegold:0.1.0)`；少了 yuhina 則是 `@local/yuhina:0.1.0`。

### 更新

在兩個 clone 內各執行 `git pull`；本 repo 另需更新 `citrus` 子模組，以取得新版所固定的 commit：

```powershell
git pull
git submodule update --init
```

junction 指向 clone 本身，所有文件下次編譯就會用到新版。若 `typst.toml` 的 `version` 提高（例如 0.2.0），再執行一次 `install.ps1` 即會建立新版本的 junction，並把文件中的 `@local/flamegold:0.1.0` 改為新版本。

## 快速開始

```typ
#import "@local/flamegold:0.1.0": *

#show: paper.with(
  preset: "ntulj",                  // 選填：模仿的期刊；不填為泛用格式
  bib: path("ref.bib"),             // 或 path("references.json")
  csl: read("law-journals-citation-guide.csl"),
  title: "誠實信用原則與衡平法之性質及功能",
  authors: (name: "何孝元", thanks: "臺灣省立中興大學法律學系系主任。"),
  abstract-zh: [本文探討……],
  keywords-zh: "誠實信用原則、衡平法",
  title-en: "The nature and function of the principle of good faith and equity",
  abstract-en: [This article examines ...],
  keywords-en: "Principle of good faith, Equity",
)

= 緒論

王澤鑑教授指出，民法百年來之發展……@WangZeJian2025。至於教育法之相關文獻，則以……#footnote[
  #ncite(prefix: "參","LiRenMiao2023", "7")。
]
```

```powershell
typst compile paper.typ
```

`bib` 請用 `path()` 包住書目檔的路徑。`path()` 在您的文件中解析路徑，所以相對路徑以您的文件所在資料夾為準，例如 `path("refs/ref.bib")`；若直接傳字串，路徑會改以套件所在資料夾為準而找不到檔案，因此模板只接受 `path`。

書目格式由 `bib-format` 指定，可為 `"csl-json"`、`"biblatex"`（含 BibTeX）或 `"hayagriva"`。預設 `auto` 依檔案內容判斷：以 `[` 或 `{` 開頭者為 CSL-JSON，含 `@類型{` 條目者為 BibLaTeX，都不是時會要求您指定；副檔名不影響判斷。檔案開頭的 UTF-8 BOM 會自動去除。

Typst 內建的 Hayagriva YAML 格式目前**不支援**：本模板以 citrus 處理引註，而 citrus 只能解析 BibLaTeX 與 CSL-JSON。指定 `"hayagriva"` 時會報錯。

`csl` 則必須由您的文件自己 `read()` 後傳入內容。

## 預設格式（preset）

《法學期刊引註格式凡例》是 TSSCI 一級法學期刊共通的引註格式，各刊差異不大，交由您傳入的 CSL 處理；`preset` 只處理版面。

| `preset`       | 模仿的期刊           |
| -------------- | -------------------- |
| `none`（預設） | 泛用格式             |
| `"ntulj"`      | 《臺大法學論叢》     |
| `"ntpu"`       | 《臺北大學法學論叢》 |

preset 只提供預設值。參數表中預設為 `auto` 的參數（目前為 `bib-order`），明確傳入時一律優先。目前僅支援《臺大法學論叢》與《臺北大學法學論叢》，未來將優先考慮支援《政大法學評論》。

本模板供撰寫報告與論文之用，並非期刊的正式排版，因此 preset 不會在頁首放入期刊名稱；需要時請以 `even-header` 自行指定，例如課程名稱。

各 preset 的差異：

| 項目         | 泛用格式                                            | `"ntulj"`                        | `"ntpu"`                                          |
| ------------ | --------------------------------------------------- | -------------------------------- | ------------------------------------------------- |
| 中文摘要標題 | 「摘要」置中，字型同其他標題                        | 「<摘要>」楷體 13pt 置中         | 同泛用格式（因此為楷體 18pt）                     |
| 中文關鍵字   | 「關鍵字：」黑體粗體，關鍵字為內文字型              | 全行楷體，「關鍵字：」不加粗     | 同泛用格式                                        |
| 標題         | 黑體粗體；「壹、」16.8pt、「一、」14.4pt，其餘 12pt | 同泛用格式                       | 楷體不加粗；「壹、」18pt、「一、」14pt，其餘 12pt |
| 註腳         | 明體，Typst 預設註腳字級；編號為黑體（無襯線）      | 同泛用格式，但編號為明體（襯線） | 明體 9pt，行高 12pt；編號為明體（襯線）           |
| 參考文獻順序 | 外文在前、中文在後                                  | 同泛用格式                       | 中文、日文在前，其他外文在後                      |

各 preset 的目次標題皆為「目次」，摘要標題都不列入目次；中、英文關鍵字行都採凸排，換行後與第一個關鍵字對齊。`"ntpu"` 依該刊〈投稿論文參考格式〉；其中的「級」即 Word 的點（pt）。「行高 12pt」模仿 Word 的「最小行高 12pt」：一般行的基線距離固定為 12pt，含有較高行內內容的行才會撐開。

## 參數說明

主函式為 `paper`，以 `#show: paper.with(...)` 套用。

| 參數                             | 型別               | 預設值  | 說明                                                                           |
| -------------------------------- | ------------------ | ------- | ------------------------------------------------------------------------------ |
| `bib`                            | path               | —       | **必填**。`path("ref.bib")`；依內容判斷為 CSL-JSON 或 BibTeX。                 |
| `bib-format`                     | `auto`／字串       | `auto`  | `"csl-json"`、`"biblatex"` 或 `"hayagriva"`（目前不支援）；`auto` 依內容判斷。 |
| `csl`                            | 字串               | —       | **必填**。`read("xxx.csl")` 讀出的 CSL 內容，應為 note 式。                    |
| `preset`                         | `none`／字串       | `none`  | 模仿的期刊：`"ntulj"`、`"ntpu"`；`none` 為泛用格式。見〈預設格式〉。           |
| `title`                          | 字串               | `""`    | 中文主標題。                                                                   |
| `title-thanks`、`subtitle`       | 內容／`none`       | `none`  | 標題的註解（以腳註呈現）、副標題。                                             |
| `title-en`                       | 字串／`none`       | `none`  | 英文標題。不填則不產生英文封面頁。                                             |
| `title-en-thanks`、`subtitle-en` | 內容／`none`       | `none`  | 英文標題註解、英文副標題。                                                     |
| `authors`                        | 字串／字典／陣列   | `()`    | 中文作者，寫法見下。                                                           |
| `authors-en`                     | 字串／字典／陣列   | `()`    | 英文作者。不填則沿用 `authors`。                                               |
| `even-header`                    | 字串／內容／`none` | `none`  | 雙數頁頁首於頁碼後輸出的字串，例如課程名稱。不填則只輸出頁碼。                 |
| `list-cases`                     | 布林值             | `false` | 是否將裁判列入參考文獻。                                                       |
| `bib-order`                      | `auto`／陣列       | `auto`  | 參考文獻分組的順序，見〈引註與參考文獻〉。`auto` 取 preset 的順序。            |
| `abstract-zh`、`abstract-en`     | 內容               | `[]`    | 中、英文摘要。留空則不輸出。                                                   |
| `keywords-zh`、`keywords-en`     | 字串／`none`       | `none`  | 中、英文關鍵字。                                                               |

作者寫法：

```typ
authors: "何孝元"
authors: (name: "何孝元", thanks: "國立臺北大學法律學系")
authors: ((name: "何孝元", thanks: "國立臺北大學法律學系"), "蔡蔭恩")
```

## 引註與參考文獻

使用腳註 (note) 式 CSL 時，`@key` 會自動產生腳註。

為配合法學引註常須加註前後短語（例如 _The Bluebook_ 前面要有信號詞，後面常會括註該文主要立場者），本模板預設搭配的 CSL 格式不輸出結尾句號。故若使用 `@key`，將無法產生結尾句號。若需要結尾句號，建議使用 `#ncitef`（footnote + ncite 之意），其參數與 `#ncite` 相同，效果相當於 `#footnote[#ncite(...)。]`。

`#ncitef` 的句號預設為全形「。」。引註英文文獻時，可用 `period` 參數改為半形句號：`#ncitef("key", "at 5", period: ".")`。若 `suffix` 已自帶標點，或不需要句號，請傳入 `period: none`。

**腳註內的引用請用 `#ncite`**。在 `#footnote[...]` 裡寫 `@key`，會在腳註裡再產生一個腳註。`#ncite` 改以行內格式輸出：

```typ
#ncite("bibKey")
#ncite("bibKey", "5")
#ncite(prefix: "可參照", "bibKey", "5", suffix: "之不同語境。")
```

文末參考文獻依語言與類型分組。泛用格式與 `ntulj` 為外文文獻在前、中文文獻在後；`ntpu` 為中文、日文文獻在前，其他外文在後。順序也可以用 `bib-order` 自行指定。沒有文獻的分組不輸出；全文沒有任何引用時，整個參考文獻章節都不輸出。泛用格式的分組如下：

```
參考文獻
一、英文文獻
二、日文文獻
三、德文文獻
四、法文文獻
五、其他外文文獻           上列以外的語言
六、中文文獻
  (一) 專書                 book、mvbook、collection
  (二) 專書論文             incollection
  (三) 期刊論文             article
  (四) 未出版之學位論文     thesis、phdthesis、mastersthesis
  (五) 其他                 其餘類型
```

上例為所有分組都有文獻時的樣子；實際編號依有輸出的分組遞補。

`bib-order` 為下列代碼組成的陣列，依序輸出；未列出的分組不輸出：`"en"`（英文）、`"ja"`（日文）、`"de"`（德文）、`"fr"`（法文）、`"other"`（其他外文）、`"zh"`（中文）。例如 `ntpu` 的順序為 `("zh", "ja", "en", "de", "fr", "other")`。

裁判原則上不列入參考文獻：CSL-JSON 中 `type` 為 `legal_case`，或 BibTeX 中標示 `mark = {LEGAL_CASE}` 的文獻，只出現在註腳。若要列入，請傳入 `list-cases: true`，裁判會依語言列入各分組，中文裁判列於「其他」。

類型以 BibTeX 的 entry type 判斷（不分大小寫）；使用 CSL-JSON 時，citrus 會先把 `book`、`chapter`、`article-journal`、`thesis` 對應為 `book`、`incollection`、`article`、`phdthesis`。

語言的判斷方式：書目有 `language` 欄位時以它為準，例如 `japanese`、`german`、`french`，或 `ja`、`de`、`fr`；沒有時，標題含漢字者一律視為中文，其餘視為英文。因此**日文文獻必須填寫 `language`**，否則會被歸入中文文獻；德文、法文文獻沒填則會歸入英文文獻。

```bib
@book{ashibe1992,
  author   = {芦部信喜},
  title    = {憲法学},
  language = {japanese},
  ...
}
```

### BibTeX 的非標準類型：以 `mark` 指定

citrus 以 citegeist 解析 BibTeX，而 citegeist 不認得 `@case`、`@jurisdiction`、`@legislation`、`@standard`、`@newspaper` 等非標準類型，會一律當成 `unknown`。CSL 因此找不到對應的格式，註腳會出現 `[CSL STYLE ERROR: reference with no printed form.]`。

這類文獻請改用 `@misc`，並以 `mark` 欄位指定類型：

```bib
@misc{khh_case,
  mark    = {LEGAL_CASE},
  title   = {<span class="nocase">State v. K.H.-H.</span>},
  journal = {Wn.2d},
  volume  = {185},
  pages   = {745},
  date    = {2016-06-23},
}

@misc{tw_case,
  mark      = {LEGAL_CASE},
  title     = {某案},
  authority = {最高法院},
  number    = {112年度台上字第1號},
  genre     = {民事判決},
  date      = {2023-05-01},
}
```

| `mark`        | 類型     |
| ------------- | -------- |
| `LEGAL_CASE`  | 裁判     |
| `LEGISLATION` | 法規     |
| `REGULATION`  | 行政命令 |
| `N`           | 報紙     |
| `S`           | 標準     |

`mark` 的值不分大小寫。網頁請用 `@online`，citegeist 不認得 `@webpage`。

出處：citrus 中文文件〈需要 `mark` 字段的文献类型〉，見 [`examples/example-zh.typ`](https://github.com/pku-typst/citeproc-typst/blob/main/examples/example-zh.typ)；`REGULATION` 見 citrus [README](https://github.com/pku-typst/citeproc-typst#unsupported-types-require-mark-field)。

## 行內樣式與編號

`lib.typ` 只匯出下列名稱，其餘屬內部實作，日後可能變動：

| 名稱                                                           | 用途                        |
| -------------------------------------------------------------- | --------------------------- |
| `paper`                                                        | 主函式                      |
| `ncite`、`ncitef`                                              | 腳註內引用、單一引用的腳註  |
| `keyword`                                                      | 重點強調（原字體加粗）      |
| `inquote`                                                      | 行內引用（楷體）            |
| `font-song`、`font-hei`、`font-kai`、`font-yuan`、`font-fsong` | 字型組合，替補字型同 yuhina |

`keyword`、`inquote` 的用法見 yuhina 的 [README](https://github.com/zhenhuang-tw/yuhina/blob/main/README.md)。

標題編號沿用 yuhina，共六層，第六層為「①」：

| 寫法          | 編號             |
| ------------- | ---------------- |
| `= 標題`      | 壹、標題（置中） |
| `== 標題`     | 一、標題         |
| `=== 標題`    | (一) 標題        |
| `==== 標題`   | 1.標題           |
| `===== 標題`  | (1) 標題         |
| `====== 標題` | ①標題            |

目次只收錄到「(一)」層。

交互參照：在標題後加上標籤，內文以 `@標籤` 參照，會輸出完整層級路徑，例如 `見@issue` 輸出「見貳、一、(三)」；`@issue[本文]` 輸出「本文貳、一、(三)」。頁碼參照請寫 `#ref(<issue>, form: "page")`。

編號清單依層級為 `1. → (1) → A. → (A) → a. → (a)`。

## 版面

與 bluemagpie 的筆記相比：

| 項目     | 筆記（bluemagpie）     | 論文（本模板）                                                            |
| -------- | ---------------------- | ------------------------------------------------------------------------- |
| 段落     | 不縮排，行距 1.1em     | 首行縮排 2 字，行距 1.2em                                                 |
| 首頁     | 標題、作者，其下接目錄 | 中文標題、作者、摘要、關鍵字                                              |
| 其他前頁 | 無                     | 英文封面與 Abstract（填 `title-en` 時）、獨立目次頁                       |
| 文末     | 不輸出參考文獻清單     | 分組參考文獻                                                              |
| 頁首     | 無                     | 第一頁不輸出；雙數頁靠左「頁碼　`even-header`」，單數頁靠右「標題　頁碼」 |

頁首使用黑體、不加粗，10pt；英數字為 Arial（無襯線體）。單數頁只輸出主標題 `title`，不含副標題與標題註解；標題若有換行（`\` 或字串中的 `\n`），頁首只取換行前的第一行。頁尾置中頁碼與筆記相同，仍然保留。

## License

[MIT](LICENSE)
