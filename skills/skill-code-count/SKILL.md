---
name: skill-code-count
version: 1.1.0
display_name: 项目量化助手
display_name_en: Code row count
description: 统计 Git 项目的代码行数，支持按总量、按作者、按语言量化，自动排除依赖/构建目录。Use when 用户询问“代码行数/代码量化/项目代码量/项目代码行数/统计代码/代码贡献/各作者贡献”。
description_zh: 项目代码量化统计。
description_en: Project code row count.
author: 花狸
category: tool
agent_created: true
allowed-tools: Bash(git:*) Bash(cloc:*) Bash(bash:*) Bash(which:*) Read Glob
compatibility: 需要 Git 与 cloc；目标路径须为 Git 仓库。
metadata:
  runtime: bash
  risk: read-only
  scripts: scripts/check-env.sh, scripts/count-lines.sh, scripts/author-stats.sh
---

# 代码统计

## 概述

统计指定 Git 项目的代码行数，用于量化项目规模与开发投入。默认仅统计 **Git 跟踪的文件**，并显式排除 `node_modules`、`vendor`、`target`、`build`、`dist` 等第三方/构建目录，避免依赖代码稀释真实工程量。

输出包含 **代码行 / 注释行 / 空白行**（cloc 三分类），以及可选的 **按作者新增/删除行数**（git log 统计）。两种口径不同，不可混用，详见 `references/metric-definitions.md`。

## 前置条件

1. 目标路径是 Git 仓库（`git rev-parse --git-dir` 成功）。
2. `cloc` 可用。未安装时按顺序尝试：`sudo apt install cloc` / `brew install cloc` / `npm install -g cloc`。
3. 推荐在 clean working tree 下统计。dirty 状态下 cloc 统计的是磁盘实际内容，可能包含未跟踪文件。

执行 `scripts/check-env.sh <path>` 可一次性输出上述检查结果与常见依赖目录检测。

## 何时使用

触发场景：
- “统计这个项目的代码行数”
- “这个仓库有多少行代码”
- “项目代码量化 / 工作量统计”
- “看看各个作者的代码贡献”
- “按语言统计代码行数”
- 用户提供了 Git 仓库路径或 URL，询问代码规模

**不触发**：单纯问“这个文件多少行”、统计非 Git 目录、或需要逐行内容分析而非行数汇总时。

## 操作步骤

### 第一步：环境检查

```bash
bash scripts/check-env.sh <项目路径>