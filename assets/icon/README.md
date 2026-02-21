# App Icons

## Setup Instructions

To use your custom app icon:

1. **Prepare your icon**:
   - Create a square icon (preferably 1024x1024 or larger)
   - PNG format recommended
   - Make sure it has enough padding/margin from edges

2. **Place icons in this directory**:
   - `icon.png` - Main icon for Android, Web, Windows, Linux, and macOS
   - `icon_ios.png` - Optional: iOS-specific icon (for better results on iOS)

3. **Generate icons**:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

4. **Rebuild your app**:
   ```bash
   flutter clean
   flutter run
   ```

## Icon Specifications

- **Minimum size**: 512x512 pixels
- **Recommended size**: 1024x1024 pixels
- **Format**: PNG (with transparency recommended)
- **Safe area**: Keep important content within center 87% of the icon
- **Background**: Transparent or solid color matching your app theme

## Generated Assets

After running `flutter pub run flutter_launcher_icons`, icons will be automatically generated for:
- **Android**: `android/app/src/main/res/mipmap-*`
- **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Web**: `web/icons/`
- **macOS**: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Windows**: `windows/runner/resources/`
- **Linux**: `linux/` (requires manual XPM format if needed)
