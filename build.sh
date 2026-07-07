#!/bin/bash
echo "Building DesktopTracker..."

# Build release
xcodebuild -project DesktopTracker.xcodeproj \
    -scheme DesktopTracker \
    -configuration Release \
    -derivedDataPath build \
    clean build

# Find .app
APP_PATH=$(find build -name "DesktopTracker.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "Build failed!"
    exit 1
fi

echo "Build successful: $APP_PATH"

# Create DMG
echo "Creating DMG..."
hdiutil create -volname "DesktopTracker" \
    -srcfolder "$APP_PATH" \
    -ov -format UDZO \
    DesktopTracker.dmg

echo "DMG created: DesktopTracker.dmg"
echo ""
echo "To install:"
echo "1. Open DesktopTracker.dmg"
echo "2. Drag DesktopTracker to Applications"
echo "3. Right-click app → Open → Open (to bypass Gatekeeper)"
