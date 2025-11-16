import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock Firebase setup for tests
/// This prevents Firebase initialization errors during testing
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock MethodChannel for Firebase Core
  const MethodChannel('plugins.flutter.io/firebase_core')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
          },
          'pluginConstants': {},
        }
      ];
    }
    if (methodCall.method == 'Firebase#initializeApp') {
      return {
        'name': methodCall.arguments['appName'],
        'options': methodCall.arguments['options'],
        'pluginConstants': {},
      };
    }
    return null;
  });

  // Mock other Firebase services as needed
  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return null;
  });

  const MethodChannel('plugins.flutter.io/cloud_firestore')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return null;
  });
}
