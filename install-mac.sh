#!/bin/bash
# Installa "Pocock D2D.app" in ~/Applications: pannello nascosto, su tutte le scrivanie, che si apre
# con una scorciatoia globale sulla P. Parte da solo al login.
# Uso: ./install-mac.sh   |   ./install-mac.sh --uninstall
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Applications/Pocock D2D.app"
DATA="$HOME/Library/Application Support/PocockD2D"
LABEL="local.pocock-d2d"
AGENT="$HOME/Library/LaunchAgents/$LABEL.plist"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Questo installer è solo per macOS." >&2
  exit 1
fi

stop_app() {
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
  pkill -f "$APP/Contents/MacOS/PocockD2D" 2>/dev/null || true
}

if [[ "${1:-}" == "--uninstall" ]]; then
  stop_app
  rm -rf "$APP" "$DATA" "$AGENT"
  echo "Rimossa: $APP"
  exit 0
fi

for f in index.html icons/AppIcon.icns mac/PocockD2D.swift; do
  [[ -f "$SRC/$f" ]] || { echo "Manca $f: lancia lo script dalla cartella del repo." >&2; exit 1; }
done

if ! xcrun --find swiftc >/dev/null 2>&1; then
  echo "Servono gli strumenti da riga di comando di Apple (gratis). Si apre l'installazione:" >&2
  echo "al termine rilancia ./install-mac.sh" >&2
  xcode-select --install || true
  exit 1
fi

stop_app
mkdir -p "$HOME/Applications" "$HOME/Library/LaunchAgents" "$DATA"
rm -rf "$APP" "$DATA/shortcut.txt"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/www/icons"

cp "$SRC/index.html" "$APP/Contents/Resources/www/"
cp "$SRC/icons/icon-192.png" "$APP/Contents/Resources/www/icons/"
cp "$SRC/icons/AppIcon.icns" "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Pocock D2D</string>
  <key>CFBundleDisplayName</key><string>Pocock D2D</string>
  <key>CFBundleIdentifier</key><string>$LABEL</string>
  <key>CFBundleExecutable</key><string>PocockD2D</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>2.0</string>
  <key>CFBundleVersion</key><string>2</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "Compilo l'app…"
xcrun swiftc -O "$SRC/mac/PocockD2D.swift" -o "$APP/Contents/MacOS/PocockD2D" \
  -framework Cocoa -framework WebKit -framework Carbon

xattr -cr "$APP" 2>/dev/null || true
touch "$APP"

# Avvio automatico al login (e subito).
cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$APP/Contents/MacOS/PocockD2D</string></array>
  <key>RunAtLoad</key><true/>
  <key>ProcessType</key><string>Interactive</string>
</dict>
</plist>
PLIST
launchctl bootstrap "gui/$(id -u)" "$AGENT"

for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -f "$DATA/shortcut.txt" ]] && break
  sleep 0.5
done
open "$APP"  # mostra il pannello una prima volta

echo "Installata: $APP (parte da sola al login, non compare nel Dock)"
echo "Scorciatoia: $(cat "$DATA/shortcut.txt" 2>/dev/null || echo 'non rilevata, vedi README')"
echo "Esc o la stessa scorciatoia la nascondono."
