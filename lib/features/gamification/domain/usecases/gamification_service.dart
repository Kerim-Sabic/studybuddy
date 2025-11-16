import 'package:studybuddy/features/gamification/domain/entities/gamification.dart';

/// Service for managing gamification features (XP, badges, streaks, etc.)
class GamificationService {
  /// Award XP for completing an action
  Future<UserProfileUpdateResult> awardXP({
    required UserProfile profile,
    required String action,
    required int baseXP,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    // Calculate multipliers
    double multiplier = 1.0;

    // Streak bonus: +10% per week of streak (max +100%)
    final streakWeeks = (profile.currentStreak / 7).floor();
    final streakBonus = (streakWeeks * 0.1).clamp(0, 1.0);
    multiplier += streakBonus;

    // Level bonus: +5% per 10 levels (max +50%)
    final levelBonus = ((profile.level ~/ 10) * 0.05).clamp(0, 0.5);
    multiplier += levelBonus;

    final finalXP = (baseXP * multiplier).round();

    // Update profile
    final updatedProfile = profile.addXP(finalXP);

    // Check for level up
    final leveledUp = updatedProfile.level > profile.level;
    final newBadges = <String>[];

    // Check for newly unlocked badges
    if (leveledUp) {
      // Award level milestone badges
      if (updatedProfile.level == 10) {
        newBadges.add('apprentice_scholar');
      } else if (updatedProfile.level == 25) {
        newBadges.add('dedicated_student');
      } else if (updatedProfile.level == 50) {
        newBadges.add('expert_learner');
      } else if (updatedProfile.level == 75) {
        newBadges.add('master_scholar');
      } else if (updatedProfile.level == 100) {
        newBadges.add('legendary_scholar');
      }
    }

    return UserProfileUpdateResult(
      profile: updatedProfile,
      xpGained: finalXP,
      leveledUp: leveledUp,
      previousLevel: profile.level,
      newLevel: updatedProfile.level,
      newBadges: newBadges,
      xpAction: XPAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: profile.userId,
        action: action,
        xpGained: finalXP,
        timestamp: DateTime.now(),
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
      ),
    );
  }

