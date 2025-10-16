#!/bin/bash

# Create build directory
mkdir -p build

# Compile Swift files
swiftc -o build/VideoCardImporter \
    VideoCardImporter/*.swift \
    -sdk $(xcrun --show-sdk-path) \
    -framework SwiftUI \
    -framework AppKit

# Create app bundle
mkdir -p "build/VideoCardImporter.app/Contents/MacOS"
mkdir -p "build/VideoCardImporter.app/Contents/Resources"

# Copy binary
cp build/VideoCardImporter "build/VideoCardImporter.app/Contents/MacOS/"

# Copy app icon resources
ICONSET_DIR="VideoCardImporter/Assets.xcassets/AppIcon.appiconset"
if [ -d "$ICONSET_DIR" ]; then
    cp "$ICONSET_DIR"/*.png "build/VideoCardImporter.app/Contents/Resources/" 2>/dev/null || true
    ICON_FILE=$(ls "$ICONSET_DIR" | grep -E 'icon_512x512(@2x)?\.png' | head -n 1)
    if [ -n "$ICON_FILE" ]; then
        sips -s format icns "$ICONSET_DIR/$ICON_FILE" --out "build/VideoCardImporter.app/Contents/Resources/AppIcon.icns" >/dev/null 2>&1
    fi
fi

# Create Info.plist
cat > "build/VideoCardImporter.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>VideoCardImporter</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.VideoCardImporter</string>
    <key>CFBundleName</key>
    <string>VideoCardImporter</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.video</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Create DMG
DMG_NAME="VideoCardImporter.dmg"
hdiutil create -volname "VideoCardImporter" -srcfolder "build/VideoCardImporter.app" -ov -format UDZO "build/$DMG_NAME"

echo "Build complete! App is in build/VideoCardImporter.app"
echo "DMG created at build/$DMG_NAME"
