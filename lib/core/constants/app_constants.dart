/// Application-wide constants and configuration values
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'StudyBuddy';
  static const String appTagline = 'Study smarter, not harder';
  static const String appVersion = '1.0.0';

  // API
  static const String apiBaseUrl = 'https://api.studybuddy.app/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String userBoxKey = 'user_box';
  static const String settingsBoxKey = 'settings_box';
  static const String cacheBoxKey = 'cache_box';
  static const String secureTokenKey = 'auth_token';
  static const String secureRefreshTokenKey = 'refresh_token';

  // Database
  static const String databaseName = 'studybuddy.db';
  static const int databaseVersion = 1;

  // Spaced Repetition Intervals (in days)
  static const List<int> leitnerBoxIntervals = [1, 3, 7, 14, 28];
  static const int maxLeitnerBox = 5;

  // Pomodoro Defaults
  static const Duration defaultPomodoroWork = Duration(minutes: 25);
  static const Duration defaultPomodoroShortBreak = Duration(minutes: 5);
  static const Duration defaultPomodoroLongBreak = Duration(minutes: 15);
  static const int pomodoroSessionsBeforeLongBreak = 4;

  // Gamification
  static const int pointsPerTask = 10;
  static const int pointsPerFocusMinute = 1;
  static const int pointsPerQuizCorrect = 5;
  static const int pointsPerDailyStreak = 50;
  static const int coinsPerFocusSession = 10;
  static const int focusMinutesPerTree = 30;

  // Tree Planting
  static const int realTreePlantingThreshold = 100; // coins needed
  static const Duration minFocusSessionForTree = Duration(minutes: 10);
  static const Duration maxFocusSessionForTree = Duration(minutes: 120);

  // UI
  static const double defaultBorderRadius = 20.0;
  static const double glassOpacity = 0.8;
  static const double glassBlurSigma = 20.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxTaskTitleLength = 200;
  static const int maxNoteLength = 50000;

  // Session
  static const Duration sessionTimeout = Duration(days: 30);
  static const Duration refreshTokenExpiry = Duration(days: 90);

  // Cache
  static const Duration imageCacheDuration = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB

  // Notifications
  static const String notificationChannelId = 'studybuddy_main';
  static const String notificationChannelName = 'StudyBuddy Notifications';
  static const String notificationChannelDescription = 'Study reminders and updates';

  // Sync
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration backgroundSyncInterval = Duration(hours: 1);

  // Feature Flags
  static const bool enableAIFeatures = true;
  static const bool enableCollaboration = true;
  static const bool enableVoiceFeatures = true;
  static const bool enableARFeatures = false; // Future feature

  // External Links
  static const String privacyPolicyUrl = 'https://studybuddy.app/privacy';
  static const String termsOfServiceUrl = 'https://studybuddy.app/terms';
  static const String supportEmail = 'support@studybuddy.app';
  static const String websiteUrl = 'https://studybuddy.app';
  static const String twitterUrl = 'https://twitter.com/StudyBuddyApp';
  static const String discordUrl = 'https://discord.gg/studybuddy';

  // Environmental Partners
  static const String treesForTheFutureUrl = 'https://trees.org';
  static const String oneTreePlantedUrl = 'https://onetreeplanted.org';
  static const String edenReforestationUrl = 'https://edenprojects.org';

  // Accessibility
  static const double minFontScale = 1.0;
  static const double maxFontScale = 2.0;
  static const double minContrastRatio = 4.5; // WCAG AA standard
  static const double minTapTargetSize = 44.0; // iOS HIG minimum
}

/// Study technique types supported by the app
enum StudyTechnique {
  pomodoro,
  flowtime,
  spacedRepetition,
  retrievalPractice,
  interleaving,
  pq4r,
  sq3r,
  feynman,
  mindMapping,
  memoryPalace,
  dualCoding,
  activeRecall,
}

/// Priority levels for tasks and assignments
enum Priority {
  low,
  medium,
  high,
  urgent,
}

/// Badge rarity levels
enum BadgeRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Session types for focus timers
enum SessionType {
  pomodoro,
  flowtime,
  custom,
}

/// Tree species available for planting
enum TreeSpecies {
  oak,
  pine,
  maple,
  cherry,
  birch,
  willow,
  cedar,
  redwood,
  bamboo,
  palm,
}

/// User subscription tiers
enum SubscriptionTier {
  free,
  premium,
  enterprise,
}

/// Theme modes
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Accessibility modes
enum AccessibilityMode {
  standard,
  highContrast,
  dyslexiaFriendly,
  largeText,
}
