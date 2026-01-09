
# LNQ Mobile App

LNQ is a cross-platform mobile application built with Flutter. It provides order management features, including order creation, filtering, and detail views. The app supports Android, iOS, web, Windows, macOS, and Linux.

## Features

- View, create, and manage orders
- Filter orders by created date or pickup date
- Sort orders by pickup date and hide past orders
- View detailed order information and items
- Localization support (English, Indonesian)
- Responsive UI for multiple platforms

## Project Structure

```
lib/
	main.dart                # App entry point
	models/                  # Data models (Order, Product, etc.)
	providers/               # State management providers
	screens/                 # UI screens (orders, order detail, etc.)
	services/                # API and business logic
	theme/                   # App theming
	utils/                   # Utility functions
	widgets/                 # Reusable widgets
l10n/                      # Localization files
android/, ios/, web/, ...  # Platform-specific code
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Android Studio/Xcode for mobile development
- Chrome or compatible browser for web

### Installation
1. Clone the repository:
	 ```sh
	 git clone <repo-url>
	 cd mobile
	 ```
2. Install dependencies:
	 ```sh
	 flutter pub get
	 ```
3. Run the app:
	 - Android/iOS:
		 ```sh
		 flutter run -d <device_id>
		 ```
	 - Web:
		 ```sh
		 flutter run -d chrome
		 ```
	 - Windows/macOS/Linux:
		 ```sh
		 flutter run -d windows|macos|linux
		 ```

## Localization
- Edit ARB files in `lib/l10n/` for translations.
- Use `flutter gen-l10n` to regenerate localization code if needed.

## Environment Configuration
- API endpoints and settings are managed in `SettingsProvider` and `api_service.dart`.
- Update `baseUrl` in the app or via provider as needed.

## Testing
- Run widget and unit tests:
	```sh
	flutter test
	```

## Code Style
- Follows Dart/Flutter best practices.
- See `analysis_options.yaml` for lint rules.

## Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Push to your branch
5. Open a pull request

## License
This project is licensed under the MIT License.

## Contact
For questions or support, please contact the project maintainer.
