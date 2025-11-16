import 'package:studybuddy/features/gamification/domain/entities/gamification.dart';

/// Service for managing focus sessions with tree planting
class FocusModeService {
  /// Start a new focus session
  FocusSession startFocusSession({
    required String taskId,
    required String? goalId,
    required int durationMinutes,
    required TreeType treeType,
  }) {
    return FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      goalId: goalId,
      startTime: DateTime.now(),
      targetDuration: Duration(minutes: durationMinutes),
      status: FocusSessionStatus.active,
      treeType: treeType,
      growthStage: TreeGrowthStage.seed,
      treeGrown: false,
      distractionCount: 0,
      distractionTimestamps: [],
    );
  }

  /// Update growth stage based on elapsed time
  FocusSession updateGrowthStage(FocusSession session) {
    final elapsed = session.elapsedTime;
    final target = session.targetDuration;
    final progress = elapsed.inSeconds / target.inSeconds;

    TreeGrowthStage newStage;

    if (progress < 0.2) {
      newStage = TreeGrowthStage.seed;
    } else if (progress < 0.4) {
      newStage = TreeGrowthStage.sprout;
    } else if (progress < 0.6) {
      newStage = TreeGrowthStage.sapling;
    } else if (progress < 0.8) {
      newStage = TreeGrowthStage.tree;
    } else {
      newStage = TreeGrowthStage.giant;
    }

    return session.copyWith(growthStage: newStage);
  }

  /// Register a distraction event
  FocusSession registerDistraction(FocusSession session) {
    final updatedTimestamps = [...session.distractionTimestamps, DateTime.now()];

    // Too many distractions kills the tree
    if (session.distractionCount >= 2) {
      return session.copyWith(
        distractionCount: session.distractionCount + 1,
        distractionTimestamps: updatedTimestamps,
        status: FocusSessionStatus.failed,
        endTime: DateTime.now(),
        treeGrown: false,
      );
    }

    return session.copyWith(
      distractionCount: session.distractionCount + 1,
      distractionTimestamps: updatedTimestamps,
    );
  }

  /// Pause focus session
  FocusSession pauseSession(FocusSession session) {
    if (session.status != FocusSessionStatus.active) {
      return session;
    }

    return session.copyWith(status: FocusSessionStatus.paused);
  }

  /// Resume focus session
  FocusSession resumeSession(FocusSession session) {
    if (session.status != FocusSessionStatus.paused) {
      return session;
    }

    return session.copyWith(status: FocusSessionStatus.active);
  }

  /// Complete focus session successfully
  FocusSessionCompletionResult completeSession({
    required FocusSession session,
    required String userId,
  }) {
    final wasSuccessful = session.wasSuccessful;
    final xpEarned = session.xpEarned;

    Tree? tree;
    if (wasSuccessful) {
      tree = Tree(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        focusSessionId: session.id,
        treeType: session.treeType,
        plantedAt: DateTime.now(),
        forestId: null, // Will be assigned by repository
      );
    }

    final completedSession = session.copyWith(
      status: FocusSessionStatus.completed,
      endTime: DateTime.now(),
      treeGrown: wasSuccessful,
      growthStage: wasSuccessful ? TreeGrowthStage.giant : session.growthStage,
    );

    return FocusSessionCompletionResult(
      session: completedSession,
      tree: tree,
      xpEarned: xpEarned,
      wasSuccessful: wasSuccessful,
      message: _getCompletionMessage(wasSuccessful, session.distractionCount),
    );
  }

  /// Fail/abandon focus session
  FocusSession failSession(FocusSession session) {
    return session.copyWith(
      status: FocusSessionStatus.failed,
      endTime: DateTime.now(),
      treeGrown: false,
    );
  }

  /// Get recommended focus duration based on task
  int getRecommendedDuration({
    required String taskType,
    int? estimatedMinutes,
  }) {
    if (estimatedMinutes != null) {
      // Round to nearest Pomodoro (25 min intervals)
      final pomodoros = (estimatedMinutes / 25).ceil();
      return pomodoros * 25;
    }

    // Default recommendations by task type
    switch (taskType) {
      case 'flashcard_review':
        return 25; // 1 Pomodoro
      case 'reading':
        return 50; // 2 Pomodoros
      case 'writing':
        return 75; // 3 Pomodoros
      case 'problem_solving':
        return 50; // 2 Pomodoros
      default:
        return 25; // Default 1 Pomodoro
    }
  }

  /// Get available tree types with unlock requirements
  List<TreeTypeInfo> getAvailableTreeTypes(int userLevel) {
    return [
      TreeTypeInfo(
        type: TreeType.oak,
        name: 'Oak Tree',
        description: 'Classic and sturdy',
        unlockLevel: 1,
        isUnlocked: true,
      ),
      TreeTypeInfo(
        type: TreeType.pine,
        name: 'Pine Tree',
        description: 'Tall and elegant',
        unlockLevel: 5,
        isUnlocked: userLevel >= 5,
      ),
      TreeTypeInfo(
        type: TreeType.cherry,
        name: 'Cherry Blossom',
        description: 'Beautiful and serene',
        unlockLevel: 10,
        isUnlocked: userLevel >= 10,
      ),
      TreeTypeInfo(
        type: TreeType.maple,
        name: 'Maple Tree',
        description: 'Vibrant and colorful',
        unlockLevel: 15,
        isUnlocked: userLevel >= 15,
      ),
      TreeTypeInfo(
        type: TreeType.willow,
        name: 'Willow Tree',
        description: 'Graceful and calming',
        unlockLevel: 20,
        isUnlocked: userLevel >= 20,
      ),
      TreeTypeInfo(
        type: TreeType.bamboo,
        name: 'Bamboo',
        description: 'Fast-growing and resilient',
        unlockLevel: 25,
        isUnlocked: userLevel >= 25,
      ),
      TreeTypeInfo(
        type: TreeType.sakura,
        name: 'Sakura',
        description: 'Rare and precious',
        unlockLevel: 50,
        isUnlocked: userLevel >= 50,
      ),
    ];
  }

  /// Calculate forest statistics
  ForestStatistics calculateForestStats(List<Tree> trees) {
    final totalTrees = trees.length;

    // Count by type
    final treeTypeCounts = <TreeType, int>{};
    for (final tree in trees) {
      treeTypeCounts[tree.treeType] = (treeTypeCounts[tree.treeType] ?? 0) + 1;
    }

    // Calculate growth milestones
    final forestLevel = _calculateForestLevel(totalTrees);
    final nextMilestone = _getNextMilestone(totalTrees);

    // Calculate CO2 saved (gamified metric: 1 tree = 1kg CO2)
    final co2SavedKg = totalTrees;

    // Calculate focus hours (estimate 30 min per tree)
    final totalFocusHours = (totalTrees * 0.5).toInt();

    return ForestStatistics(
      totalTrees: totalTrees,
      treesByType: treeTypeCounts,
      forestLevel: forestLevel,
      nextMilestone: nextMilestone,
      co2SavedKg: co2SavedKg,
      totalFocusHours: totalFocusHours,
      oldestTree: trees.isNotEmpty
          ? trees.reduce((a, b) => a.plantedAt.isBefore(b.plantedAt) ? a : b)
          : null,
      newestTree: trees.isNotEmpty
          ? trees.reduce((a, b) => a.plantedAt.isAfter(b.plantedAt) ? a : b)
          : null,
    );
  }

  int _calculateForestLevel(int treeCount) {
    if (treeCount >= 1000) return 10; // Ancient Forest
    if (treeCount >= 500) return 9; // Legendary Forest
    if (treeCount >= 250) return 8; // Epic Forest
    if (treeCount >= 100) return 7; // Grand Forest
    if (treeCount >= 50) return 6; // Thriving Forest
    if (treeCount >= 25) return 5; // Growing Forest
    if (treeCount >= 10) return 4; // Young Forest
    if (treeCount >= 5) return 3; // Small Grove
    if (treeCount >= 2) return 2; // Seedling Cluster
    return 1; // Single Tree
  }

  int _getNextMilestone(int treeCount) {
    if (treeCount >= 1000) return 2000;
    if (treeCount >= 500) return 1000;
    if (treeCount >= 250) return 500;
    if (treeCount >= 100) return 250;
    if (treeCount >= 50) return 100;
    if (treeCount >= 25) return 50;
    if (treeCount >= 10) return 25;
    if (treeCount >= 5) return 10;
    if (treeCount >= 2) return 5;
    return 2;
  }

  String _getCompletionMessage(bool successful, int distractions) {
    if (!successful) {
      return '🪦 Your tree died from distractions. Try again!';
    }

    if (distractions == 0) {
      return '🌳 Perfect focus! Your tree grew beautifully!';
    } else if (distractions == 1) {
      return '🌲 Good job! Your tree grew despite one distraction.';
    } else {
      return '🌱 Your tree survived, but needs better focus next time.';
    }
  }
}

