#!/bin/bash
# 把本机 ~/.agents/skills 的 dbs 家族镜像进本仓库并推送
# 用法：~/dbskill-personal/sync.sh "备注"
set -euo pipefail

SRC="$HOME/.agents/skills"
ROOT="$(cd "$(dirname "$0")" && pwd)"
DST="$ROOT/skills"
# 不入库：官方已下线、本机已移除（备份在 ~/.dbs/retired-skills/）
EXCLUDE=" dbs-hook dbs-xhs-title dbs-agent-migration "

[[ -d "$SRC" ]] || { echo "真源目录不存在：$SRC"; exit 1; }

for d in "$SRC"/dbs*/; do
  name="$(basename "$d")"
  [[ "$EXCLUDE" == *" $name "* ]] && continue
  mkdir -p "$DST/$name"
  rsync -a --delete --exclude '.DS_Store' "$d" "$DST/$name/"
done

# 本机已消失的 skill，仓库同步移除（保持镜像）
for d in "$DST"/dbs*/; do
  name="$(basename "$d")"
  [[ "$EXCLUDE" == *" $name "* ]] && continue
  [[ -d "$SRC/$name" ]] || rm -rf "$DST/$name"
done

cd "$ROOT"
git add -A
if git diff --cached --quiet; then
  echo "无变化，不需要同步"
  exit 0
fi
git commit -m "sync: ${1:-本机同步 $(date +%Y-%m-%d\ %H:%M)}"
git push
echo "已推送 $(git log -1 --format='%h %s')"
