#!/usr/bin/env bash
# count-lines.sh — 基于 cloc 的代码行数统计（快照口径）
set -euo pipefail

TARGET="."
INCLUDE_LANG=""
OUTPUT_FORMAT="text"
MAX_FILE_SIZE=""

usage() {
  cat <<EOF
用法: $0 [路径] [选项]
选项:
  --include-lang=<langs>   仅统计指定语言，逗号分隔，如 Python,TypeScript
  --csv                    导出 CSV 到 cloc-report.csv
  --md                     导出 Markdown 到 cloc-report.md
  --max-file-size=<MB>     跳过大于指定 MB 的文件
  -h, --help               显示帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-lang=*) INCLUDE_LANG="${1#*=}"; shift ;;
    --csv)            OUTPUT_FORMAT="csv"; shift ;;
    --md)             OUTPUT_FORMAT="md"; shift ;;
    --max-file-size=*) MAX_FILE_SIZE="${1#*=}"; shift ;;
    -h|--help)        usage; exit 0 ;;
    -*)               echo "未知选项: $1" >&2; usage; exit 2 ;;
    *)                TARGET="$1"; shift ;;
  esac
done

# --- 前置检查 ---
if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  echo "ERROR: $TARGET 不是 Git 仓库" >&2
  exit 1
fi

if ! command -v cloc >/dev/null 2>&1; then
  echo "ERROR: cloc 未安装。请执行：" >&2
  echo "  Debian/Ubuntu: sudo apt install cloc" >&2
  echo "  macOS:         brew install cloc" >&2
  echo "  Node:          npm install -g cloc" >&2
  exit 2
fi

TRACKED=$(git -C "$TARGET" ls-files | wc -l | tr -d ' ')
if [[ "$TRACKED" -eq 0 ]]; then
  echo "ERROR: 仓库尚无 Git 跟踪文件，无法统计" >&2
  exit 3
fi

# --- 构建 cloc 参数 ---
EXCLUDES="node_modules,vendor,target,build,dist,venv,.git,__pycache__,.next,.nuxt,coverage,.gradle,.m2,out,.idea,.vscode"

CLOC_ARGS=(
  --vcs=git
  --quiet
  --exclude-dir="$EXCLUDES"
)

[[ -n "$INCLUDE_LANG" ]] && CLOC_ARGS+=(--include-lang="$INCLUDE_LANG")
[[ -n "$MAX_FILE_SIZE" ]] && CLOC_ARGS+=(--max-file-size="$MAX_FILE_SIZE")

case "$OUTPUT_FORMAT" in
  csv) CLOC_ARGS+=(--csv --out=cloc-report.csv) ;;
  md)  CLOC_ARGS+=(--md  --out=cloc-report.md)  ;;
esac

# --- 执行 ---
echo "统计路径：$(cd "$TARGET" && pwd)"
echo "口径：快照（cloc --vcs=git，仅 Git 跟踪文件）"
echo "排除目录：$EXCLUDES"
echo ""

cloc "$TARGET" "${CLOC_ARGS[@]}"

if [[ "$OUTPUT_FORMAT" != "text" ]]; then
  echo ""
  echo "已导出：cloc-report.$OUTPUT_FORMAT"
fi