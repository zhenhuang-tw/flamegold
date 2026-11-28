# citrus（內嵌副本）

本資料夾是 [citrus](https://github.com/pku-typst/citeproc-typst) 的內嵌副本，取自 fork
[zhenhuang-tw/citeproc-typst](https://github.com/zhenhuang-tw/citeproc-typst) 的
`ntu-adapted` 分支，其中修正了腳註編號、引用頁範圍、姓名變數與 `shorttitle`。

- 上游版本：citrus 0.2.1
- 來源 commit：`b078142fd20d407315687361b18df2938ac3905b`

Typst Universe 上的套件無法使用 Git 子模組，因此改為直接複製。只保留執行時需要的
`lib.typ`、`src/` 與 `LICENSE`；測試、範例、字型與文件網站請見原 repo。

## 更新

請勿直接修改這裡的檔案。要更新時，先在 fork 修改，再於 repo 根目錄執行這支腳本：

<!-- 這串指令用來把 lib\citrus 更新成 fork 的最新版本，等於手動做 git submodule update 的工作。 -->
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\update-citrus.ps1
```

腳本會自動改寫上方的上游版本與來源 commit，但不會替您 commit；請先以 `git status` 檢查，再自行 commit。
細節（參數、錯誤時如何復原）見腳本開頭的說明，或執行 `Get-Help .\scripts\update-citrus.ps1 -Full`。

上方兩行由腳本以文字比對改寫，修改這份檔案時請保留其格式。
