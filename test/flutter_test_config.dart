import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_mock_setup.dart';

/// This file is automatically discovered and run by `flutter test`
/// It sets up the test environment before any tests run
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Initialize Flutter test bindings
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Firebase mocks to prevent initialization errors
  setupFirebaseMocks();

  // Suppress debug prints during tests for cleaner output
  debugPrint = (String? message, {int? wrapWidth}) {};

  // Run all tests
  return testMain();
}
