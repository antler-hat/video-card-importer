#!/bin/bash

# Create build directory
mkdir -p build

# Compile Swift files
swiftc -o build/CanonVideoImporter \
    CanonVideoImporter/*.swift \
    -sdk $(xcrun --show-sdk-path) \
    -framework SwiftUI \
    -framework AppKit

# Create app bundle
mkdir -p "build/CanonVideoImporter.app/Contents/MacOS"
mkdir -p "build/CanonVideoImporter.app/Contents/Resources"

# Copy binary
cp build/CanonVideoImporter "build/CanonVideoImporter.app/Contents/MacOS/"

# Create Info.plist
cat > "build/CanonVideoImporter.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CanonVideoImporter</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.CanonVideoImporter</string>
    <key>CFBundleName</key>
    <string>CanonVideoImporter</string>
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
</dict>
</plist>
EOF

echo "Build complete! App is in build/CanonVideoImporter.app" 