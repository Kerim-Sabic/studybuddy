import 'package:equatable/equatable.dart';

/// User's gamification profile
class UserProfile extends Equatable {
  final String userId;
  final int totalXP;
  final int level;
  final String rank;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final List<String> unlockedBadges;
  final List<String> unlockedThemes;
  final int streakFreezes; // Available freeze tokens
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.userId,
    this.totalXP = 0,
    this.level = 1,
    this.rank = 'Beginner',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.unlockedBadges = const [],
    this.unlockedThemes = const [],
    this.streakFreezes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate XP needed for next level
  int get xpForNextLevel {
    return calculateXPForLevel(level + 1);
  }

  /// Calculate XP for a given level (exponential curve)
  static int calculateXPForLevel(int level) {
    // Formula: XP = 100 * level^1.5
    return (100 * (level * level * level).toDouble() / level).toInt();
  }

  /// Progress to next level (0-100)
  double get levelProgress {
    final xpForCurrentLevel = calculateXPForLevel(level);
    final xpForNext = xpForNextLevel;
    final xpIntoLevel = totalXP - xpForCurrentLevel;
    final xpNeeded = xpForNext - xpForCurrentLevel;

    if (xpNeeded <= 0) return 100;
    return ((xpIntoLevel / xpNeeded) * 100).clamp(0, 100);
  }

  /// Determine rank based on level
  static String getRankForLevel(int level) {
    if (level >= 100) return 'Legendary Scholar';
    if (level >= 75) return 'Master';
    if (level >= 50) return 'Expert';
    if (level >= 25) return 'Scholar';
    if (level >= 10) return 'Apprentice';
    return 'Beginner';
  }

  /// Update XP and recalculate level
  UserProfile addXP(int xp) {
    final newTotalXP = totalXP + xp;
    int newLevel = level;

    // Check if leveled up
    while (newTotalXP >= calculateXPForLevel(newLevel + 1)) {
      newLevel++;
    }

    final newRank = getRankForLevel(newLevel);

    return copyWith(
      totalXP: newTotalXP,
      level: newLevel,
      rank: newRank,
      updatedAt: DateTime.now(),
    );
  }

  /// Update streak (call daily)
  UserProfile updateStreak({required bool completedTaskToday}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastActiveDate == null) {
      return copyWith(
        currentStreak: completedTaskToday ? 1 : 0,
        longestStreak: completedTaskToday ? 1 : 0,
        lastActiveDate: today,
        updatedAt: now,
      );
    }

    final lastActive = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );

    final daysSinceLastActive = today.difference(lastActive).inDays;

    if (daysSinceLastActive == 0) {
      // Same day, no change
      return this;
    } else if (daysSinceLastActive == 1 && completedTaskToday) {
      // Consecutive day with activity
      final newStreak = currentStreak + 1;
      return copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
        lastActiveDate: today,
        updatedAt: now,
      );
    } else if (daysSinceLastActive > 1) {
      // Streak broken
      return copyWith(
        currentStreak: completedTaskToday ? 1 : 0,
        lastActiveDate: today,
        updatedAt: now,
      );
    }

    return this;
  }

  /// Use a streak freeze
  UserProfile useStreakFreeze() {
    if (streakFreezes <= 0) return this;

    return copyWith(
      streakFreezes: streakFreezes - 1,
      lastActiveDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? userId,
    int? totalXP,
    int? level,
    String? rank,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    List<String>? unlockedBadges,
    List<String>? unlockedThemes,
    int? streakFreezes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalXP,
        level,
        rank,
        currentStreak,
        longestStreak,
        lastActiveDate,
        unlockedBadges,
        unlockedThemes,
        streakFreezes,
        createdAt,
        updatedAt,
      ];
}

/// Achievement badge
class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final BadgeCategory category;
  final String iconName;
  final int xpReward;
  final BadgeRarity rarity;

  // Unlock criteria
  final int? streakRequired;
  final int? tasksRequired;
  final int? studyHoursRequired;
  final int? perfectDaysRequired;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    this.xpReward = 100,
    this.rarity = BadgeRarity.common,
    this.streakRequired,
    this.tasksRequired,
    this.studyHoursRequired,
    this.perfectDaysRequired,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        iconName,
        xpReward,
        rarity,
        streakRequired,
        tasksRequired,
        studyHoursRequired,
        perfectDaysRequired,
      ];
}

/// Badge categories
enum BadgeCategory {
  streak,       // Streak-related
  productivity, // Task completion
  focus,        // Focus sessions
  learning,     // Study hours
  social,       // Study groups
  special,      // Special achievements
}

/// Badge rarity tiers
enum BadgeRarity {
  common,       // Easy to obtain
  uncommon,     // Moderate effort
  rare,         // Significant achievement
  epic,         // Very difficult
  legendary,    // Exceptional achievement
}

