#!/bin/bash
# Packs an .app into a drag-to-Applications .dmg.
# Usage: make-dmg.sh <path/to/App.app> <volume name> <out.dmg>
set -euo pipefail
app="$1"
vol="$2"
out="$3"
stage="$(mktemp -d)"
cp -R "$app" "$stage/"
ln -s /Applications "$stage/Applications"
# ad-hoc signature: required for Apple Silicon to start it; not a Developer ID signature
codesign --force --deep --sign - "$stage/$(basename "$app")"
mkdir -p "$(dirname "$out")"
hdiutil create -volname "$vol" -srcfolder "$stage" -ov -format UDZO "$out"
