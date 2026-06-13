#!/usr/bin/env bash
# 远程构建 — 将项目同步到一台装有完整 Xcode 的远程 Mac 上构建/测试/打包
#
# 本机仅有 Command Line Tools（无 XCTest / swift-testing）时，
# 用此脚本在远程机器上执行完整测试与打包，产物自动取回本地 dist/。
#
# 配置（环境变量）:
#   TBH_REMOTE_HOST  必填，SSH 目标，如 user@buildmac.local
#   TBH_REMOTE_DIR   远程工作目录，默认 ~/remote-builds/TBH
#
# 用法:
#   ./scripts/remote-build.sh build     # 远程 swift build
#   ./scripts/remote-build.sh test      # 远程 swift test（完整 swift-testing 套件）
#   ./scripts/remote-build.sh package   # 远程打包 TBH.app 并取回到本地 dist/
set -euo pipefail

cd "$(dirname "$0")/.."

REMOTE_HOST="${TBH_REMOTE_HOST:?请设置 TBH_REMOTE_HOST，例如 user@buildmac.local}"
REMOTE_DIR="${TBH_REMOTE_DIR:-\$HOME/remote-builds/TBH}"
ACTION="${1:-build}"

echo "==> 同步源码到 $REMOTE_HOST:$REMOTE_DIR"
ssh "$REMOTE_HOST" "mkdir -p $REMOTE_DIR"
rsync -az --delete \
    --exclude '.build' \
    --exclude 'dist' \
    --exclude '.DS_Store' \
    --exclude '.remember' \
    --exclude '.claude' \
    --exclude 'Resources/Assets.xcassets/steam_source' \
    ./ "$REMOTE_HOST:$REMOTE_DIR/"

case "$ACTION" in
    build)
        echo "==> 远程构建"
        ssh "$REMOTE_HOST" "cd $REMOTE_DIR && swift build"
        ;;
    test)
        echo "==> 远程测试（swift build + 完整 swift-testing 套件 + self-test）"
        ssh "$REMOTE_HOST" "cd $REMOTE_DIR && swift build && swift test && swift run TBH --self-test"
        ;;
    package)
        echo "==> 远程打包"
        ssh "$REMOTE_HOST" "cd $REMOTE_DIR && bash scripts/package-app.sh dist"
        echo "==> 取回产物到本地 dist/"
        mkdir -p dist
        rsync -az "$REMOTE_HOST:$REMOTE_DIR/dist/TBH.app" dist/
        echo "==> 完成: dist/TBH.app"
        ;;
    *)
        echo "未知操作: $ACTION（可用: build | test | package）" >&2
        exit 1
        ;;
esac
