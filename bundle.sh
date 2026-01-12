#!/bin/bash
set -e

# Build the executable
echo "Building SolderScope..."
swift build -c release

# Set up paths
APP_NAME="SolderScope"
BUILD_DIR=".build/release"
BUNDLE_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean and create bundle structure
rm -rf "$BUNDLE_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Copy Info.plist
cp "SolderScope/Metadata/Info.plist" "$CONTENTS_DIR/"

# Copy entitlements if they exist
if [ -f "SolderScope/Metadata/SolderScope.entitlements" ]; then
    cp "SolderScope/Metadata/SolderScope.entitlements" "$CONTENTS_DIR/"
fi

# Create PkgInfo
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Copy icon if it exists
if [ -f "SolderScope/Metadata/AppIcon.icns" ]; then
    cp "SolderScope/Metadata/AppIcon.icns" "$RESOURCES_DIR/"
fi

echo "Bundle created at: $BUNDLE_DIR"
echo ""
echo "To install, run:"
echo "  cp -r \"$BUNDLE_DIR\" /Applications/"
echo ""
echo "Or open directly:"
echo "  open \"$BUNDLE_DIR\""
