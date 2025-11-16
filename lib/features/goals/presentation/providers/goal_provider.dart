import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';

import '../../../../core/data/providers/database_provider.dart';
import '../../../../core/data/database/app_database.dart';
import '../../domain/entities/goal.dart' as entity;

/// Provider for all goals
final goalsProvider = StreamProvider<List<entity.Goal>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.select(database.goals).watch().map((goals) {
    return goals.map((g) => _goalFromDb(g)).toList();
  });
});

/// Provider for active goals
final activeGoalsProvider = StreamProvider<List<entity.Goal>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getActiveGoals().asStream().map((goals) {
    return goals.map((g) => _goalFromDb(g)).toList();
  });
});

/// Provider for a single goal
final goalProvider = StreamProvider.family<entity.Goal?, String>((ref, id) {
  final database = ref.watch(databaseProvider);
  return database
      .getGoalById(id)
      .asStream()
      .map((goal) => goal != null ? _goalFromDb(goal) : null);
});

/// Goal controller
final goalControllerProvider = Provider<GoalController>((ref) {
  final database = ref.watch(databaseProvider);
  return GoalController(database);
});

class GoalController {
  final AppDatabase _database;
  final _uuid = const Uuid();

  GoalController(this._database);

  /// Create a new goal
  Future<String> createGoal({
    required String title,
    String? description,
    required entity.GoalType type,
    required entity.GoalCategory category,
    required DateTime startDate,
    required DateTime targetDate,
    required double targetValue,
    required String unit,
    String? courseId,
    List<String>? tags,
  }) async {
    final id = _uuid.v4();
    final goal = GoalsCompanion.insert(
      id: id,
      title: title,
      description: drift.Value(description),
      type: type.name,
      category: category.name,
      startDate: startDate,
      targetDate: targetDate,
      targetValue: targetValue,
      unit: unit,
      courseId: drift.Value(courseId),
      tags: drift.Value(tags != null ? jsonEncode(tags) : null),
      createdAt: DateTime.now(),
    );

    await _database.insertGoal(goal);
    return id;
  }

  /// Update a goal
  Future<void> updateGoal({
    required String id,
    String? title,
    String? description,
    double? currentValue,
    bool? isCompleted,
  }) async {
    final goal = GoalsCompanion(
      id: drift.Value(id),
      title: title != null ? drift.Value(title) : const drift.Value.absent(),
      description: description != null ? drift.Value(description) : const drift.Value.absent(),
      currentValue: currentValue != null ? drift.Value(currentValue) : const drift.Value.absent(),
      isCompleted: isCompleted != null ? drift.Value(isCompleted) : const drift.Value.absent(),
      completedAt: isCompleted == true
          ? drift.Value(DateTime.now())
          : const drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now()),
    );

    await _database.updateGoal(goal);
  }

  /// Update goal progress
  Future<void> updateProgress(String id, double newValue) async {
    await updateGoal(id: id, currentValue: newValue);
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _database.deleteGoal(id);
  }

  /// Add milestone to goal
  Future<String> addMilestone({
    required String goalId,
    required String title,
    String? description,
    required double targetValue,
    required DateTime targetDate,
  }) async {
    final id = _uuid.v4();
    final milestone = MilestonesCompanion.insert(
      id: id,
      goalId: goalId,
      title: title,
      description: drift.Value(description),
      targetValue: targetValue,
      targetDate: targetDate,
    );

    await _database.insertMilestone(milestone);
    return id;
  }

  /// Complete milestone
  Future<void> completeMilestone(String id) async {
    final milestone = MilestonesCompanion(
      id: drift.Value(id),
      isCompleted: const drift.Value(true),
      completedAt: drift.Value(DateTime.now()),
    );

    await _database.updateMilestone(milestone);
  }
}

// Helper function to convert database model to entity
entity.Goal _goalFromDb(Goal goal) {
  return entity.Goal(
    id: goal.id,
    title: goal.title,
    description: goal.description,
    type: entity.GoalType.values.firstWhere(
      (t) => t.name == goal.type,
      orElse: () => entity.GoalType.shortTerm,
    ),
    category: entity.GoalCategory.values.firstWhere(
      (c) => c.name == goal.category,
      orElse: () => entity.GoalCategory.other,
    ),
    startDate: goal.startDate,
    targetDate: goal.targetDate,
    targetValue: goal.targetValue,
    currentValue: goal.currentValue,
    unit: goal.unit,
    milestones: const [], // Load separately if needed
    courseId: goal.courseId,
    tags: goal.tags != null ? List<String>.from(jsonDecode(goal.tags!)) : [],
    isCompleted: goal.isCompleted,
    completedAt: goal.completedAt,
    notes: goal.notes,
    createdAt: goal.createdAt,
    updatedAt: goal.updatedAt,
  );
}
