#!/usr/bin/env bash
# check-env.sh — 统计前的环境检查
set -euo pipefail

TARGET="${1:-.}"

echo "=== 环境检查报告 ==="
echo "目标路径：$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"
echo ""

# 1. Git 仓库
if git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  ROOT=$(git -C "$TARGET" rev-parse --show-toplevel)
  BRANCH=$(git -C "$TARGET" branch --show-current 2>/dev/null || echo "detached")
  echo "[OK]   Git 仓库：$ROOT"
  echo "       当前分支：$BRANCH"
  TRACKED=$(git -C "$TARGET" ls-files | wc -l | tr -d ' ')
  echo "       Git 跟踪文件数：$TRACKED"
  if [[ "$TRACKED" -eq 0 ]]; then
    echo "[WARN] 仓库尚无 Git 跟踪文件，无法统计"
  fi
else
  echo "[FAIL] $TARGET 不是 Git 仓库"
  exit 1
fi

# 2. cloc
if command -v cloc >/dev/null 2>&1; then
  echo "[OK]   cloc：$(cloc --version 2>/dev/null | head -1)"
else
  echo "[WARN] cloc 未安装，安装方式："
  echo "       Debian/Ubuntu: sudo apt install cloc"
  echo "       macOS:         brew install cloc"
  echo "       Node:          npm install -g cloc"
fi

# 3. 工作区状态
DIRTY=$(git -C "$TARGET" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [[ "$DIRTY" -eq 0 ]]; then
  echo "[OK]   工作区干净"
else
  echo "[WARN] 工作区有 $DIRTY 个未提交变更；cloc --vcs=git 仍只统计已跟踪文件"
fi

# 4. 常见依赖/构建目录
echo ""
echo "=== 常见依赖/构建目录检测 ==="
FOUND=0
for dir in node_modules vendor target build dist .next .nuxt venv __pycache__ coverage .gradle .m2; do
  if [[ -d "$TARGET/$dir" ]]; then
    echo "  [存在] $dir"
    FOUND=$((FOUND + 1))
  fi
done
[[ "$FOUND" -eq 0 ]] && echo "  未检测到常见依赖/构建目录"

echo ""
echo "=== 建议 ==="
echo "下一步：bash scripts/count-lines.sh $TARGET"