#!/usr/bin/env bash
# author-stats.sh — 按作者统计贡献（历史变更口径）
set -euo pipefail

TARGET="."
SINCE=""
UNTIL=""
TOP=""

usage() {
  cat <<EOF
用法: $0 [路径] [选项]
选项:
  --since=<date>   起始日期，如 2025-01-01
  --until=<date>   截止日期，如 2025-12-31
  --top=<N>        仅显示净增行数前 N 名
  -h, --help       显示帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since=*) SINCE="${1#*=}"; shift ;;
    --until=*) UNTIL="${1#*=}"; shift ;;
    --top=*)   TOP="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "未知选项: $1" >&2; usage; exit 2 ;;
    *)         TARGET="$1"; shift ;;
  esac
done

if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  echo "ERROR: $TARGET 不是 Git 仓库" >&2
  exit 1
fi

GIT_LOG_ARGS=(--pretty=tformat: --numstat --all)
[[ -n "$SINCE" ]] && GIT_LOG_ARGS+=(--since="$SINCE")
[[ -n "$UNTIL" ]] && GIT_LOG_ARGS+=(--until="$UNTIL")

echo "统计路径：$(cd "$TARGET" && pwd)"
echo "口径：历史变更（git log --numstat --all）"
[[ -n "$SINCE" || -n "$UNTIL" ]] && echo "时间范围：${SINCE:-起始} ~ ${UNTIL:-至今}"
echo ""
printf "%-24s %8s %12s %12s %12s\n" "作者" "提交数" "新增行数" "删除行数" "净增行数"
printf '%.0s-' {1..72}; echo

git -C "$TARGET" shortlog -sn --all | while read -r count author; do
  git -C "$TARGET" log --author="$author" "${GIT_LOG_ARGS[@]}" | awk -v a="$author" -v c="$count" '
    NF==3 && $1 != "-" && $2 != "-" { add += $1; del += $2 }
    END { printf "%-24s %8d %12d %12d %12d\n", a, c, add, del, add-del }
  '
done | { if [[ -n "$TOP" ]]; then sort -k3 -nr | head -n "$TOP"; else sort -k3 -nr; fi; }