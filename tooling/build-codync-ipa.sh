#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPS_DIR="$ROOT_DIR/apps"
OUT_DIR="$ROOT_DIR/build/trollstore"
IPA_NAME="Codync-TrollStore.ipa"
ENTITLEMENTS="$ROOT_DIR/tooling/TrollStore.entitlements"

echo "==> 准备输出目录..."
mkdir -p "$OUT_DIR"

echo "==> 配置 Xcode 允许 Swift Macro 自动化编译..."
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES || true

cd "$APPS_DIR"
echo "==> 使用 xcodegen 生成适用于 iOS 16.0 的 Xcode 工程..."
xcodegen generate --spec project.yml

echo "==> 开始编译 iOS Target (Release, iOS 16.0)..."
xcodebuild clean archive \
  -project Codync.xcodeproj \
  -scheme iOS \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ROOT_DIR/build/Codync.xcarchive" \
  -skipMacroValidation \
  SWIFT_STRICT_CONCURRENCY=minimal \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  IPHONEOS_DEPLOYMENT_TARGET=16.0

APP_PATH="$ROOT_DIR/build/Codync.xcarchive/Products/Applications/Codync.app"

if [ ! -d "$APP_PATH" ]; then
  echo "[-] 未找到编译生成的 Codync.app: $APP_PATH"
  exit 1
fi

echo "==> 打包 Payload 并注入 TrollStore Entitlements..."
PAYLOAD_DIR="$OUT_DIR/Payload"
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/Codync.app"

# 签名所有 Frameworks
if [ -d "$PAYLOAD_DIR/Codync.app/Frameworks" ]; then
  find "$PAYLOAD_DIR/Codync.app/Frameworks" -type d -name "*.framework" | while read -r fw; do
    echo "  -> codesign Framework: $(basename "$fw")"
    codesign --force --sign - --timestamp=none "$fw" || true
  done
  find "$PAYLOAD_DIR/Codync.app/Frameworks" -type f -name "*.dylib" | while read -r dylib; do
    echo "  -> codesign Dylib: $(basename "$dylib")"
    codesign --force --sign - --timestamp=none "$dylib" || true
  done
fi

echo "==> codesign 注入 TrollStore Entitlements..."
codesign --force --sign - --entitlements "$ENTITLEMENTS" --timestamp=none "$PAYLOAD_DIR/Codync.app"

echo "==> 压缩生成 IPA..."
cd "$OUT_DIR"
rm -f "$IPA_NAME"
zip -qry "$IPA_NAME" Payload

echo "==> [成功] IPA 已生成: $OUT_DIR/$IPA_NAME"
ls -lh "$OUT_DIR/$IPA_NAME"
