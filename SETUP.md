# StudyBuddy Setup Guide

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher)
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **Xcode** (depending on your target platform)
- **Git**
- **VS Code** or **Android Studio** (recommended IDEs)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/studybuddy.git
cd studybuddy
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the project root:

```env
# Firebase Configuration (Optional - for cloud sync)
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id

# OpenAI API (Optional - for AI features)
OPENAI_API_KEY=your_openai_key

# Anthropic API (Optional - for Claude AI)
ANTHROPIC_API_KEY=your_anthropic_key

# Stripe (Optional - for premium features)
STRIPE_PUBLISHABLE_KEY=your_stripe_key
STRIPE_SECRET_KEY=your_stripe_secret
```

**Note:** The app will work without these keys, but AI and cloud sync features will be disabled.

### 4. Run Code Generation

```bash
# Generate code for Drift, Freezed, etc.
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
# Run on connected device or emulator
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter devices
flutter run -d <device-id>
```

## 🔧 Development Setup

### VS Code Extensions

Install these recommended extensions:

- **Flutter** - Official Flutter extension
- **Dart** - Official Dart extension
- **Awesome Flutter Snippets** - Code snippets
- **Flutter Widget Snippets** - Widget snippets
- **Pubspec Assist** - Package management

### Android Studio Setup

1. Install **Flutter plugin**
2. Install **Dart plugin**
3. Configure Android SDK (API 26+)
4. Create an Android emulator

### iOS Setup (macOS only)

```bash
# Install CocoaPods
sudo gem install cocoapods

# Install iOS dependencies
cd ios
pod install
cd ..
```

## 📦 Required Dependencies

The following packages are already configured in `pubspec.yaml`:

### Core Dependencies
- `flutter` - Flutter framework
- `drift` - Local database (SQLite)
- `http` - HTTP requests for AI API

### UI Components
- `flutter_svg` - SVG support (if needed)
- `cached_network_image` - Image caching (if needed)

### State Management
- `riverpod` or `provider` (if implemented)

### Firebase (Optional)
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Cloud database

## 🗄️ Database Setup

The app uses **Drift** for local database management.

### Initialize Database

The database is automatically initialized on first launch. No manual setup required.

### Database Location

- **Android:** `/data/data/com.studybuddy.app/databases/`
- **iOS:** `Application Support/databases/`

### Reset Database (Development)

```bash
# Uninstall and reinstall the app
flutter clean
flutter pub get
flutter run
```

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
lcov --summary coverage/lcov.info
```

### Run Specific Test File

```bash
flutter test test/features/flashcards/flashcard_scheduler_test.dart
```

### Run Integration Tests

```bash
flutter test integration_test/
```

## 📱 Platform-Specific Setup

### Android

#### Minimum Configuration

- **minSdkVersion:** 21
- **targetSdkVersion:** 33
- **compileSdkVersion:** 33

#### Permissions

The following permissions are configured in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS

#### Minimum Configuration

- **iOS Deployment Target:** 13.0

#### Permissions

Add to `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for scanning documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access for saving images</string>
```

## 🎨 Design Resources

### Assets

Place assets in the following directories:

```
assets/
├── images/
│   ├── icons/
│   └── illustrations/
├── fonts/
└── animations/
```

### Generate App Icons

```bash
flutter pub run flutter_launcher_icons:main
```

## 🔐 API Key Configuration

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android/iOS apps
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
5. Place them in the correct directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### OpenAI API

1. Sign up at [OpenAI Platform](https://platform.openai.com/)
2. Create an API key
3. Add to `.env` file

### Anthropic API

1. Sign up at [Anthropic Console](https://console.anthropic.com/)
2. Create an API key
3. Add to `.env` file

## 🐛 Troubleshooting

### Common Issues

#### 1. "Flutter SDK not found"

```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

#### 2. "Build failed" on Android

```bash
# Clean and rebuild
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

#### 3. "Pod install failed" on iOS

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

#### 4. "Code generation failed"

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Enable Debug Logging

```dart
// In main.dart
void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(MyApp());
}
```

## 📚 Additional Resources

### Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Firebase Flutter Setup](https://firebase.flutter.dev/)

### Tutorials

- [Flutter Codelabs](https://flutter.dev/codelabs)
- [Drift Getting Started](https://drift.simonbinder.eu/docs/getting-started/)

### Community

- [Flutter Discord](https://discord.gg/flutter)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

## 🚢 Deployment

### Android Release Build

```bash
# Generate release APK
flutter build apk --release

# Generate App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS Release Build

```bash
# Build for release
flutter build ios --release

# Then archive in Xcode
open ios/Runner.xcworkspace
```

### Web Release Build

```bash
flutter build web --release
```

## ✅ Verification Checklist

Before pushing code, ensure:

- [ ] All tests pass: `flutter test`
- [ ] No analyzer issues: `flutter analyze`
- [ ] Code is formatted: `flutter format .`
- [ ] No debug prints in production code
- [ ] Environment variables are not committed
- [ ] Documentation is updated

## 📞 Support

If you encounter issues during setup:

1. Check the [GitHub Issues](https://github.com/yourusername/studybuddy/issues)
2. Join our [Discord server](https://discord.gg/studybuddy)
3. Email: dev-support@studybuddy.app

---

**Happy Coding! 🚀**
