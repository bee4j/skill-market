# 故障排查手册

## 1. 行数异常偏高

**症状**：排除依赖目录后，code 行数仍远超预期（如单仓库 > 500 万行）。

**排查步骤**：
```bash
# 定位最大的 10 个文件
cloc . --vcs=git --by-file --csv --out=by-file.csv
sort -t, -k5 -nr by-file.csv | head -10