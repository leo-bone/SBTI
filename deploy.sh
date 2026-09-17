#!/usr/bin/env bash
# 将清理后的 SBTI 仓库强制推送到 GitHub（覆盖被污染的 main 分支）。
#
# 前置条件：
#   1) git 可用。若报错 "xcrun: error: invalid active developer path"，先执行：
#         sudo xcode-select --install
#   2) 已登录 GitHub（gh auth login，或 remote URL 中已含 token）。
#
# 本脚本会用清理后的内容【强制覆盖】 leo-bone/sbti 的 main 分支。
# 清理后的 index.html 与线上正在运行的 SBTI 站点完全一致，因此线上页面不会变化，
# 只是仓库本身恢复正确（删除了水道监测 / 中文名生成器 / MiroFish / gaokao-app 等无关内容）。
set -e

cd "$(dirname "$0")"
REMOTE="https://github.com/leo-bone/sbti.git"

if ! git --version >/dev/null 2>&1; then
  echo "✗ git 不可用。请先修复 Command Line Tools：sudo xcode-select --install"
  exit 1
fi

git init -b main
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE"

git add -A
git commit -m "fix: restore SBTI source, remove unrelated project pollution (waterways/name-gen/mirofish/gaokao)"

echo
echo "即将 force-push 到 $REMOTE 的 main 分支（覆盖污染内容）。"
read -p "确认继续？输入 yes 继续: " ans
if [ "$ans" != "yes" ]; then echo "已取消。"; exit 0; fi

git push --force origin main
echo "✓ 已推送。GitHub Actions 会自动重新部署 Pages，稍候访问 https://sbti.uichain.org"
