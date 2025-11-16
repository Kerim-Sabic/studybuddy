import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';

import '../../../../core/data/providers/database_provider.dart';
import '../../../../core/data/database/app_database.dart';
import '../../domain/entities/assignment.dart' as entity;
import '../../../../core/constants/app_constants.dart';

/// Provider for all assignments
final assignmentsProvider = StreamProvider<List<entity.Assignment>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.select(database.assignments).watch().map((assignments) {
    return assignments.map((a) => _assignmentFromDb(a)).toList();
  });
});

/// Provider for pending assignments
final pendingAssignmentsProvider = StreamProvider<List<entity.Assignment>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getPendingAssignments().asStream().map((assignments) {
    return assignments.map((a) => _assignmentFromDb(a)).toList();
  });
});

/// Provider for upcoming assignments (next 7 days)
final upcomingAssignmentsProvider = StreamProvider<List<entity.Assignment>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getUpcomingAssignments().asStream().map((assignments) {
    return assignments.map((a) => _assignmentFromDb(a)).toList();
  });
});

/// Provider for assignments by course
final assignmentsByCourseProvider =
    StreamProvider.family<List<entity.Assignment>, String>((ref, courseId) {
  final database = ref.watch(databaseProvider);
  return database.getAssignmentsForCourse(courseId).asStream().map((assignments) {
    return assignments.map((a) => _assignmentFromDb(a)).toList();
  });
});

/// Assignment controller
final assignmentControllerProvider = Provider<AssignmentController>((ref) {
  final database = ref.watch(databaseProvider);
  return AssignmentController(database);
});

class AssignmentController {
  final AppDatabase _database;
  final _uuid = const Uuid();

  AssignmentController(this._database);

  /// Create a new assignment
  Future<String> createAssignment({
    required String courseId,
    required String title,
    String? description,
    required entity.AssignmentType type,
    required DateTime dueDate,
    Priority priority = Priority.medium,
    int? estimatedMinutes,
    List<String>? tags,
  }) async {
    final id = _uuid.v4();
    final assignment = AssignmentsCompanion.insert(
      id: id,
      courseId: courseId,
      title: title,
      description: drift.Value(description),
      type: type.name,
      dueDate: dueDate,
      priority: priority.name,
      estimatedMinutes: drift.Value(estimatedMinutes),
      tags: drift.Value(tags != null ? jsonEncode(tags) : null),
      createdAt: DateTime.now(),
    );

    await _database.insertAssignment(assignment);
    return id;
  }

  /// Update an assignment
  Future<void> updateAssignment({
    required String id,
    String? title,
    String? description,
    entity.AssignmentType? type,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    int? estimatedMinutes,
    int? actualMinutes,
    double? grade,
    double? maxGrade,
  }) async {
    final assignment = AssignmentsCompanion(
      id: drift.Value(id),
      title: title != null ? drift.Value(title) : const drift.Value.absent(),
      description: description != null ? drift.Value(description) : const drift.Value.absent(),
      type: type != null ? drift.Value(type.name) : const drift.Value.absent(),
      dueDate: dueDate != null ? drift.Value(dueDate) : const drift.Value.absent(),
      priority: priority != null ? drift.Value(priority.name) : const drift.Value.absent(),
      isCompleted: isCompleted != null ? drift.Value(isCompleted) : const drift.Value.absent(),
      completedAt: isCompleted == true
          ? drift.Value(DateTime.now())
          : const drift.Value.absent(),
      estimatedMinutes: estimatedMinutes != null
          ? drift.Value(estimatedMinutes)
          : const drift.Value.absent(),
      actualMinutes: actualMinutes != null
          ? drift.Value(actualMinutes)
          : const drift.Value.absent(),
      grade: grade != null ? drift.Value(grade) : const drift.Value.absent(),
      maxGrade: maxGrade != null ? drift.Value(maxGrade) : const drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now()),
    );

    await _database.updateAssignment(assignment);
  }

  /// Mark assignment as completed
  Future<void> completeAssignment(String id, {int? actualMinutes}) async {
    await updateAssignment(
      id: id,
      isCompleted: true,
      actualMinutes: actualMinutes,
    );
  }

  /// Delete an assignment
  Future<void> deleteAssignment(String id) async {
    await _database.deleteAssignment(id);
  }
}

// Helper function to convert database model to entity
entity.Assignment _assignmentFromDb(Assignment assignment) {
  return entity.Assignment(
    id: assignment.id,
    courseId: assignment.courseId,
    title: assignment.title,
    description: assignment.description,
    type: entity.AssignmentType.values.firstWhere(
      (t) => t.name == assignment.type,
      orElse: () => entity.AssignmentType.other,
    ),
    dueDate: assignment.dueDate,
    priority: Priority.values.firstWhere(
      (p) => p.name == assignment.priority,
      orElse: () => Priority.medium,
    ),
    isCompleted: assignment.isCompleted,
    completedAt: assignment.completedAt,
    estimatedMinutes: assignment.estimatedMinutes,
    actualMinutes: assignment.actualMinutes,
    attachments: assignment.attachments != null
        ? List<String>.from(jsonDecode(assignment.attachments!))
        : [],
    tags: assignment.tags != null ? List<String>.from(jsonDecode(assignment.tags!)) : [],
    grade: assignment.grade,
    maxGrade: assignment.maxGrade,
    notes: assignment.notes,
    createdAt: assignment.createdAt,
    updatedAt: assignment.updatedAt,
  );
}