/// Result of completing a focus session
class FocusSessionCompletionResult {
  final FocusSession session;
  final Tree? tree;
  final int xpEarned;
  final bool wasSuccessful;
  final String message;

  const FocusSessionCompletionResult({
    required this.session,
    required this.tree,
    required this.xpEarned,
    required this.wasSuccessful,
    required this.message,
  });
}

/// Tree type information with unlock requirements
class TreeTypeInfo {
  final TreeType type;
  final String name;
  final String description;
  final int unlockLevel;
  final bool isUnlocked;

  const TreeTypeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.unlockLevel,
    required this.isUnlocked,
  });
}

/// Forest statistics
class ForestStatistics {
  final int totalTrees;
  final Map<TreeType, int> treesByType;
  final int forestLevel;
  final int nextMilestone;
  final int co2SavedKg;
  final int totalFocusHours;
  final Tree? oldestTree;
  final Tree? newestTree;

  const ForestStatistics({
    required this.totalTrees,
    required this.treesByType,
    required this.forestLevel,
    required this.nextMilestone,
    required this.co2SavedKg,
    required this.totalFocusHours,
    this.oldestTree,
    this.newestTree,
  });

  String get forestLevelName {
    switch (forestLevel) {
      case 10:
        return 'Ancient Forest';
      case 9:
        return 'Legendary Forest';
      case 8:
        return 'Epic Forest';
      case 7:
        return 'Grand Forest';
      case 6:
        return 'Thriving Forest';
      case 5:
        return 'Growing Forest';
      case 4:
        return 'Young Forest';
      case 3:
        return 'Small Grove';
      case 2:
        return 'Seedling Cluster';
      default:
        return 'Single Tree';
    }
  }
}
