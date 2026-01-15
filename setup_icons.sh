#!/bin/bash
# Flutter Launcher Icons Setup Script
# Run this script after placing your icon files in assets/icon/

echo "======================================"
echo "Flutter Launcher Icons Setup"
echo "======================================"
echo ""
echo "Step 1: Getting dependencies..."
flutter pub get
echo ""
echo "Step 2: Generating icons for all platforms..."
flutter pub run flutter_launcher_icons
echo ""
echo "Step 3: Icon generation complete!"
echo ""
echo "Next steps:"
echo "1. Review the generated icons in the respective folders"
echo "2. Run: flutter clean"
echo "3. Run: flutter run"
echo ""
echo "If there are issues, manually check:"
echo "  - Android: android/app/src/main/res/mipmap-*"
echo "  - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "  - Web: web/icons/"
echo "======================================"
