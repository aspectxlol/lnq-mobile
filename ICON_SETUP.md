# Flutter Launcher Icons Setup - Complete Guide

## Overview

Flutter Launcher Icons has been configured for the LNQ Mobile app. This tool automatically generates app icons for all platforms (Android, iOS, Web, Windows, macOS, Linux) from a single source icon.

## Configuration Details

The configuration is already set up in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true                              # Generate Android icons
  ios: true                                  # Generate iOS icons
  image_path: "assets/icon/icon.png"        # Main icon source (512x512+)
  image_path_ios: "assets/icon/icon_ios.png" # Optional iOS-specific icon
  min_sdk_android: 21                        # Minimum Android SDK
  web:
    generate: true
    image_path: "assets/icon/icon.png"
    background_color: "#1A1A1A"             # Dark background matching theme
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
  macos:
    generate: true
    image_path: "assets/icon/icon.png"
  linux:
    generate: true
    image_path: "assets/icon/icon.png"
```

## How to Use Your Custom Icon

### 1. Prepare Your Icon File

Create or export your custom app icon:
- **Format**: PNG with transparency (recommended)
- **Size**: 1024x1024 pixels (minimum 512x512)
- **Safe area**: Keep important content within the center 87% to avoid clipping
- **No background**: Use transparent background for better results on all platforms

### 2. Place Icon Files

Copy your icon files to the `assets/icon/` directory:

```
assets/
└── icon/
    ├── icon.png              (Required: Main icon for all platforms)
    ├── icon_ios.png          (Optional: iOS-specific icon for better results)
    └── README.md
```

### 3. Generate Icons

Run the icon generation command:

```bash
flutter pub run flutter_launcher_icons
```

Or use the provided setup script:
```bash
bash setup_icons.sh
```

### 4. Rebuild the App

After generating icons, rebuild your app:

```bash
flutter clean
flutter run
```

## Platform-Specific Generated Assets

After running the icon generation, icons will be created in:

### Android
- `android/app/src/main/res/mipmap-ldpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### iOS
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (various sizes)

### Web
- `web/icons/` (Icon-192.png, Icon-512.png, and maskable variants)

### macOS
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

### Windows
- `windows/runner/resources/` (Windows icon)

### Linux
- Icon configuration in app metadata

## Icon Design Tips

1. **Simplicity**: Keep your icon simple and recognizable at small sizes
2. **Color Contrast**: Ensure good contrast for visibility
3. **Padding**: Leave at least 10% margin around the edges
4. **Shape**: Rounded corners work well for modern app icons
5. **Testing**: Test your icon at various sizes to ensure it looks good

## Current Status

✅ **flutter_launcher_icons** dependency added to `pubspec.yaml`
✅ Configuration for all platforms set up
✅ `assets/icon/` directory created
✅ Ready for icon files

## Next Steps

1. Create your custom icon (1024x1024 PNG)
2. Save it as `assets/icon/icon.png`
3. Run: `flutter pub run flutter_launcher_icons`
4. Run: `flutter clean && flutter run`
5. Check all platforms for proper icon display

## Troubleshooting

### Icons not showing after generation
- Run `flutter clean` before rebuilding
- Check that icon file is not corrupted
- Verify file is in correct location: `assets/icon/icon.png`

### iOS icon still shows old image
- Clear iOS build folder: `rm -rf ios/Pods ios/Podfile.lock`
- Rebuild: `flutter clean && flutter run`

### Android icon issues
- Check minimum SDK is 21: `android/app/build.gradle.kts`
- Verify icon dimensions are square

## Dependencies Added

- **flutter_launcher_icons**: ^0.13.1 (dev dependency)

This package is a dev dependency, so it won't increase your app bundle size.
