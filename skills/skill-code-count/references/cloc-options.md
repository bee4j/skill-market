# cloc 参数速查与项目适配

## 核心参数

| 参数 | 作用 | 是否必用 |
| :--- | :--- | :--- |
| `--vcs=git` | 仅统计 Git 跟踪的文件，忽略未跟踪的临时文件、日志、dump | **必用** |
| `--exclude-dir=<a,b,c>` | 排除目录，逗号分隔，不递归匹配 | **必用** |
| `--include-lang=<langs>` | 仅统计指定语言 | 按需 |
| `--exclude-lang=<langs>` | 排除指定语言（如 Markdown、JSON） | 按需 |
| `--by-file` | 输出每个文件的行数，用于定位异常大文件 | 排查时用 |
| `--csv` / `--md` / `--json` | 导出结构化报告 | 按需 |
| `--out=<file>` | 指定导出文件 | 配合导出格式 |
| `--max-file-size=<MB>` | 跳过超过指定大小的文件 | 大仓库建议 |
| `--quiet` | 抑制进度输出 | 推荐 |

## 各语言项目推荐排除目录

cloc 默认排除 `.git`、`.svn` 等版本控制目录，但**不排除** `node_modules`、`target` 等依赖/构建目录。以下为常见技术栈的补充排除清单：

| 技术栈 | 推荐排除目录 |
| :--- | :--- |
| Node / 前端 | `node_modules,dist,build,.next,.nuxt,coverage,out` |
| Java / Maven / Gradle | `target,build,.gradle,.m2,out` |
| Go | `vendor` |
| Python | `venv,.venv,__pycache__,.pytest_cache,.mypy_cache` |
| PHP | `vendor` |
| Rust | `target` |
| .NET | `bin,obj,packages` |
| IDE | `.idea,.vscode` |

脚本已内置上述大部分目录，如项目有特殊生成目录（如 `generated/`、`proto-gen/`），需手动追加到 `--exclude-dir`。

## 口径说明：为什么必须用 `--vcs=git`

不加 `--vcs=git` 时，cloc 统计的是**磁盘上的全部文件**，包括：
- 未跟踪的日志、dump、临时文件
- `.env`、本地配置
- 被 `.gitignore` 忽略但仍存在的构建产物

这会导致行数虚高且不可复现。`--vcs=git` 将统计范围限定为 Git 索引中的文件，结果与提交快照一致。

## 导出示例

```bash
# CSV，便于导入表格
cloc . --vcs=git --exclude-dir=node_modules,target --csv --out=report.csv

# Markdown，便于贴入文档
cloc . --vcs=git --exclude-dir=node_modules,target --md --out=report.md

# 按文件排序，定位最大的 10 个文件
cloc . --vcs=git --by-file --csv --out=by-file.csv
# 然后：sort -t, -k5 -nr by-file.csv | head -10