  /// Update daily streak
  Future<UserProfile> updateStreak(UserProfile profile) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (profile.lastActiveDate == null) {
      // First time
      return profile.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastActiveDate: today,
      );
    }

    final lastActive = DateTime(
      profile.lastActiveDate!.year,
      profile.lastActiveDate!.month,
      profile.lastActiveDate!.day,
    );

    final daysDifference = today.difference(lastActive).inDays;

    if (daysDifference == 0) {
      // Same day - no change
      return profile;
    } else if (daysDifference == 1) {
      // Consecutive day - increase streak
      final newStreak = profile.currentStreak + 1;
      return profile.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > profile.longestStreak
            ? newStreak
            : profile.longestStreak,
        lastActiveDate: today,
      );
    } else if (daysDifference > 1 && profile.streakFreezes > 0) {
      // Use a streak freeze
      return profile.copyWith(
        streakFreezes: profile.streakFreezes - 1,
        lastActiveDate: today,
      );
    } else {
      // Streak broken
      return profile.copyWith(
        currentStreak: 1,
        lastActiveDate: today,
      );
    }
  }

  /// Calculate XP for different actions
  int calculateXPForAction(GamificationAction action) {
    switch (action) {
      // Flashcard reviews
      case GamificationAction.reviewFlashcard:
        return 5;
      case GamificationAction.reviewFlashcardPerfect:
        return 10;
      case GamificationAction.completeDeck:
        return 100;

      // Tasks & assignments
      case GamificationAction.completeTask:
        return 20;
      case GamificationAction.completeAssignment:
        return 50;
      case GamificationAction.completeAssignmentEarly:
        return 75;

      // Goals
      case GamificationAction.achieveGoal:
        return 100;
      case GamificationAction.reachMilestone:
        return 50;

      // Study sessions
      case GamificationAction.completeStudySession:
        return 30;
      case GamificationAction.focusSession25min:
        return 25;
      case GamificationAction.focusSession50min:
        return 60;
      case GamificationAction.focusSession90min:
        return 120;
      case GamificationAction.perfectFocusNoDistractions:
        return 150;

      // Notes & learning
      case GamificationAction.createNote:
        return 15;
      case GamificationAction.createMindMap:
        return 40;
      case GamificationAction.completeFeynmanSession:
        return 50;
      case GamificationAction.completeReadingSession:
        return 35;

      // Streaks
      case GamificationAction.weekStreak:
        return 50;
      case GamificationAction.monthStreak:
        return 200;
      case GamificationAction.yearStreak:
        return 1000;

      // Well-being
      case GamificationAction.dailyCheckIn:
        return 10;
      case GamificationAction.takeScheduledBreak:
        return 5;
      case GamificationAction.completeSleepLog:
        return 15;
      case GamificationAction.completeBreathingExercise:
        return 20;

      // Social (future)
      case GamificationAction.helpPeer:
        return 30;
      case GamificationAction.joinStudyGroup:
        return 25;
    }
  }

  /// Check badge eligibility and return newly unlocked badges
  Future<List<Badge>> checkBadgeEligibility({
    required UserProfile profile,
    required Map<String, dynamic> userStats,
  }) async {
    final newBadges = <Badge>[];

    // Study time badges
    final totalStudyHours = userStats['totalStudyHours'] as int? ?? 0;
    if (totalStudyHours >= 100 && !profile.unlockedBadges.contains('century_scholar')) {
      newBadges.add(_createBadge(
        id: 'century_scholar',
        name: '100 Hour Scholar',
        description: 'Studied for 100 hours total',
        category: BadgeCategory.studyTime,
        rarity: BadgeRarity.rare,
      ));
    }
    if (totalStudyHours >= 500 && !profile.unlockedBadges.contains('dedicated_learner')) {
      newBadges.add(_createBadge(
        id: 'dedicated_learner',
        name: 'Dedicated Learner',
        description: 'Studied for 500 hours total',
        category: BadgeCategory.studyTime,
        rarity: BadgeRarity.epic,
      ));
    }

    // Streak badges
    if (profile.currentStreak >= 7 && !profile.unlockedBadges.contains('week_warrior')) {
      newBadges.add(_createBadge(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: 'Maintained a 7-day streak',
        category: BadgeCategory.streaks,
        rarity: BadgeRarity.common,
      ));
    }
    if (profile.currentStreak >= 30 && !profile.unlockedBadges.contains('month_master')) {
      newBadges.add(_createBadge(
        id: 'month_master',
        name: 'Month Master',
        description: 'Maintained a 30-day streak',
        category: BadgeCategory.streaks,
        rarity: BadgeRarity.rare,
      ));
    }
    if (profile.currentStreak >= 100 && !profile.unlockedBadges.contains('century_streak')) {
      newBadges.add(_createBadge(
        id: 'century_streak',
        name: 'Century Streak',
        description: 'Maintained a 100-day streak',
        category: BadgeCategory.streaks,
        rarity: BadgeRarity.legendary,
      ));
    }

    // Flashcard badges
    final totalFlashcardsReviewed = userStats['totalFlashcardsReviewed'] as int? ?? 0;
    if (totalFlashcardsReviewed >= 1000 && !profile.unlockedBadges.contains('flashcard_master')) {
      newBadges.add(_createBadge(
        id: 'flashcard_master',
        name: 'Flashcard Master',
        description: 'Reviewed 1000 flashcards',
        category: BadgeCategory.flashcards,
        rarity: BadgeRarity.rare,
      ));
    }

    // Focus badges
    final perfectFocusSessions = userStats['perfectFocusSessions'] as int? ?? 0;
    if (perfectFocusSessions >= 10 && !profile.unlockedBadges.contains('focus_champion')) {
      newBadges.add(_createBadge(
        id: 'focus_champion',
        name: 'Focus Champion',
        description: 'Completed 10 perfect focus sessions',
        category: BadgeCategory.focus,
        rarity: BadgeRarity.epic,
      ));
    }

    // Goal achievement badges
    final goalsAchieved = userStats['goalsAchieved'] as int? ?? 0;
    if (goalsAchieved >= 10 && !profile.unlockedBadges.contains('goal_getter')) {
      newBadges.add(_createBadge(
        id: 'goal_getter',
        name: 'Goal Getter',
        description: 'Achieved 10 goals',
        category: BadgeCategory.achievements,
        rarity: BadgeRarity.rare,
      ));
    }

    // Well-being badges
    final wellbeingCheckIns = userStats['wellbeingCheckIns'] as int? ?? 0;
    if (wellbeingCheckIns >= 30 && !profile.unlockedBadges.contains('wellness_warrior')) {
      newBadges.add(_createBadge(
        id: 'wellness_warrior',
        name: 'Wellness Warrior',
        description: 'Completed 30 well-being check-ins',
        category: BadgeCategory.wellbeing,
        rarity: BadgeRarity.rare,
      ));
    }

    // Forest badges
    final treesGrown = userStats['treesGrown'] as int? ?? 0;
    if (treesGrown >= 50 && !profile.unlockedBadges.contains('forest_guardian')) {
      newBadges.add(_createBadge(
        id: 'forest_guardian',
        name: 'Forest Guardian',
        description: 'Grew 50 focus trees',
        category: BadgeCategory.focus,
        rarity: BadgeRarity.epic,
      ));
    }

    return newBadges;
  }

  Badge _createBadge({
    required String id,
    required String name,
    required String description,
    required BadgeCategory category,
    required BadgeRarity rarity,
  }) {
    int xpReward;
    switch (rarity) {
      case BadgeRarity.common:
        xpReward = 50;
        break;
      case BadgeRarity.rare:
        xpReward = 150;
        break;
      case BadgeRarity.epic:
        xpReward = 300;
        break;
      case BadgeRarity.legendary:
        xpReward = 1000;
        break;
    }

    return Badge(
      id: id,
      name: name,
      description: description,
      icon: '🏆', // Would be replaced with actual icon path
      category: category,
      rarity: rarity,
      xpReward: xpReward,
      requirement: description,
      requiredCount: 1,
      createdAt: DateTime.now(),
    );
  }

  /// Get leaderboard position (future implementation)
  Future<LeaderboardPosition> getLeaderboardPosition({
    required UserProfile profile,
    required LeaderboardType type,
  }) async {
    // Placeholder for leaderboard functionality
    return LeaderboardPosition(
      rank: 0,
      totalUsers: 0,
      percentile: 0,
    );
  }
}

