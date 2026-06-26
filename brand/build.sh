#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Snippeter brand asset build.
#
# Renders every platform icon/favicon/social asset from the master SVGs in this
# directory. Single source of truth — re-run after editing any brand/*.svg.
#
# Requires: rsvg-convert (librsvg), node (for the .ico packer). Fonts for the
# raster wordmark are vendored in brand/fonts and wired via a local fontconfig.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

BRAND="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$BRAND/.." && pwd)"
cd "$ROOT"

# Local fontconfig so the vendored Space Grotesk resolves without a system install.
FC_DIR="$BRAND/.fontcache"; mkdir -p "$FC_DIR"
FC_CONF="$BRAND/.fonts.conf"
cat > "$FC_CONF" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>$BRAND/fonts</dir>
  <cachedir>$FC_DIR</cachedir>
  <include ignore_missing="yes">/opt/homebrew/etc/fonts/fonts.conf</include>
  <include ignore_missing="yes">/usr/local/etc/fonts/fonts.conf</include>
  <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
</fontconfig>
EOF
export FONTCONFIG_FILE="$FC_CONF"

# render <svg> <w> <h> <out> [bgcolor]
render() {
  local svg="$1" w="$2" h="$3" out="$4" bg="${5:-}"
  mkdir -p "$(dirname "$out")"
  if [ -n "$bg" ]; then
    rsvg-convert -w "$w" -h "$h" -b "$bg" "$BRAND/$svg" -o "$out"
  else
    rsvg-convert -w "$w" -h "$h" "$BRAND/$svg" -o "$out"
  fi
}

echo "▸ Web (Flutter web shell)"
render icon.svg          48  48  web/favicon.png
render icon.svg          192 192 web/icons/Icon-192.png
render icon.svg          512 512 web/icons/Icon-512.png
render icon-maskable.svg 192 192 web/icons/Icon-maskable-192.png
render icon-maskable.svg 512 512 web/icons/Icon-maskable-512.png

echo "▸ Android — legacy mipmaps + adaptive icon"
declare -a AND_DPI=("mdpi:48:108" "hdpi:72:162" "xhdpi:96:216" "xxhdpi:144:324" "xxxhdpi:192:432")
for e in "${AND_DPI[@]}"; do
  IFS=: read -r dpi launch adaptive <<< "$e"
  d="android/app/src/main/res/mipmap-$dpi"
  render icon.svg            "$launch"   "$launch"   "$d/ic_launcher.png"
  render icon.svg            "$launch"   "$launch"   "$d/ic_launcher_round.png"
  render icon-foreground.svg "$adaptive" "$adaptive" "$d/ic_launcher_foreground.png"
  render icon-background.svg "$adaptive" "$adaptive" "$d/ic_launcher_background.png"
done
mkdir -p android/app/src/main/res/mipmap-anydpi-v26
cat > android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
XML
cp android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml \
   android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml

echo "▸ iOS — AppIcon.appiconset (opaque, no alpha bleed)"
ios="ios/Runner/Assets.xcassets/AppIcon.appiconset"
declare -a IOS=( \
  "20:Icon-App-20x20@1x.png" "40:Icon-App-20x20@2x.png" "60:Icon-App-20x20@3x.png" \
  "29:Icon-App-29x29@1x.png" "58:Icon-App-29x29@2x.png" "87:Icon-App-29x29@3x.png" \
  "40:Icon-App-40x40@1x.png" "80:Icon-App-40x40@2x.png" "120:Icon-App-40x40@3x.png" \
  "120:Icon-App-60x60@2x.png" "180:Icon-App-60x60@3x.png" \
  "76:Icon-App-76x76@1x.png" "152:Icon-App-76x76@2x.png" "167:Icon-App-83.5x83.5@2x.png" \
  "1024:Icon-App-1024x1024@1x.png" )
for e in "${IOS[@]}"; do
  IFS=: read -r px name <<< "$e"
  render icon-fullbleed.svg "$px" "$px" "$ios/$name" "#13151A"
done

echo "▸ macOS — AppIcon.appiconset (rounded w/ margin)"
mac="macos/Runner/Assets.xcassets/AppIcon.appiconset"
for px in 16 32 64 128 256 512 1024; do
  render icon-macos.svg "$px" "$px" "$mac/app_icon_$px.png"
done

echo "▸ Windows — multi-res .ico"
tmp="$(mktemp -d)"
for px in 16 24 32 48 64 128 256; do
  render icon-fullbleed.svg "$px" "$px" "$tmp/w$px.png" "#13151A"
done
node "$BRAND/png2ico.mjs" windows/runner/resources/app_icon.ico \
  "$tmp/w16.png" "$tmp/w24.png" "$tmp/w32.png" "$tmp/w48.png" "$tmp/w64.png" "$tmp/w128.png" "$tmp/w256.png"
rm -rf "$tmp"

echo "▸ Linux — packaging icon"
render icon.svg 256 256 linux/snippeter.png

echo "▸ Chrome extension"
render icon.svg 16  16  integrations/chrome/icons/icon16.png
render icon.svg 48  48  integrations/chrome/icons/icon48.png
render icon.svg 128 128 integrations/chrome/icons/icon128.png
cp "$BRAND/icon.svg" integrations/chrome/icons/icon.svg

echo "▸ VS Code extension"
render icon.svg 128 128 integrations/vscode/icon.png

echo "▸ JetBrains plugin"
cp "$BRAND/icon.svg" integrations/jetbrains/src/main/resources/META-INF/pluginIcon.svg
cp "$BRAND/icon.svg" integrations/jetbrains/src/main/resources/META-INF/pluginIcon_dark.svg

echo "▸ Landing (Next.js) — favicon, apple-icon, social cards"
cp "$BRAND/icon.svg" landing/app/icon.svg
render icon.svg 180 180 landing/app/apple-icon.png
render og.svg  1200 630 landing/app/opengraph-image.png
cp landing/app/opengraph-image.png landing/app/twitter-image.png

echo "▸ Brand previews (for the design-system pane / docs)"
render icon.svg          512 512 "$BRAND/preview-icon.png"
render lockup-dark.svg   760 200 "$BRAND/preview-lockup-dark.png" "#0D0E11"
render og.svg           1200 630 "$BRAND/preview-og.png"

echo "✓ Brand build complete."
