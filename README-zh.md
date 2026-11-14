# typst-ntulj

適用於 [Typst](https://typst.app/) 的繁體中文學術論文模板，版面仿《臺大法學論叢》（NTU Law Journal）：中英封面、摘要、目錄、腳註式 CSL 引註，以及依語言與類型分組的參考文獻。

字體、行內樣式、註腳與標題編號沿用 [typst-basic-zh](https://github.com/zhenhuang-tw/typst-basic-zh) 的 `common.typ`，以 Git 子模組（submodule）引入，因此與筆記模板外觀一致。引註使用 [citrus](https://typst.app/universe/package/citrus)，目前固定於修正腳註編號的 fork 分支（`fix/note-number-from-footnote-counter`）。

## 環境需求

1. [Typst](https://github.com/typst/typst#installation) 0.15 以上（`bib` 參數使用 0.15 新增的 `path` 型別）。
2. 字型同 typst-basic-zh，見其 [README](https://github.com/zhenhuang-tw/typst-basic-zh/blob/main/README-zh.md#環境需求)；但台灣圓體與朱雀仿宋僅供筆記專用的 `#hypo`、`#thought` 使用，本模板不需要。

首次編譯時，Typst 會自動下載 `@preview/cuti` 與 `@preview/citegeist`。

## 安裝

在您的論文專案根目錄執行：

```powershell
git submodule add https://github.com/zhenhuang-tw/typst-ntulj.git typst-ntulj
git submodule update --init --recursive
```

本模板自己也有兩個 submodule（`typst-basic-zh`、`citrus`），所以一定要加 `--recursive`；少了它，`typst-ntulj/typst-basic-zh/` 與 `typst-ntulj/citrus/` 會是空資料夾，編譯時出現找不到 `common.typ` 或 `lib.typ` 的錯誤。

在其他電腦 clone 論文專案時，同樣請用：

```powershell
git clone --recurse-submodules <論文專案網址>
```

## 快速開始

```typ
#import "typst-ntulj/lib.typ": *

#show: paper.with(
  bib: path("ref.bib"),             // 或 path("references.json")
  csl: read("law-journals-citation-guide.csl"),
  title: "誠實信用原則與衡平法之性質及功能",
  authors: (name: "何孝元", thanks: "臺灣省立中興大學法律學系系主任。"),
  abstract-zh: [本文探討……],
  keywords-zh: "誠實信用原則、衡平法",
  title-en: "The nature and function of the principle of good faith and equity",
  abstract-en: [This article examines ...],
  keywords-en: "Principle of good faith, Equity",
  even-header: "臺大法學論叢",       // 選填：雙數頁頁首
)

= 緒論

王澤鑑教授指出，民法百年來之發展……@WangZeJian2025。至於教育法之相關文獻，則以……#footnote[
  #ncite(prefix: "參","LiRenMiao2023", "7")。
]
```

```powershell
typst compile paper.typ
```

`bib` 請用 `path()` 包住書目檔的路徑。`path()` 在你的文件中解析路徑，所以相對路徑以你的文件所在資料夾為準，例如 `path("refs/ref.bib")`；若直接傳字串，路徑會改以模板所在資料夾為準而找不到檔案，因此模板只接受 `path`。

模板依檔案內容判斷格式：以 `[` 或 `{` 開頭者為 CSL-JSON，其餘為 BibTeX，副檔名不影響判斷。檔案開頭的 UTF-8 BOM 會自動去除。

`csl` 則必須由你的文件自己 `read()` 後傳入內容。

## 參數說明

主函式為 `paper`，以 `#show: paper.with(...)` 套用。

| 參數                             | 型別               | 預設值 | 說明                                                           |
| -------------------------------- | ------------------ | ------ | -------------------------------------------------------------- |
| `bib`                            | path               | —      | **必填**。`path("ref.bib")`；依內容判斷為 CSL-JSON 或 BibTeX。 |
| `csl`                            | 字串               | —      | **必填**。`read("xxx.csl")` 讀出的 CSL 內容，應為 note 式。    |
| `title`                          | 字串               | `""`   | 中文主標題。                                                   |
| `title-thanks`、`subtitle`       | 內容／`none`       | `none` | 標題的註解（以腳註呈現）、副標題。                             |
| `title-en`                       | 字串／`none`       | `none` | 英文標題。不填則不產生英文封面頁。                             |
| `title-en-thanks`、`subtitle-en` | 內容／`none`       | `none` | 英文標題註解、英文副標題。                                     |
| `authors`                        | 字串／字典／陣列   | `()`   | 中文作者，寫法同 typst-basic-zh。                              |
| `authors-en`                     | 字串／字典／陣列   | `()`   | 英文作者。不填則沿用 `authors`。                               |
| `even-header`                    | 字串／內容／`none` | `none` | 雙數頁頁首於頁碼後輸出的字串，例如期刊名稱。不填則只輸出頁碼。 |
| `abstract-zh`、`abstract-en`     | 內容               | `[]`   | 中、英文摘要。留空則不輸出。                                   |
| `keywords-zh`、`keywords-en`     | 字串／`none`       | `none` | 中、英文關鍵字。                                               |

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

文末參考文獻依語言與類型分組。沒有文獻的分組不輸出；全文沒有任何引用時，整個參考文獻章節都不輸出：

```
參考文獻
一、英文文獻
二、中文文獻
  (一) 專書                 book、mvbook、collection
  (二) 專書論文             incollection
  (三) 期刊論文             article
  (四) 未出版之學位論文     thesis、phdthesis、mastersthesis
  (五) 其他                 其餘類型
三、日文文獻
四、德文文獻
五、法文文獻
六、其他外文文獻           上列以外的語言
```

上例為所有分組都有文獻時的樣子；實際編號依有輸出的分組遞補。類型以 BibTeX 的 entry type 判斷（不分大小寫）；使用 CSL-JSON 時，citrus 會先把 `book`、`chapter`、`article-journal`、`thesis` 對應為 `book`、`incollection`、`article`、`phdthesis`。

語言的判斷方式：書目有 `language` 欄位時以它為準，例如 `japanese`、`german`、`french`，或 `ja`、`de`、`fr`；沒有時，標題含漢字者一律視為中文，其餘視為英文。因此**日文文獻必須填寫 `language`**，否則會被歸入中文文獻；德文、法文文獻沒填則會歸入英文文獻。

```bib
@book{ashibe1992,
  author   = {芦部信喜},
  title    = {憲法学},
  language = {japanese},
  ...
}
```

## 行內樣式與編號

入口檔 `lib.typ` 只匯出主函式 `paper`、引註函式 `ncite`、`ncitef`、字型名稱 `font-song`、`font-hei`、`font-kai`、`font-yuan`、`font-fsong`，以及 `keyword`（重點強調）與 `inquote`（行內引用）兩個行內樣式函式；其餘名稱屬內部實作，日後可能變動。行內樣式函式的用法見 typst-basic-zh 的 [README](https://github.com/zhenhuang-tw/typst-basic-zh/blob/main/README-zh.md#行內樣式函式)。筆記專用的 `very-keyword`、`hypo`、`thought`、`rightNote` 不提供；從舊版遷移的論文若用到它們，請改寫或自行定義。

標題與編號清單的編號規則同樣來自 typst-basic-zh。標題編號與 `basic-note.typ` 相同：`=` 為「壹、」，`==` 為「一、」，`===` 為「(一)」。

交互參照也與 `basic-note.typ` 相同：在標題後加上標籤，內文以 `@標籤` 參照，會輸出完整層級路徑，例如 `見@issue` 輸出「見貳、一、(三)」；`@issue[本文]` 輸出「本文貳、一、(三)」。詳見 typst-basic-zh 的 [README](https://github.com/zhenhuang-tw/typst-basic-zh/blob/main/README-zh.md#交互參照)。

## 版面

與 typst-basic-zh 的筆記模板相比：

| 項目     | 筆記（typst-basic-zh） | 論文（本模板）                                                            |
| -------- | ---------------------- | ------------------------------------------------------------------------- |
| 段落     | 不縮排，行距 1.1em     | 首行縮排 2 字，行距 1.2em                                                 |
| 首頁     | 標題、作者，其下接目錄 | 中文標題、作者、「<摘要>」、關鍵字                                        |
| 其他前頁 | 無                     | 英文封面與 Abstract（填 `title-en` 時）、獨立目錄頁                       |
| 文末     | 不輸出參考文獻清單     | 分組參考文獻                                                              |
| 頁首     | 無                     | 第一頁不輸出；雙數頁靠左「頁碼　`even-header`」，單數頁靠右「標題　頁碼」 |

頁首使用黑體、不加粗，10pt；英數字為 Arial（無襯線體）。單數頁只輸出主標題 `title`，不含副標題與標題註解；標題若有換行（`\` 或字串中的 `\n`），頁首只取換行前的第一行。頁尾置中頁碼與筆記模板相同，仍然保留。

## 從 typst-basic-zh 遷移

### 原本匯入 `typst-basic-zh/academic-paper.typ`

1. 依「安裝」一節加入本 submodule。
2. 將 `#import "typst-basic-zh/academic-paper.typ": *` 改為 `#import "typst-ntulj/lib.typ": *`。主函式由 `project` 改名為 `paper`；`ncite`、`ncitef` 的參數不變。
3. 若該專案只用來寫論文，可以移除原本的 `typst-basic-zh` submodule：

```powershell
git rm typst-basic-zh
git commit -m "chore(tpl): replace typst-basic-zh with typst-ntulj"
```

### 原本使用獨立的 `template_basicPaper.typ`

1. 匯入路徑改為 `typst-ntulj/lib.typ`。
2. 將 `project.with(...)` 改為 `paper.with(...)`，並加上 `bib: path("ref.bib")`（或 `path("references.json")`）與 `csl: read("你的樣式.csl")`。
3. 原專案資料夾中的 `template_basicPaper.typ` 可以刪除。

差異：巢狀編號清單的第二層由 `1.` 改為 `(1)`；參考文獻不再重複列出英文文獻、分組編號從「一、」起算、空分組不輸出。

## 更新 submodule

在你的論文專案根目錄執行：

```powershell
git submodule update --remote --merge typst-ntulj
git -C typst-ntulj submodule update --init --recursive
git add typst-ntulj
git commit -m "chore(tpl): update typst-ntulj submodule"
```

第二行不可省略：`--remote` 只會把 `typst-ntulj` 本身移到最新版，不會讓其內的 `typst-basic-zh`、`citrus` 跟著切到新版所指定的 commit。第二行以 `-C typst-ntulj` 在模板資料夾內執行；若改在論文專案根目錄執行 `git submodule update`，且尚未 `git add typst-ntulj`，Git 會把 `typst-ntulj` 退回論文專案原本記錄的舊 commit。

本模板所用的 typst-basic-zh 版本由本 repo 固定。typst-basic-zh 更新後，若要讓論文跟進，應先在本 repo 更新 `typst-basic-zh` submodule 並提交，論文專案再依上述步驟更新 `typst-ntulj`；不要在論文專案裡直接進入 `typst-ntulj/typst-basic-zh/` 切換版本。
