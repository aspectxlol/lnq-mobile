
# LNQ Mobile App

**LNQ** is a comprehensive cross-platform mobile application built with **Flutter**. It provides robust order management features, including order creation, real-time filtering, detailed order views, and order editing capabilities. The application is fully responsive and supports Android, iOS, web, Windows, macOS, and Linux platforms.

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage Guide](#usage-guide)
- [Architecture](#architecture)
- [Localization](#localization)
- [Testing](#testing)
- [Code Quality](#code-quality)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

### Core Functionality
- **Order Management**: Create, view, edit, and delete orders with comprehensive order details
- **Product Management**: Browse available products, manage custom items, and track pricing
- **Order Filtering**: Filter orders by creation date or pickup date with intuitive date range selectors
- **Order Sorting**: Sort orders by pickup date and toggle visibility of past orders
- **Order Details**: View complete order information including items, pricing, and order status
- **Order Editing**: Edit existing orders with real-time validation and error handling
- **Custom Items**: Add custom products to orders with custom pricing and descriptions

### User Experience
- **Responsive UI**: Glassmorphism-style design with smooth animations and modern aesthetics
- **Real-time Validation**: Form validation with helpful error messages
- **Multi-language Support**: Full localization support for English and Indonesian
- **Cross-Platform Compatibility**: Seamless experience across mobile, web, and desktop platforms
- **Accessibility**: Proper semantic structure and accessibility considerations
- **Performance**: Optimized rendering and efficient state management

### Technical Features
- **State Management**: Provider-based reactive state management
- **API Integration**: RESTful API integration with proper error handling
- **Localization**: ARB-based internationalization (i18n) system
- **Theming**: Comprehensive theming system with support for multiple color schemes
- **Data Persistence**: Local data caching and management

## Project Structure

```
lib/
├── main.dart                      # Application entry point and root configuration
├── models/                        # Data models
│   ├── order.dart                # Order model with nested item types
│   ├── product.dart              # Product model
│   ├── order_item_data.dart      # Order item wrapper for form management
│   └── create_order_request.dart # API request models for order creation
├── components/                    # Reusable UI components
│   ├── date_range_filter.dart    # Date filtering widget
│   ├── edit_order_screen.dart    # Order editing functionality
│   ├── image_picker_widget.dart  # Image selection component
│   ├── info_row.dart             # Information display row
│   ├── order_card.dart           # Order summary card
│   ├── order_item_row.dart       # Individual order item display
│   ├── price_input.dart          # Formatted price input field
│   └── ...                       # Additional UI components
├── constants/                     # Application constants
├── l10n/                         # Localization strings
│   └── strings.dart             # All localized strings (English, Indonesian)
├── mixins/                       # Dart mixins for shared behavior
├── models/                       # Data models (see above)
├── providers/                    # State management providers
│   ├── settings_provider.dart   # App settings and configuration
│   └── ...                      # Other state providers
├── screens/                      # Complete screen implementations
│   ├── orders_screen.dart       # Orders list and management
│   ├── order_detail_screen.dart # Order details view
│   └── ...                      # Additional screens
├── services/                     # Business logic and API integration
│   ├── api_service.dart         # REST API client
│   └── ...                      # Additional services
├── theme/                        # Theming and styling
│   ├── app_theme.dart           # Main theme definitions
│   ├── app_colors.dart          # Color palette
│   └── ...                      # Additional theme files
├── utils/                        # Utility functions
│   ├── currency_utils.dart      # Currency formatting
│   ├── data_loader_extension.dart # Data loading utilities
│   └── ...                      # Additional utilities
└── widgets/                      # Custom reusable widgets

android/                          # Android-specific code (Gradle, Kotlin)
├── app/src/main/
├── build.gradle.kts
└── settings.gradle.kts

ios/                             # iOS-specific code (Swift, Xcode)
├── Runner/
├── Runner.xcodeproj
└── Podfile

web/                             # Web build configuration
├── index.html
├── manifest.json
└── icons/

windows/, macos/, linux/         # Desktop platform configurations

pubspec.yaml                     # Flutter project configuration and dependencies
pubspec.lock                     # Locked dependency versions
analysis_options.yaml            # Dart analyzer configuration
devtools_options.yaml            # DevTools configuration
swagger.json                     # API specification
```

## Technology Stack

### Frontend Framework
- **Flutter**: Latest stable version for cross-platform development
- **Dart**: Programming language for Flutter

### State Management
- **Provider**: Reactive state management pattern for clean architecture

### UI/UX
- **Material Design**: Following Material 3 design principles
- **Custom Theming**: Comprehensive theme system with color management
- **Animations**: Smooth transitions and visual feedback

### Localization
- **Custom Localization**: Centralized strings.dart file with AppStrings class
- **Supported Languages**: English, Indonesian (easily extensible)

### API Integration
- **REST API**: RESTful endpoints for backend communication
- **HTTP Client**: Dart's http package for network requests
- **Error Handling**: Comprehensive error handling and user feedback

### Development Tools
- **Flutter Analysis**: Dart analyzer for code quality
- **DevTools**: Flutter DevTools for debugging and profiling
- **Testing Framework**: Widget and unit testing support

### Platform-Specific
- **Android**: Gradle build system, Kotlin support
- **iOS**: Xcode, Swift support
- **Web**: HTML5, JavaScript compilation
- **Desktop**: Native Windows, macOS, Linux support

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
  - [Installation Guide](https://flutter.dev/docs/get-started/install)
  - Includes Dart SDK automatically
  
- **Development Tools**:
  - Android Studio with Android SDK (for Android development)
  - Xcode (for iOS development on macOS)
  - Visual Studio or Visual Studio Code with C++ build tools (for Windows desktop)
  
- **Version Control**:
  - Git for cloning and managing the repository
  
- **Editor**:
  - Visual Studio Code with Flutter extension (recommended)
  - Android Studio
  - Or your preferred IDE with Flutter/Dart plugin

### Installation

Follow these steps to set up the development environment:

1. **Clone the repository**:
   ```sh
   git clone <repository-url>
   cd lnq-mobile
   ```

2. **Verify Flutter installation**:
   ```sh
   flutter --version
   flutter doctor
   ```
   Address any issues reported by `flutter doctor`.

3. **Install project dependencies**:
   ```sh
   flutter pub get
   ```

4. **Run the application**:

   **On Android device/emulator**:
   ```sh
   flutter run
   # Or specify a device
   flutter run -d <device_id>
   ```

   **On iOS device/simulator** (macOS only):
   ```sh
   flutter run -d ios
   # Or specify a simulator
   flutter run -d "<simulator_name>"
   ```

   **On Web**:
   ```sh
   flutter run -d chrome
   # Or other browsers: edge, firefox, safari
   flutter run -d edge
   ```

   **On Windows**:
   ```sh
   flutter run -d windows
   ```

   **On macOS**:
   ```sh
   flutter run -d macos
   ```

   **On Linux**:
   ```sh
   flutter run -d linux
   ```

6. **Build for Release**:
   ```sh
   # Android APK
   flutter build apk --release
   
   # Android App Bundle
   flutter build appbundle --release
   
   # iOS
   flutter build ios --release
   
   # Web
   flutter build web --release
   
   # Desktop platforms
   flutter build windows --release
   flutter build macos --release
   flutter build linux --release
   ```

## Configuration

### API Configuration

The API integration is managed through the `ApiService` class located in `lib/services/api_service.dart`. 

**To configure API endpoints**:

1. Update the base URL in `api_service.dart`:
   ```dart
   static const String baseUrl = 'https://your-api-url.com/api';
   ```

2. Or configure dynamically through `SettingsProvider`:
   ```dart
   final settingsProvider = Provider((ref) => SettingsProvider());
   ```

### Build Configuration

**Android** (`android/app/build.gradle.kts`):
- Minimum SDK: 21
- Target SDK: Latest stable
- Application ID: `com.aspectxlol.lnq`

**iOS** (`ios/Podfile`):
- Minimum deployment target: iOS 12.0
- Pod dependencies are managed automatically

**Web** (`web/index.html`):
- Base href configuration for routing
- Progressive Web App (PWA) settings

### App Name and Icon

#### Changing App Name

**Android** (`android/app/build.gradle.kts`):
```kotlin
defaultConfig {
    applicationId = "com.aspectxlol.lnq"  // Package name
    ...
}
```

Also update `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="@string/app_name"  <!-- App name appears here -->
    ...
```

Update the string in `android/app/src/main/res/values/strings.xml`:
```xml
<resources>
    <string name="app_name">LnQ</string>
</resources>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleName</key>
<string>LnQ</string>

<key>CFBundleDisplayName</key>
<string>LnQ</string>
```

**Web** (`web/index.html`):
```html
<title>LnQ</title>
```

**macOS** (`macos/Runner/Info.plist`):
```xml
<key>CFBundleName</key>
<string>LnQ</string>
```

**Windows** (`windows/runner/main.cpp`):
```cpp
CreateWindow(L"LnQ", ...)
```

Or use `windows/runner/windows/runner.rc`:
```
IDI_APP_ICON            ICON                    "..\\..\\..\\windows\\runner\\resources\\app_icon.ico"
```

#### Changing App Icon

**Android**:

1. Prepare icon sizes:
   - `ldpi`: 36x36
   - `mdpi`: 48x48
   - `hdpi`: 72x72
   - `xhdpi`: 96x96
   - `xxhdpi`: 144x144
   - `xxxhdpi`: 192x192

2. Place icons in respective folders:
   ```
   android/app/src/main/res/
   ├── mipmap-ldpi/ic_launcher.png
   ├── mipmap-mdpi/ic_launcher.png
   ├── mipmap-hdpi/ic_launcher.png
   ├── mipmap-xhdpi/ic_launcher.png
   ├── mipmap-xxhdpi/ic_launcher.png
   └── mipmap-xxxhdpi/ic_launcher.png
   ```

**iOS**:

1. Prepare icon size: 1024x1024 PNG

2. Replace in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Navigate to `Runner > Assets.xcassets > AppIcon`
   - Drag and drop your icon (Xcode will auto-scale)

3. Or replace files directly in:
   ```
   ios/Runner/Assets.xcassets/AppIcon.appiconset/
   ```

**Web**:

1. Prepare icons:
   - `web/icons/Icon-192.png` (192x192)
   - `web/icons/Icon-512.png` (512x512)
   - `web/favicon.png` (any size)

2. Update `web/manifest.json`:
   ```json
   {
     "name": "LnQ",
     "short_name": "LnQ",
     "icons": [
       {
         "src": "icons/Icon-192.png",
         "sizes": "192x192",
         "type": "image/png"
       },
       {
         "src": "icons/Icon-512.png",
         "sizes": "512x512",
         "type": "image/png"
       }
     ]
   }
   ```

**macOS**:

1. Prepare icon: 1024x1024 PNG

2. Open `macos/Runner.xcworkspace` in Xcode
3. Navigate to `Runner > Assets.xcassets > AppIcon`
4. Drag and drop your icon

**Windows**:

1. Prepare icon: `windows/runner/resources/app_icon.ico`

2. Convert PNG to ICO format using online converter or ImageMagick:
   ```sh
   convert app_icon.png -define icon:auto-resize=256,128,96,64,48,32,16 app_icon.ico
   ```

3. Replace `windows/runner/resources/app_icon.ico`

**Linux**:

1. Prepare icons in various sizes and place in:
   ```
   linux/
   └── resources/
       └── <app-id>/
           └── (your app icons)
   ```

**Easy Method - Using flutter_launcher_icons Package**:

1. Add to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.0
   ```

2. Create `flutter_launcher_icons.yaml` in project root:
   ```yaml
   flutter_launcher_icons:
     android: "ic_launcher"
     ios: true
     windows: false
     macos: false
     image_path: "assets/icon/icon.png"  # Path to your 1024x1024 PNG icon
     image_path_android: "assets/icon/icon.png"
     image_path_ios: "assets/icon/icon.png"
     ```

3. Run:
   ```sh
   flutter pub get
   flutter pub run flutter_launcher_icons:main
   ```

### Environment Variables

Create a `.env` file in the project root for environment-specific configuration:
```
API_URL=https://your-api-url.com/api
API_TIMEOUT=30
LOG_LEVEL=info
```

Load environment variables in `main.dart` if needed.

## Usage Guide

### Creating an Order

1. Navigate to the Orders screen
2. Tap the "Add Order" button
3. Enter customer name and notes
4. Add items:
   - **Product Items**: Select from product list, set quantity and price override (optional)
   - **Custom Items**: Enter custom product name and price
5. Review the order total
6. Tap "Save" to create the order

### Editing an Order

1. From the Orders list, tap the edit icon on an order card
2. Modify customer information, notes, or order items
3. Add or remove items as needed
4. Tap "Save" to update the order

### Filtering Orders

1. Use the date range filter at the top of the Orders screen
2. Select "Created Date" or "Pickup Date" filter type
3. Choose start and end dates
4. Toggle "Hide Past Orders" to exclude completed orders

### Viewing Order Details

1. Tap on an order card to view full details
2. View all items in the order with pricing information
3. See order status, dates, and customer information

## Architecture

### Design Patterns

**Provider Pattern**: Uses the Provider package for state management
- Reactive data flow
- Separation of concerns
- Easy testing and debugging

**Repository Pattern**: Abstracts data access logic
- API service acts as data source
- Models define data structure
- Services handle business logic

**Widget Composition**: Reusable component-based UI
- Small, focused widgets
- Clear separation of concerns
- Easy to maintain and test

### Data Flow

```
UI (Screens & Components)
     ↓
State Management (Provider)
     ↓
Services (API, Business Logic)
     ↓
Models (Data structures)
     ↓
External APIs / Local Storage
```

### Project Layers

1. **Presentation Layer**
   - Screens, Components, Widgets
   - User interface and user interactions
   - View models and state management

2. **Domain Layer**
   - Models and data structures
   - Business logic and validation
   - Interfaces for repositories

3. **Data Layer**
   - API service and HTTP client
   - Local data storage
   - Network communication

## Localization

The app uses a custom localization system with a centralized `strings.dart` file for managing all translated strings.

### Supported Languages
- **English** - Default language
- **Indonesian** - Secondary language

### Localization File Structure

All strings are managed in `lib/l10n/strings.dart` using the `AppStrings` class.

**File Location**: `lib/l10n/strings.dart`

Example structure:
```dart
class AppStrings {
  static const String orderTitle = 'Orders';
  static const String customerName = 'Customer Name';
  
  // Language-specific translations
  static Map<String, Map<String, String>> translations = {
    'en': {
      'orderTitle': 'Orders',
      'customerName': 'Customer Name',
      // ... more English strings
    },
    'id': {
      'orderTitle': 'Pesanan',
      'customerName': 'Nama Pelanggan',
      // ... more Indonesian strings
    },
  };
}
```

### Using Localized Strings

In your code:
```dart
// Static string access
AppStrings.orderTitle

// Context-based translation (switching language at runtime)
AppStrings.tr(context, 'orderTitle')

// With context watching (reactive updates when language changes)
AppStrings.trWatch(context, 'orderTitle')
```

### Adding New Strings

1. Open `lib/l10n/strings.dart`
2. Add the string key to the `AppStrings` class:
   ```dart
   static const String newFeature = 'newFeature';
   ```

3. Add translations for all supported languages in the translations map:
   ```dart
   static Map<String, Map<String, String>> translations = {
     'en': {
       'newFeature': 'New Feature',
       // ...
     },
     'id': {
       'newFeature': 'Fitur Baru',
       // ...
     },
   };
   ```

### Adding a New Language

1. Open `lib/l10n/strings.dart`
2. Add a new language code entry to the translations map:
   ```dart
   static Map<String, Map<String, String>> translations = {
     'en': { /* English translations */ },
     'id': { /* Indonesian translations */ },
     'es': { /* Spanish translations */ }, // New language
   };
   ```

3. Ensure all translation keys exist in the new language
4. Update language selection logic in your app settings

## Testing

### Running Tests

**Run all tests**:
```sh
flutter test
```

**Run specific test file**:
```sh
flutter test test/models/order_test.dart
```

**Run tests with coverage**:
```sh
flutter test --coverage
```

### Test Structure

Tests are organized in the `test/` directory mirroring the `lib/` structure:

```
test/
├── models/          # Model unit tests
├── services/        # Service and API tests
├── screens/         # Widget and screen tests
├── utils/           # Utility function tests
└── widgets/         # Widget component tests
```

### Writing Tests

**Unit Test Example**:
```dart
test('Order total calculation', () {
  final order = Order(
    id: 1,
    customerName: 'John Doe',
    items: [/* ... */],
  );
  expect(order.total, equals(expectedTotal));
});
```

**Widget Test Example**:
```dart
testWidgets('Order card displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.byType(OrderCard), findsWidgets());
});
```

### Test Coverage

Generate coverage reports:
```sh
flutter test --coverage
# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

## Code Quality

### Dart Analysis

Run the Dart analyzer to check code quality:
```sh
flutter analyze
```

**Fix common issues automatically**:
```sh
dart fix --apply
```

### Lint Rules

Configured in `analysis_options.yaml`. Key rules:
- Code style consistency
- Null safety compliance
- Performance best practices
- Widget best practices
- Accessibility considerations

### Formatting

Auto-format code:
```sh
dart format lib/
```

**Check formatting**:
```sh
dart format --set-exit-if-changed lib/
```

### Naming Conventions

- **Classes**: PascalCase (e.g., `OrderScreen`)
- **Variables/Functions**: camelCase (e.g., `orderTotal`)
- **Constants**: camelCase with leading underscore if private (e.g., `_defaultTimeout`)
- **Files**: snake_case (e.g., `order_screen.dart`)

### Best Practices

1. **Null Safety**: Leverage Dart's null safety features
2. **Type Annotations**: Always use explicit type annotations
3. **Documentation**: Document public APIs with doc comments
4. **Error Handling**: Use try-catch for error-prone operations
5. **State Management**: Use Provider for reactive state
6. **Widget Size**: Keep widgets small and focused
7. **BuildContext**: Capture context before async operations

### Common Issues and Solutions

**BuildContext across async gaps**:
```dart
// ❌ Don't do this
await someAsyncOperation();
ScaffoldMessenger.of(context).showSnackBar(...); // Error

// ✅ Do this instead
final messenger = ScaffoldMessenger.of(context);
await someAsyncOperation();
messenger.showSnackBar(...); // Safe
```

## Contributing

We welcome contributions! Here's how to contribute:

### Development Workflow

1. **Fork the repository** on GitHub

2. **Create a feature branch**:
   ```sh
   git checkout -b feature/your-feature-name
   # or for bug fixes
   git checkout -b bugfix/your-bug-fix
   ```

3. **Make your changes**:
   - Follow the project's code style and conventions
   - Write clear, descriptive commit messages
   - Add tests for new features
   - Ensure code passes analysis

4. **Test your changes**:
   ```sh
   flutter test
   flutter analyze
   dart format lib/
   ```

5. **Commit your changes**:
   ```sh
   git add .
   git commit -m "Brief description of changes"
   ```

6. **Push to your fork**:
   ```sh
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**:
   - Provide a clear description of your changes
   - Reference any related issues
   - Include screenshots for UI changes

### Commit Message Guidelines

- Use imperative mood ("Add feature" not "Added feature")
- Start with a capital letter
- Keep subject line under 50 characters
- Reference issues with "Fixes #123" or "Related to #456"

Example:
```
Add order filtering by date range

- Implement DateRangeFilter widget
- Add filter state management
- Update OrdersScreen to use new filter
- Add unit tests for filtering logic

Fixes #789
```

### Code Review Process

1. Maintainers will review your PR
2. Address any requested changes
3. Once approved, your PR will be merged
4. Your contribution will be credited

### Reporting Issues

Found a bug? Please report it:
1. Check if the issue already exists
2. Include a clear description
3. Provide steps to reproduce
4. Add relevant screenshots or logs
5. Specify your environment (Flutter version, device, OS)

## Troubleshooting

### Common Issues

**"Flutter command not found"**:
```sh
# Add Flutter to your PATH
export PATH="$PATH:`flutter/bin`"
```

**"Get dependencies" fails**:
```sh
flutter clean
flutter pub get
```

**Build errors on iOS**:
```sh
cd ios
pod repo update
pod install
cd ..
flutter clean
flutter run
```

**Hot reload not working**:
- Save the file again
- Try `r` in the console to hot reload manually
- Use `R` for hot restart if hot reload fails

**Localization not updating**:
```sh
flutter clean
flutter pub get
# Rebuild the app to reload strings.dart
flutter run
```

### Performance Optimization

For production builds:
```sh
# Measure performance
flutter run --profile

# Build optimized release
flutter build <platform> --release --split-per-abi
```

### Debugging

**Enable verbose logging**:
```sh
flutter run -v
```

**Use Flutter DevTools**:
```sh
flutter pub global activate devtools
devtools
# Or open in Android Studio: View > Open DevTools
```

**Debug network requests**:
```dart
// In api_service.dart, enable request logging
http.Client()... // Consider using dio package for better debugging
```

## File Guidelines

### Important Files to Know

- **pubspec.yaml**: Project configuration and dependencies
- **analysis_options.yaml**: Linter rules and analyzer settings
- **main.dart**: Application bootstrap and root widget
- **lib/services/api_service.dart**: API client and HTTP configuration
- **lib/models/**: Data models and API response structures
- **lib/screens/**: Full-page UI components
- **lib/components/**: Reusable UI widgets
- **lib/l10n/strings.dart**: Centralized localization strings with AppStrings class

### Modifying Dependencies

**Add a package**:
```sh
flutter pub add package_name
```

**Update packages**:
```sh
flutter pub upgrade
```

**Update specific package**:
```sh
flutter pub upgrade package_name
```

**Remove a package**:
```sh
flutter pub remove package_name
```

## Performance Tips

1. **Use const constructors** for widgets that don't change
2. **Limit rebuilds** with Provider.select() or repaint boundaries
3. **Cache images** using cached_network_image or similar
4. **Lazy load** list items with ListView.builder
5. **Profile regularly** using Flutter DevTools
6. **Minimize dependencies** in the main thread
7. **Use async/await** properly to avoid blocking the UI

## Security Considerations

1. **API Keys**: Never commit API keys; use environment variables
2. **User Data**: Implement proper data encryption for sensitive info
3. **Input Validation**: Always validate user input before sending to server
4. **HTTPS**: Use HTTPS for all API communications
5. **Token Storage**: Store authentication tokens securely using flutter_secure_storage

## License

This project is licensed under the **MIT License** - see the LICENSE file for details.

The MIT License permits:
- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use

With the condition:
- ⚠️ License and copyright notice must be included

## Contact & Support

For questions, issues, or feature requests:

- **GitHub Issues**: [Report issues here](https://github.com/yourrepo/issues)
- **Email**: support@example.com
- **Documentation**: See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

### Project Maintainer
- **Name**: [Your Name]
- **Email**: [your.email@example.com]
- **GitHub**: [@yourprofile](https://github.com/yourprofile)

### Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://material.io/design)
- [Flutter Community](https://flutter.dev/community)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

---

**Happy coding!** 🚀
