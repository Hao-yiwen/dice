#!/usr/bin/env bash
# 使用 Swift 开源工具链做语法级检查（不链接 iOS/macOS SDK）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SWIFT="${SWIFT_TOOLCHAIN:-$ROOT/.swift-toolchain/usr/bin/swift}"

if [[ ! -x "$SWIFT" ]]; then
  echo "SKIP: Swift toolchain not found at $SWIFT"
  echo "Set SWIFT_TOOLCHAIN or extract swift.org toolchain to $ROOT/.swift-toolchain"
  exit 0
fi

echo "Using: $($SWIFT --version | head -1)"

fail=0
while IFS= read -r -d '' file; do
  if ! "$SWIFT" frontend -parse "$file" >/dev/null 2>&1; then
    echo "PARSE FAIL: $file"
    "$SWIFT" frontend -parse "$file" 2>&1 | head -20
    fail=1
  fi
done < <(find "$ROOT" -path "$ROOT/.swift-toolchain" -prune -o -name '*.swift' -print0)

if [[ "$fail" -ne 0 ]]; then
  echo "Swift syntax check failed."
  exit 1
fi

echo "Swift syntax check passed for all .swift files."