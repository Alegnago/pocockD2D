#!/bin/bash
# Installa "Pocock D2D.app" in ~/Applications: apre la pagina locale in una finestra dedicata,
# senza server né connessione. Uso: ./install-mac.sh   |   ./install-mac.sh --uninstall
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Applications/Pocock D2D.app"
DATA="$HOME/Library/Application Support/PocockD2D"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Questo installer è solo per macOS." >&2
  exit 1
fi

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -rf "$APP" "$DATA"
  echo "Rimossa: $APP"
  exit 0
fi

for f in index.html icons/AppIcon.icns; do
  [[ -f "$SRC/$f" ]] || { echo "Manca $f: lancia lo script dalla cartella del repo." >&2; exit 1; }
done

mkdir -p "$HOME/Applications"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/www/icons"

cp "$SRC/index.html" "$APP/Contents/Resources/www/"
cp "$SRC/icons/icon-192.png" "$APP/Contents/Resources/www/icons/"
cp "$SRC/icons/AppIcon.icns" "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Pocock D2D</string>
  <key>CFBundleDisplayName</key><string>Pocock D2D</string>
  <key>CFBundleIdentifier</key><string>local.pocock-d2d</string>
  <key>CFBundleExecutable</key><string>PocockD2D</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>10.13</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

# Il launcher apre la pagina in modalità app (finestra senza barre) con il primo browser
# Chromium trovato, su un profilo separato; altrimenti la apre nel browser predefinito.
cat > "$APP/Contents/MacOS/PocockD2D" <<'LAUNCHER'
#!/bin/bash
PAGE="$(cd "$(dirname "$0")/../Resources/www" && pwd)/index.html"
URL="file://${PAGE// /%20}"
PROFILE="$HOME/Library/Application Support/PocockD2D/browser"

for browser in "Google Chrome" "Microsoft Edge" "Brave Browser" "Chromium" "Vivaldi"; do
  if open -Ra "$browser" 2>/dev/null; then
    mkdir -p "$PROFILE"
    exec open -na "$browser" --args --user-data-dir="$PROFILE" --app="$URL" \
      --no-first-run --no-default-browser-check --window-size=1000,900
  fi
done

exec open "$PAGE"
LAUNCHER
chmod +x "$APP/Contents/MacOS/PocockD2D"

# Niente attributo di quarantena sui file copiati da un download, o Gatekeeper blocca l'apertura.
xattr -cr "$APP" 2>/dev/null || true
touch "$APP"

echo "Installata: $APP"
echo "Aprila da Launchpad/Spotlight (\"Pocock D2D\") o trascinala nel Dock."
