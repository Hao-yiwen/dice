#!/bin/bash
set -euo pipefail

# =============================================================================
# macOS Build + Sign + Notarize + DMG Script
# Usage:
#   ./scripts/build-macos-dmg.sh
#
# Credentials (choose one):
#   Option A - Keychain profile (recommended for local use):
#     export NOTARY_KEYCHAIN_PROFILE="dice-notarize"
#
#   Option B - Environment variables:
#     export APPLE_ID="your@email.com"
#     export APPLE_TEAM_ID="84F8R9TAQN"
#     export APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"
# =============================================================================

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="dice.xcodeproj"
SCHEME="dice"
CONFIGURATION="Release"
ARCHIVE_PATH="$PROJECT_DIR/build/dice.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build/export"
DMG_NAME="DiceGenerator.dmg"
DMG_PATH="$PROJECT_DIR/build/$DMG_NAME"
VOLUME_NAME="Dice Generator"
APP_NAME="幸运骰子.app"

# --- Step 1: Clean ---
echo "==> Cleaning build directory..."
rm -rf "$PROJECT_DIR/build"
mkdir -p "$PROJECT_DIR/build"

# --- Step 2: Archive ---
echo "==> Archiving $SCHEME (Release)..."
xcodebuild archive \
    -project "$PROJECT_DIR/$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    CODE_SIGN_IDENTITY="Developer ID Application" \
    DEVELOPMENT_TEAM="84F8R9TAQN" \
    CODE_SIGN_STYLE="Manual"

# --- Step 3: Export ---
echo "==> Exporting archive..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$PROJECT_DIR/ExportOptions-macos.plist"

# --- Step 4: Verify signature ---
echo "==> Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$EXPORT_PATH/$APP_NAME"

# --- Step 5: Notarize app ---
echo "==> Notarizing app..."
NOTARIZE_ZIP="$PROJECT_DIR/build/dice-notarize.zip"
ditto -c -k --keepParent "$EXPORT_PATH/$APP_NAME" "$NOTARIZE_ZIP"

if [ -n "${NOTARY_KEYCHAIN_PROFILE:-}" ]; then
    xcrun notarytool submit "$NOTARIZE_ZIP" \
        --keychain-profile "$NOTARY_KEYCHAIN_PROFILE" \
        --wait
else
    xcrun notarytool submit "$NOTARIZE_ZIP" \
        --apple-id "${APPLE_ID:?Set APPLE_ID or NOTARY_KEYCHAIN_PROFILE}" \
        --team-id "${APPLE_TEAM_ID:-84F8R9TAQN}" \
        --password "${APPLE_APP_PASSWORD:?Set APPLE_APP_PASSWORD}" \
        --wait
fi

# --- Step 6: Staple ---
echo "==> Stapling notarization ticket to app..."
xcrun stapler staple "$EXPORT_PATH/$APP_NAME"

# --- Step 7: Create DMG ---
echo "==> Creating DMG..."
DMG_STAGING="$PROJECT_DIR/build/dmg-staging"
mkdir -p "$DMG_STAGING"
cp -R "$EXPORT_PATH/$APP_NAME" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$DMG_STAGING" \
    -ov -format UDZO \
    "$DMG_PATH"

# --- Step 8: Sign DMG ---
echo "==> Signing DMG..."
codesign --force --sign "Developer ID Application" "$DMG_PATH"

# --- Step 9: Notarize DMG ---
echo "==> Notarizing DMG..."
if [ -n "${NOTARY_KEYCHAIN_PROFILE:-}" ]; then
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_KEYCHAIN_PROFILE" \
        --wait
else
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "${APPLE_TEAM_ID:-84F8R9TAQN}" \
        --password "$APPLE_APP_PASSWORD" \
        --wait
fi

# --- Step 10: Staple DMG ---
echo "==> Stapling notarization ticket to DMG..."
xcrun stapler staple "$DMG_PATH"

# --- Done ---
echo ""
echo "=========================================="
echo "  SUCCESS: $DMG_PATH"
echo "=========================================="
echo ""
echo "Verify with:"
echo "  spctl --assess --type open --context context:primary-signature --verbose \"$DMG_PATH\""
