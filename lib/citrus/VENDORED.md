# citrus（內嵌副本）

本資料夾是 [citrus](https://github.com/pku-typst/citeproc-typst) 的內嵌副本，取自 fork
[zhenhuang-tw/citeproc-typst](https://github.com/zhenhuang-tw/citeproc-typst) 的
`ntu-adapted` 分支，其中修正了腳註編號、引用頁範圍、姓名變數與 `shorttitle`。

- 上游版本：citrus 0.2.1
- 來源 commit：`b078142fd20d407315687361b18df2938ac3905b`

Typst Universe 上的套件無法使用 Git 子模組，因此改為直接複製。只保留執行時需要的
`lib.typ`、`src/` 與 `LICENSE`；測試、範例、字型與文件網站請見原 repo。

請勿直接修改這裡的檔案。要更新時，先在 fork 修改，再整個覆蓋：

```powershell
git clone -b ntu-adapted https://github.com/zhenhuang-tw/citeproc-typst.git $env:TEMP\citrus
Remove-Item -Recurse -Force lib\citrus\src
Copy-Item -Recurse $env:TEMP\citrus\src, $env:TEMP\citrus\lib.typ, $env:TEMP\citrus\LICENSE lib\citrus\ -Force
git -C $env:TEMP\citrus rev-parse HEAD   # 把結果更新到上方的「來源 commit」
```
