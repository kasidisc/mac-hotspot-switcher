# mac-hotspot-switcher

Auto-switches your Mac to iPhone Personal Hotspot when a specified app opens.

Built for **macOS 26 (Tahoe)** — uses CoreWLAN via the Swift interpreter to bypass the broken `networksetup` and removed `airport` CLI on newer macOS versions.

---

## How it works

- A background AppleScript applet polls every 5 seconds
- When your trigger app launches, it runs `connect_hotspot.swift` via `swift`
- The Swift script uses CoreWLAN to scan and join your iPhone hotspot
- Shows a macOS notification on connect, or a Ping alert if hotspot isn't broadcasting yet

```
Trigger app opens
       ↓
  pgrep -x <app>
       ↓
  swift connect_hotspot.swift
       ↓
  CoreWLAN: scan → associate("Your iPhone", password)
       ↓
  Notification: "Hotspot Connected"
```

---

## Requirements

- macOS 15+ (Sequoia / Tahoe) — tested on macOS 26.5.1
- iPhone with Personal Hotspot enabled
- Both devices signed into the same Apple ID (for Instant Hotspot discovery)
- Xcode Command Line Tools (`xcode-select --install`)

---

## Quick install

```bash
git clone https://github.com/kasidisc/mac-hotspot-switcher
cd mac-hotspot-switcher

# Edit install.sh — set your iPhone name, owner name, hotspot password, and trigger app
nano install.sh

# Run installer
bash install.sh

# Launch the app
open '/Applications/Hotspot Monitor.app'
```

---

## Manual setup

### 1. Edit `connect_hotspot.swift`

```swift
let ssid = "YourName\u{2019}s iPhone XX Pro"  // curly apostrophe — copy from:
                                                // networksetup -listpreferredwirelessnetworks en0
let password = "your-hotspot-password"
```

> **Important:** The apostrophe in iPhone hotspot SSIDs is a Unicode RIGHT SINGLE QUOTATION MARK (`'`, U+2019), not a straight apostrophe. Copy the exact SSID from `networksetup -listpreferredwirelessnetworks en0`.

### 2. Edit `HotspotMonitor.applescript`

```applescript
property triggerApp : "YourApp"  -- e.g. "Zoom", "FaceTime", "Discord", "OBS"
```

### 3. Install the Swift script

```bash
cp connect_hotspot.swift /usr/local/bin/connect_hotspot.swift
```

### 4. Build the app

```bash
osacompile -x -o '/Applications/Hotspot Monitor.app' HotspotMonitor.applescript
```

### 5. Launch

```bash
open '/Applications/Hotspot Monitor.app'
```

Add to **System Settings → General → Login Items** to start it automatically.

---

## Why `swift` instead of a compiled binary?

`CWInterface.associate()` (CoreWLAN) requires Apple-signed entitlements to join networks on macOS 15+. Ad-hoc signed or unsigned binaries get `tmpErr (-3900)`. Running the script through the `swift` interpreter (which carries Apple's signature and entitlements) works around this without needing a developer certificate.

---

## Trigger app examples

Change `triggerApp` in `HotspotMonitor.applescript` to any process name:

| Use case | `triggerApp` value |
|---|---|
| Remote desktop | `TeamViewer` |
| Video calls | `zoom.us` |
| Screen recording | `OBS` |
| Gaming | `Steam` |
| Video conferencing | `FaceTime` |

---

## Notifications

| Event | Sound | Message |
|---|---|---|
| Hotspot switched | Glass | "Switched to iPhone hotspot" |
| Hotspot not broadcasting | Ping (repeats) | "Turn on Personal Hotspot on your iPhone" |

---

## Files

| File | Purpose |
|---|---|
| `connect_hotspot.swift` | CoreWLAN script — scans and joins the hotspot |
| `HotspotMonitor.applescript` | Background applet — watches for the trigger app |
| `install.sh` | Automated installer |
