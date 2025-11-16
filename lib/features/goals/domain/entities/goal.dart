import 'package:equatable/equatable.dart';

/// Goal entity for setting and tracking academic goals
class Goal extends Equatable {
  final String id;
  final String title;
  final String? description;
  final GoalType type;
  final GoalCategory category;
  final DateTime startDate;
  final DateTime targetDate;
  final double targetValue;
  final double currentValue;
  final String unit; // e.g., "hours", "pages", "assignments", "%"
  final List<Milestone> milestones;
  final String? courseId;
  final List<String> tags;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Goal({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.startDate,
    required this.targetDate,
    required this.targetValue,
    this.currentValue = 0.0,
    required this.unit,
    this.milestones = const [],
    this.courseId,
    this.tags = const [],
    this.isCompleted = false,
    this.completedAt,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    GoalCategory? category,
    DateTime? startDate,
    DateTime? targetDate,
    double? targetValue,
    double? currentValue,
    String? unit,
    List<Milestone>? milestones,
    String? courseId,
    List<String>? tags,
    bool? isCompleted,
    DateTime? completedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      milestones: milestones ?? this.milestones,
      courseId: courseId ?? this.courseId,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get completion percentage
  double get completionPercentage {
    if (targetValue == 0) return 0.0;
    final percentage = (currentValue / targetValue) * 100;
    return percentage > 100 ? 100.0 : percentage;
  }

  /// Check if goal is achieved
  bool get isAchieved {
    return currentValue >= targetValue;
  }

  /// Get days remaining
  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  /// Get days elapsed
  int get daysElapsed {
    return DateTime.now().difference(startDate).inDays;
  }

  /// Get total duration in days
  int get totalDurationDays {
    return targetDate.difference(startDate).inDays;
  }

  /// Get time progress percentage
  double get timeProgressPercentage {
    if (totalDurationDays == 0) return 0.0;
    final percentage = (daysElapsed / totalDurationDays) * 100;
    return percentage > 100 ? 100.0 : percentage;
  }

  /// Check if goal is on track (completion >= time progress)
  bool get isOnTrack {
    return completionPercentage >= timeProgressPercentage;
  }

  /// Check if goal is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(targetDate);
  }

  /// Get recommended daily progress
  double get recommendedDailyProgress {
    if (daysRemaining <= 0) return 0.0;
    final remaining = targetValue - currentValue;
    return remaining / daysRemaining;
  }

  /// Get completed milestones count
  int get completedMilestonesCount {
    return milestones.where((m) => m.isCompleted).length;
  }

  /// Get milestones completion percentage
  double get milestonesCompletionPercentage {
    if (milestones.isEmpty) return 0.0;
    return (completedMilestonesCount / milestones.length) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        startDate,
        targetDate,
        targetValue,
        currentValue,
        unit,
        milestones,
        courseId,
        tags,
        isCompleted,
        completedAt,
        notes,
        createdAt,
        updatedAt,
      ];
}

/// Milestone for breaking down goals
class Milestone extends Equatable {
  final String id;
  final String goalId;
  final String title;
  final String? description;
  final double targetValue;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;

  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.description,
    required this.targetValue,
    required this.targetDate,
    this.isCompleted = false,
    this.completedAt,
    this.sortOrder = 0,
  });

  Milestone copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    double? targetValue,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
  }) {
    return Milestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Get days remaining
  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  /// Check if milestone is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(targetDate);
  }

  @override
  List<Object?> get props => [
        id,
        goalId,
        title,
        description,
        targetValue,
        targetDate,
        isCompleted,
        completedAt,
        sortOrder,
      ];
}

/// Type of goal
enum GoalType {
  shortTerm, // < 1 month
  mediumTerm, // 1-6 months
  longTerm, // > 6 months
}

extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.shortTerm:
        return 'Short-term';
      case GoalType.mediumTerm:
        return 'Medium-term';
      case GoalType.longTerm:
        return 'Long-term';
    }
  }

  String get description {
    switch (this) {
      case GoalType.shortTerm:
        return 'Less than 1 month';
      case GoalType.mediumTerm:
        return '1-6 months';
      case GoalType.longTerm:
        return 'More than 6 months';
    }
  }
}

/// Category of goal
enum GoalCategory {
  grade, // Grade improvement
  studyTime, // Study hours
  completion, // Complete X assignments/chapters
  skill, // Learn a skill
  habit, // Build a habit
  project, // Complete a project
  reading, // Reading goals
  other,
}

extension GoalCategoryExtension on GoalCategory {
  String get displayName {
    switch (this) {
      case GoalCategory.grade:
        return 'Grade Improvement';
      case GoalCategory.studyTime:
        return 'Study Time';
      case GoalCategory.completion:
        return 'Completion';
      case GoalCategory.skill:
        return 'Skill Development';
      case GoalCategory.habit:
        return 'Habit Building';
      case GoalCategory.project:
        return 'Project';
      case GoalCategory.reading:
        return 'Reading';
      case GoalCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case GoalCategory.grade:
        return '📈';
      case GoalCategory.studyTime:
        return '⏱️';
      case GoalCategory.completion:
        return '✅';
      case GoalCategory.skill:
        return '🎯';
      case GoalCategory.habit:
        return '🔄';
      case GoalCategory.project:
        return '🚀';
      case GoalCategory.reading:
        return '📚';
      case GoalCategory.other:
        return '⭐';
    }
  }
}
