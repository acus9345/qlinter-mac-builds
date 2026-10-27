#!/bin/bash
# Wraps a universal binary into a minimal .app bundle.
# Usage: make-app.sh <binary> <App Name> <bundle id> <version> <icon.png> <out dir>
set -euo pipefail
bin="$1"
name="$2"
id="$3"
version="$4"
icon="$5"
out="$6"
app="$out/$name.app"
exe="$(basename "$bin")"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin" "$app/Contents/MacOS/$exe"

iconset="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$iconset"
for s in 16 32 128 256 512; do
  sips -z $s $s "$icon" --out "$iconset/icon_${s}x${s}.png" >/dev/null
  sips -z $((s * 2)) $((s * 2)) "$icon" --out "$iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$iconset" -o "$app/Contents/Resources/AppIcon.icns"

cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>                <string>$name</string>
    <key>CFBundleDisplayName</key>         <string>$name</string>
    <key>CFBundleIdentifier</key>          <string>$id</string>
    <key>CFBundleExecutable</key>          <string>$exe</string>
    <key>CFBundleIconFile</key>            <string>AppIcon</string>
    <key>CFBundlePackageType</key>         <string>APPL</string>
    <key>CFBundleShortVersionString</key>  <string>$version</string>
    <key>CFBundleVersion</key>             <string>$version</string>
    <key>LSMinimumSystemVersion</key>      <string>11.0</string>
    <key>NSHighResolutionCapable</key>     <true/>
</dict>
</plist>
PLIST
codesign --force --deep --sign - "$app"
echo "Built: $app"
