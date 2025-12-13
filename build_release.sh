#!/bin/bash

# Android Release Build Script for Chinese Learning App
# This script builds a release APK and App Bundle for Android

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set up Android environment variables
# Try to detect ANDROID_HOME automatically
if [ -z "$ANDROID_HOME" ]; then
    # Common Android SDK locations
    if [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    elif [ -d "$HOME/android-sdk" ]; then
        export ANDROID_HOME="$HOME/android-sdk"
    elif [ -d "/usr/lib/android-sdk" ]; then
        export ANDROID_HOME="/usr/lib/android-sdk"
    elif [ -d "$HOME/.android/sdk" ]; then
        export ANDROID_HOME="$HOME/.android/sdk"
    fi
fi

# Add Android SDK tools to PATH if ANDROID_HOME is set
if [ -n "$ANDROID_HOME" ]; then
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    echo -e "${GREEN}✓ ANDROID_HOME set to: $ANDROID_HOME${NC}"
else
    echo -e "${YELLOW}⚠ ANDROID_HOME not set. This might cause build issues.${NC}"
    echo -e "${YELLOW}  Set it manually: export ANDROID_HOME=/path/to/android/sdk${NC}"
fi

# Project paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_APP_DIR="${PROJECT_ROOT}/flutter_app"
ANDROID_DIR="${FLUTTER_APP_DIR}/android"
KEY_PROPERTIES="${ANDROID_DIR}/key.properties"
KEYSTORE="${ANDROID_DIR}/app/upload-keystore.jks"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Chinese Learning App - Release Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found: $(flutter --version | head -n 1)${NC}"

# Check Android setup with flutter doctor
echo -e "${YELLOW}Checking Android setup...${NC}"
if flutter doctor | grep -q "Android toolchain.*✗"; then
    echo -e "${YELLOW}⚠ Android toolchain has issues. Checking licenses...${NC}"
    if [ -n "$ANDROID_HOME" ]; then
        echo -e "${YELLOW}Attempting to accept Android licenses...${NC}"
        yes | flutter doctor --android-licenses 2>/dev/null || echo -e "${YELLOW}Some licenses may need manual acceptance${NC}"
    else
        echo -e "${YELLOW}⚠ ANDROID_HOME not set. Android licenses cannot be checked automatically.${NC}"
        echo -e "${YELLOW}  Run: flutter doctor --android-licenses${NC}"
    fi
fi

# Check if keystore exists
if [ ! -f "${KEYSTORE}" ]; then
    echo -e "${RED}Error: Keystore not found at ${KEYSTORE}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Keystore found${NC}"

# Check if key.properties exists
if [ ! -f "${KEY_PROPERTIES}" ]; then
    echo -e "${RED}Error: key.properties not found at ${KEY_PROPERTIES}${NC}"
    echo -e "${YELLOW}Please create key.properties with your keystore credentials${NC}"
    exit 1
fi

echo -e "${GREEN}✓ key.properties found${NC}"
echo ""

# Navigate to flutter app directory
cd "${FLUTTER_APP_DIR}"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}Getting Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies retrieved${NC}"
echo ""

# Build APK
echo -e "${YELLOW}Building release APK...${NC}"
flutter build apk --release
echo -e "${GREEN}✓ APK build complete${NC}"
echo ""

# Build App Bundle (AAB)
echo -e "${YELLOW}Building release App Bundle...${NC}"
flutter build appbundle --release
echo -e "${GREEN}✓ App Bundle build complete${NC}"
echo ""

# Show output files
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Build Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Release APK location:${NC}"
echo "  ${FLUTTER_APP_DIR}/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo -e "${GREEN}Release App Bundle location:${NC}"
echo "  ${FLUTTER_APP_DIR}/build/app/outputs/bundle/release/app-release.aab"
echo ""

# Get file sizes
if [ -f "${FLUTTER_APP_DIR}/build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_SIZE=$(du -h "${FLUTTER_APP_DIR}/build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
    echo -e "${GREEN}APK Size:${NC} ${APK_SIZE}"
fi

if [ -f "${FLUTTER_APP_DIR}/build/app/outputs/bundle/release/app-release.aab" ]; then
    AAB_SIZE=$(du -h "${FLUTTER_APP_DIR}/build/app/outputs/bundle/release/app-release.aab" | cut -f1)
    echo -e "${GREEN}AAB Size:${NC} ${AAB_SIZE}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Release build completed successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
