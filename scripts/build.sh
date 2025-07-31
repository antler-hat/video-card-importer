#!/bin/bash

# Create build directory
mkdir -p build

# Compile Swift files
swiftc -o build/VideoCardImporter \
    AVCHDVideoImporter/*.swift \
    -sdk $(xcrun --show-sdk-path) \
    -framework SwiftUI \
    -framework AppKit

# Create app bundle
mkdir -p "build/VideoCardImporter.app/Contents/MacOS"
mkdir -p "build/VideoCardImporter.app/Contents/Resources"

# Copy binary
cp build/VideoCardImporter "build/VideoCardImporter.app/Contents/MacOS/"

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
</dict>
</plist>
EOF

echo "Build complete! App is in build/VideoCardImporter.app"
