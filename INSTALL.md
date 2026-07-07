# Desktop Time Tracker

Native macOS application for time tracking with Trello integration.

## Installation

### Option 1: Direct install
1. Download `DesktopTracker.dmg`
2. Open the DMG file
3. Drag `DesktopTracker.app` to `Applications` folder
4. **Important:** Right-click the app → Select **Open** → Click **Open** again
   (This bypasses macOS Gatekeeper for unsigned apps)

### Option 2: Terminal (one-time)
```bash
xattr -cr /Applications/DesktopTracker.app
```

## First Launch
1. Open the app
2. Click "Sign in with Trello"
3. Authorize in your browser
4. App will detect your account automatically

## Features
- Timer with board/card selection
- Dashboard with time statistics
- Records management with pagination
- Menu bar quick access
- Auto-stop on sleep

## Troubleshooting

### "App is damaged" error
Run in Terminal:
```bash
xattr -cr /Applications/DesktopTracker.app
```

### App won't open
1. Go to System Settings → Privacy & Security
2. Click "Allow Anyway" next to the blocked app message

### Timer not syncing
The app checks for timer updates every 5 seconds. If you start/stop from Trello web, it will sync automatically.
