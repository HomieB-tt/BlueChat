# BlueChat

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.38.4)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)
- GitHub (for source control)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
bluechat/
├── android/            # Android-specific configuration and native code
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/          # Core utilities and configurations
│   │   ├── app_export.dart
│   │   ├── env.dart
│   │   └── supabase_client.dart
│   ├── presentation/   # UI screens and widgets
│   │   ├── bluetooth_onboarding/    # Bluetooth setup screens
│   │   │   ├── bluetooth_onboarding.dart
│   │   │   └── widgets/
│   │   │       ├── benefit_card_widget.dart
│   │   │       └── onboarding_page_widget.dart
│   │   ├── chat_conversation/       # Chat screen
│   │   │   ├── chat_conversation.dart
│   │   │   └── widgets/
│   │   │       ├── connection_status_banner_widget.dart
│   │   │       ├── message_bubble_widget.dart
│   │   │       └── message_input_widget.dart
│   │   ├── device_discovery/         # Device scanning screen
│   │   │   ├── device_discovery.dart
│   │   │   └── widgets/
│   │   │       ├── device_card_widget.dart
│   │   │       ├── empty_state_widget.dart
│   │   │       └── scanning_animation_widget.dart
│   │   ├── home_screen/             # Main home screen
│   │   │   └── home_screen.dart
│   │   ├── messages_view/            # Messages list screen
│   │   │   ├── messages_view.dart
│   │   │   └── widgets/
│   │   │       └── conversation_card_widget.dart
│   │   ├── permission_request/      # Permission screens
│   │   │   ├── permission_request.dart
│   │   │   └── widgets/
│   │   │       ├── permission_card_widget.dart
│   │   │       └── permission_explanation_widget.dart
│   │   ├── settings/                # Settings screen
│   │   │   ├── settings.dart
│   │   │   └── widgets/
│   │   │       ├── action_button_widget.dart
│   │   │       ├── profile_header_widget.dart
│   │   │       └── settings_section_widget.dart
│   │   └── splash_screen/           # Splash screen
│   │       └── splash_screen.dart
│   ├── routes/         # Application routing
│   │   └── app_routes.dart
│   ├── services/       # Business logic services
│   │   ├── bluetooth_service.dart    # Bluetooth LE operations
│   │   ├── database_service.dart
│   │   ├── realtime_service.dart
│   │   ├── storage_service.dart
│   │   └── user_service.dart
│   ├── theme/          # Theme configuration
│   │   └── app_theme.dart
│   ├── widgets/        # Reusable UI components
│   │   ├── custom_bottom_bar.dart
│   │   ├── custom_error_widget.dart
│   │   ├── custom_icon_widget.dart
│   │   └── custom_image_widget.dart
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, etc.)
│   └── images/
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## 🙏 Acknowledgments
- The Supabase team
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with 💙 from Uganda!
