#!/usr/bin/env bash
# Linux/macOS 静态工程一致性检查（不替代 xcodebuild）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 <<'PY'
import re
import sys
from pathlib import Path

root = Path('.')
errors: list[str] = []

def err(msg: str) -> None:
    errors.append(msg)

pbx = (root / 'dice.xcodeproj/project.pbxproj').read_text()

required = [
    'dice_ios/Info.plist',
    'dice_ios/ShakeMotionDetector.swift',
    'dice_ios/PrivacyInfo.xcprivacy',
    'dice_ios_widget/Info.plist',
    'scripts/verify-project.sh',
]
for rel in required:
    if not (root / rel).exists():
        err(f'missing file: {rel}')

if 'LastUpgradeCheck = 1600;' not in pbx:
    err('LastUpgradeCheck should be 1600 (project does not require Xcode 27)')
if 'SWIFT_STRICT_CONCURRENCY = minimal;' not in pbx:
    err('SWIFT_STRICT_CONCURRENCY minimal not set at project level')

# deployment + swift version
if set(re.findall(r'MACOSX_DEPLOYMENT_TARGET = ([0-9.]+);', pbx)) != {'14.0'}:
    err('macOS deployment target not unified to 14.0')
if set(re.findall(r'IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);', pbx)) != {'17.0'}:
    err('iOS deployment target expected 17.0')
if set(re.findall(r'SWIFT_VERSION = ([^;]+);', pbx)) != {'5.0'}:
    err('SWIFT_VERSION expected 5.0')

if 'INFOPLIST_FILE = dice_ios/Info.plist;' not in pbx:
    err('dice_ios INFOPLIST_FILE not set')
if 'Exceptions for "dice_ios" folder in "dice_ios" target' not in pbx:
    err('dice_ios Info.plist exception set missing')

info = (root / 'dice_ios/Info.plist').read_text()
if 'diceapp' not in info:
    err('dice_ios/Info.plist missing diceapp URL scheme')

# schemes should launch in Debug
for scheme in ['dice.xcscheme', 'dice_ios.xcscheme']:
    text = (root / 'dice.xcodeproj/xcshareddata/xcschemes' / scheme).read_text()
    if 'buildConfiguration = "Debug"' not in text.split('<LaunchAction')[1].split('</LaunchAction>')[0]:
        err(f'{scheme}: LaunchAction should use Debug')

# deprecated APIs / fragile patterns
for path in root.rglob('*.swift'):
    text = path.read_text()
    rel = path.as_posix()
    for pat, label in [
        (r'\.lockFocus\s*\(', 'NSImage.lockFocus'),
        (r'UIGraphicsBeginImageContextWithOptions\s*\(', 'UIGraphicsBeginImageContextWithOptions'),
        (r'extension UIWindow', 'global UIWindow override'),
        (r'getTimeline\s*\(.*completion:', 'completion-based Widget timeline'),
    ]:
        if re.search(pat, text):
            err(f'{label} still present in {rel}')

content_view = (root / 'dice_ios/DiceContentView.swift').read_text()
if '.onOpenURL' not in content_view:
    err('DiceContentView missing onOpenURL handler')

shake = (root / 'dice_ios/ShakeMotionDetector.swift').read_text()
if 'UIViewRepresentable' not in shake or 'canBecomeFirstResponder' not in shake:
    err('ShakeMotionDetector must be a first-responder UIView representable')

widget = (root / 'dice_ios_widget/dice_ios_widget.swift').read_text()
if 'func timeline(in context: Context) async' not in widget:
    err('widget provider should use async timeline API (iOS 17+)')

# tracked user data
for tracked in [
    root / 'dice.xcodeproj/project.xcworkspace/xcuserdata',
]:
    if tracked.exists() and any(tracked.rglob('*')):
        # local exists is fine; ensure git index doesn't include
        pass

print('Static verify: OK' if not errors else 'Static verify: FAILED')
for e in errors:
    print(' -', e)
if errors:
    sys.exit(1)
PY

if [[ -x "$ROOT/scripts/swift-syntax-check.sh" ]]; then
  "$ROOT/scripts/swift-syntax-check.sh"
fi

echo "All static checks passed."