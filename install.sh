#!/bin/bash
set -e

echo "=== mac-hotspot-switcher - Installer ==="

# --- Config ---
SSID_RAW="iPhone 17 Pro"           # Edit: your iPhone name WITHOUT the owner prefix
OWNER="YourName"                    # Edit: your name as it appears in the hotspot SSID
PASSWORD="your-hotspot-password"    # Edit: your iPhone hotspot password
TRIGGER_APP="TeamViewer"            # Edit: app that triggers the switch (e.g. Zoom, FaceTime)
SWIFT_SCRIPT="/usr/local/bin/connect_hotspot.swift"
APP_PATH="/Applications/Hotspot Monitor.app"

# --- Build SSID with curly apostrophe (as macOS stores it) ---
SSID="${OWNER}\xe2\x80\x99s ${SSID_RAW}"

echo ""
echo "Config:"
echo "  SSID     : ${OWNER}'s ${SSID_RAW}"
echo "  Password : ${PASSWORD}"
echo "  Script   : ${SWIFT_SCRIPT}"
echo "  App      : ${APP_PATH}"
echo ""

# 1. Install CoreWLAN Swift script
echo "[1/3] Installing connect_hotspot.swift..."
sed \
  -e "s|Kasidis\\\\u{2019}s iPhone 17 Pro|${OWNER}\\\\u{2019}s ${SSID_RAW}|g" \
  -e "s|servmode|${PASSWORD}|g" \
  connect_hotspot.swift > "$SWIFT_SCRIPT"
echo "      -> $SWIFT_SCRIPT"

# 2. Compile the AppleScript app (inject trigger app name)
echo "[2/3] Compiling Hotspot Monitor.app..."
sed "s/property triggerApp : \"TeamViewer\"/property triggerApp : \"${TRIGGER_APP}\"/" \
  HotspotMonitor.applescript > /tmp/HotspotMonitor_build.applescript
osacompile -x -o "/tmp/Hotspot Monitor.app" /tmp/HotspotMonitor_build.applescript
cp -r "/tmp/Hotspot Monitor.app" "${APP_PATH}" 2>/dev/null || true
echo "      -> ${APP_PATH}"

# 3. Add to Login Items
echo "[3/3] Adding to Login Items..."
osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"${APP_PATH}\", hidden:true}" 2>/dev/null && \
  echo "      -> Added to Login Items (starts at login)" || \
  echo "      -> Note: add manually via System Settings → General → Login Items"

echo ""
echo "Done! Open the app to start monitoring:"
echo "  open '${APP_PATH}'"
echo ""
echo "The app runs silently in the background."
echo "When ${TRIGGER_APP} opens, it auto-switches to your iPhone hotspot."
