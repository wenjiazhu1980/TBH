#!/usr/bin/env bash
# 打包 TBH.app — 将 SPM release 产物组装为 macOS 应用包
# 用法: ./scripts/package-app.sh [输出目录，默认 dist]
set -euo pipefail

cd "$(dirname "$0")/.."

OUT_DIR="${1:-dist}"
APP_NAME="TBH"
BUNDLE_ID="com.tbh.game"
VERSION="0.1.2"
RESOURCE_BUNDLE="TBH-macOS_TBH.bundle"  # SPM 资源 bundle 命名：<Package>_<Target>

echo "==> swift build -c release ${SWIFT_BUILD_FLAGS:-}"
if [ -n "${SWIFT_BUILD_FLAGS:-}" ]; then
    # shellcheck disable=SC2086
    swift build -c release ${SWIFT_BUILD_FLAGS}
else
    swift build -c release
fi

if [ -n "${SWIFT_BUILD_FLAGS:-}" ]; then
    # shellcheck disable=SC2086
    BIN_PATH="$(swift build -c release ${SWIFT_BUILD_FLAGS} --show-bin-path)"
else
    BIN_PATH="$(swift build -c release --show-bin-path)"
fi
APP_ROOT="$OUT_DIR/$APP_NAME.app"

echo "==> 组装 $APP_ROOT"
rm -rf "$APP_ROOT"
mkdir -p "$APP_ROOT/Contents/MacOS" "$APP_ROOT/Contents/Resources"

cp "$BIN_PATH/$APP_NAME" "$APP_ROOT/Contents/MacOS/$APP_NAME"

# SPM resources live in the standard app Resources directory. The runtime loader
# resolves this bundle via Bundle.main.resourceURL for packaged .app launches.
if [ -d "$BIN_PATH/$RESOURCE_BUNDLE" ]; then
    cp -R "$BIN_PATH/$RESOURCE_BUNDLE" "$APP_ROOT/Contents/Resources/"
else
    echo "错误: 未找到资源 bundle $RESOURCE_BUNDLE，无法生成可启动的应用包" >&2
    exit 1
fi

cat > "$APP_ROOT/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# 无签名身份时使用 ad-hoc 签名，保证本机可运行
echo "==> codesign (ad-hoc)"
codesign --force --deep --sign - "$APP_ROOT"

echo "==> resource self-test"
"$APP_ROOT/Contents/MacOS/$APP_NAME" --resource-self-test

echo "==> 完成: $APP_ROOT"
