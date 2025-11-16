import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';

import '../../../../core/data/providers/database_provider.dart';
import '../../../../core/data/database/app_database.dart';
import '../../domain/entities/task.dart' as entity;
import '../../../../core/constants/app_constants.dart';

/// Provider for all tasks
final tasksProvider = StreamProvider<List<entity.Task>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.select(database.tasks).watch().map((tasks) {
    return tasks.map((t) => _taskFromDb(t)).toList();
  });
});

/// Provider for pending tasks
final pendingTasksProvider = StreamProvider<List<entity.Task>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getPendingTasks().asStream().map((tasks) {
    return tasks.map((t) => _taskFromDb(t)).toList();
  });
});

/// Provider for today's tasks
final todayTasksProvider = StreamProvider<List<entity.Task>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getTasksForToday().asStream().map((tasks) {
    return tasks.map((t) => _taskFromDb(t)).toList();
  });
});

/// Task controller
final taskControllerProvider = Provider<TaskController>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskController(database);
});

class TaskController {
  final AppDatabase _database;
  final _uuid = const Uuid();

  TaskController(this._database);

  /// Create a new task
  Future<String> createTask({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    String? categoryId,
    String? courseId,
    DateTime? dueDate,
    DateTime? reminderTime,
    int? estimatedMinutes,
    List<String>? tags,
  }) async {
    final id = _uuid.v4();
    final task = TasksCompanion.insert(
      id: id,
      title: title,
      description: drift.Value(description),
      priority: priority.name,
      categoryId: drift.Value(categoryId),
      courseId: drift.Value(courseId),
      dueDate: drift.Value(dueDate),
      reminderTime: drift.Value(reminderTime),
      estimatedMinutes: drift.Value(estimatedMinutes),
      tags: drift.Value(tags != null ? jsonEncode(tags) : null),
      createdAt: DateTime.now(),
    );

    await _database.insertTask(task);
    return id;
  }

  /// Update a task
  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    int? actualMinutes,
  }) async {
    final task = TasksCompanion(
      id: drift.Value(id),
      title: title != null ? drift.Value(title) : const drift.Value.absent(),
      description: description != null ? drift.Value(description) : const drift.Value.absent(),
      priority: priority != null ? drift.Value(priority.name) : const drift.Value.absent(),
      dueDate: dueDate != null ? drift.Value(dueDate) : const drift.Value.absent(),
      isCompleted: isCompleted != null ? drift.Value(isCompleted) : const drift.Value.absent(),
      completedAt: isCompleted == true
          ? drift.Value(DateTime.now())
          : const drift.Value.absent(),
      actualMinutes: actualMinutes != null
          ? drift.Value(actualMinutes)
          : const drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now()),
    );

    await _database.updateTask(task);
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    await updateTask(id: id, isCompleted: isCompleted);
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    await _database.deleteTask(id);
  }

  /// Add subtask
  Future<String> addSubTask({
    required String taskId,
    required String title,
  }) async {
    final id = _uuid.v4();
    final subtask = SubTasksCompanion.insert(
      id: id,
      taskId: taskId,
      title: title,
    );

    await _database.insertSubTask(subtask);
    return id;
  }

  /// Toggle subtask completion
  Future<void> toggleSubTaskCompletion(String id, bool isCompleted) async {
    final subtask = SubTasksCompanion(
      id: drift.Value(id),
      isCompleted: drift.Value(isCompleted),
      completedAt: isCompleted ? drift.Value(DateTime.now()) : const drift.Value.absent(),
    );

    await _database.updateSubTask(subtask);
  }
}

// Helper function to convert database model to entity
entity.Task _taskFromDb(Task task) {
  return entity.Task(
    id: task.id,
    title: task.title,
    description: task.description,
    priority: Priority.values.firstWhere(
      (p) => p.name == task.priority,
      orElse: () => Priority.medium,
    ),
    categoryId: task.categoryId,
    courseId: task.courseId,
    dueDate: task.dueDate,
    reminderTime: task.reminderTime,
    isCompleted: task.isCompleted,
    completedAt: task.completedAt,
    subtasks: const [], // Load separately if needed
    recurrence: null, // Parse from JSON if needed
    tags: task.tags != null ? List<String>.from(jsonDecode(task.tags!)) : [],
    estimatedMinutes: task.estimatedMinutes,
    actualMinutes: task.actualMinutes,
    parentTaskId: task.parentTaskId,
    sortOrder: task.sortOrder,
    createdAt: task.createdAt,
    updatedAt: task.updatedAt,
  );
}
