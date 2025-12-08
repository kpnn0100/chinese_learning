#!/bin/bash

echo "🚀 Starting Chinese Flashcard Flutter App..."
echo ""

cd "$(dirname "$0")/flutter_app"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "📦 Checking dependencies..."
flutter pub get

echo ""
echo "🎨 Available devices:"
flutter devices

echo ""
echo "🏃 Running app..."
flutter run