/// Focus session with tree planting (Forest-style)
class FocusSession extends Equatable {
  final String id;
  final String? taskId;
  final String? goalId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration targetDuration;
  final FocusSessionStatus status;

  // Tree growing
  final String treeType;
  final TreeGrowthStage growthStage;
  final bool treeGrown; // Successfully completed without leaving app

  // Distractions
  final int distractionCount;
  final List<DateTime> distractionTimestamps;

  const FocusSession({
    required this.id,
    this.taskId,
    this.goalId,
    required this.startTime,
    this.endTime,
    required this.targetDuration,
    this.status = FocusSessionStatus.active,
    this.treeType = 'oak',
    this.growthStage = TreeGrowthStage.seedling,
    this.treeGrown = false,
    this.distractionCount = 0,
    this.distractionTimestamps = const [],
  });

  /// Calculate elapsed time
  Duration get elapsedTime {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  /// Progress percentage (0-100)
  double get progress {
    final elapsed = elapsedTime.inSeconds;
    final target = targetDuration.inSeconds;
    if (target == 0) return 0;
    return ((elapsed / target) * 100).clamp(0, 100);
  }

  /// Check if session was successful
  bool get wasSuccessful {
    return status == FocusSessionStatus.completed &&
        treeGrown &&
        distractionCount <= 1; // Allow 1 minor distraction
  }

  /// Calculate XP earned
  int get xpEarned {
    if (!wasSuccessful) return 0;

    // Base XP: 10 per minute
    final baseXP = (elapsedTime.inMinutes * 10).toInt();

    // Bonus for no distractions
    final distractionBonus = distractionCount == 0 ? (baseXP * 0.5).toInt() : 0;

    // Bonus for longer sessions
    final durationBonus = elapsedTime.inMinutes > 60 ? 200 : 0;

    return baseXP + distractionBonus + durationBonus;
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        goalId,
        startTime,
        endTime,
        targetDuration,
        status,
        treeType,
        growthStage,
        treeGrown,
        distractionCount,
        distractionTimestamps,
      ];
}

/// Focus session status
enum FocusSessionStatus {
  active,      // Currently in progress
  paused,      // Paused (tree stops growing)
  completed,   // Successfully completed
  abandoned,   // Left early (tree died)
}

/// Tree growth stages
enum TreeGrowthStage {
  seedling,    // 0-25%
  sapling,     // 25-50%
  young,       // 50-75%
  mature,      // 75-100%
  fullGrown,   // 100%
}

/// Virtual forest (collection of grown trees)
class Forest extends Equatable {
  final String id;
  final String userId;
  final String name;
  final List<Tree> trees;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Forest({
    required this.id,
    required this.userId,
    required this.name,
    this.trees = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total focus time (sum of all trees)
  Duration get totalFocusTime {
    return trees.fold(
      Duration.zero,
      (sum, tree) => sum + tree.duration,
    );
  }

  /// Count by tree type
  Map<String, int> get treeTypeCount {
    final counts = <String, int>{};
    for (final tree in trees) {
      counts[tree.type] = (counts[tree.type] ?? 0) + 1;
    }
    return counts;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        trees,
        createdAt,
        updatedAt,
      ];
}

/// Individual tree in the forest
class Tree extends Equatable {
  final String id;
  final String forestId;
  final String type; // oak, pine, cherry, etc.
  final Duration duration;
  final DateTime grownAt;
  final String? taskId;
  final String? goalId;
  final int xpEarned;

  const Tree({
    required this.id,
    required this.forestId,
    required this.type,
    required this.duration,
    required this.grownAt,
    this.taskId,
    this.goalId,
    this.xpEarned = 0,
  });

  @override
  List<Object?> get props => [
        id,
        forestId,
        type,
        duration,
        grownAt,
        taskId,
        goalId,
        xpEarned,
      ];
}

/// XP action for tracking how XP was earned
class XPAction extends Equatable {
  final String id;
  final String userId;
  final XPSource source;
  final int amount;
  final String? sourceId; // Task, goal, or session ID
  final DateTime earnedAt;

  const XPAction({
    required this.id,
    required this.userId,
    required this.source,
    required this.amount,
    this.sourceId,
    required this.earnedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        source,
        amount,
        sourceId,
        earnedAt,
      ];
}

/// Sources of XP
enum XPSource {
  taskCompleted,        // +50 XP
  assignmentCompleted,  // +100 XP
  goalAchieved,         // +200 XP
  streakMaintained,     // +10 XP per day
  focusSession,         // +10 XP per minute
  badgeUnlocked,        // Variable
  perfectDay,           // +500 XP (all tasks done)
  flashcardReviewed,    // +5 XP per card
  studySessionComplete, // +50 XP
}