/// Result of updating user profile with XP
class UserProfileUpdateResult {
  final UserProfile profile;
  final int xpGained;
  final bool leveledUp;
  final int previousLevel;
  final int newLevel;
  final List<String> newBadges;
  final XPAction xpAction;

  const UserProfileUpdateResult({
    required this.profile,
    required this.xpGained,
    required this.leveledUp,
    required this.previousLevel,
    required this.newLevel,
    required this.newBadges,
    required this.xpAction,
  });
}

/// Actions that can earn XP
enum GamificationAction {
  // Flashcards
  reviewFlashcard,
  reviewFlashcardPerfect,
  completeDeck,

  // Tasks & Assignments
  completeTask,
  completeAssignment,
  completeAssignmentEarly,

  // Goals
  achieveGoal,
  reachMilestone,

  // Study sessions
  completeStudySession,
  focusSession25min,
  focusSession50min,
  focusSession90min,
  perfectFocusNoDistractions,

  // Notes & Learning
  createNote,
  createMindMap,
  completeFeynmanSession,
  completeReadingSession,

  // Streaks
  weekStreak,
  monthStreak,
  yearStreak,

  // Well-being
  dailyCheckIn,
  takeScheduledBreak,
  completeSleepLog,
  completeBreathingExercise,

  // Social (future)
  helpPeer,
  joinStudyGroup,
}

/// Leaderboard position
class LeaderboardPosition {
  final int rank;
  final int totalUsers;
  final double percentile;

  const LeaderboardPosition({
    required this.rank,
    required this.totalUsers,
    required this.percentile,
  });
}

/// Leaderboard types
enum LeaderboardType {
  xp,
  streak,
  studyTime,
  flashcards,
  goals,
}
