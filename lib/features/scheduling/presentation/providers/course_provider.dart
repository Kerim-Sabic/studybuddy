import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/providers/database_provider.dart';
import '../../../../core/data/database/app_database.dart';
import '../../domain/entities/course.dart' as entity;
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

/// Provider for all courses
final coursesProvider = StreamProvider<List<entity.Course>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.select(database.courses).watch().map((courses) {
    return courses.map((course) => _courseFromDb(course)).toList();
  });
});

/// Provider for a single course
final courseProvider = StreamProvider.family<entity.Course?, String>((ref, id) {
  final database = ref.watch(databaseProvider);
  return (database.select(database.courses)..where((c) => c.id.equals(id)))
      .watchSingleOrNull()
      .map((course) => course != null ? _courseFromDb(course) : null);
});

/// Provider for course sessions
final courseSessionsProvider = StreamProvider.family<List<entity.ClassSession>, String>((ref, courseId) {
  final database = ref.watch(databaseProvider);
  return (database.select(database.classSessions)..where((s) => s.courseId.equals(courseId)))
      .watch()
      .map((sessions) => sessions.map((s) => _sessionFromDb(s)).toList());
});

/// Course controller for managing courses
final courseControllerProvider = Provider<CourseController>((ref) {
  final database = ref.watch(databaseProvider);
  return CourseController(database);
});

class CourseController {
  final AppDatabase _database;
  final _uuid = const Uuid();

  CourseController(this._database);

  /// Create a new course
  Future<String> createCourse({
    required String name,
    String? code,
    String? instructor,
    String? location,
    required Color color,
    String? description,
  }) async {
    final id = _uuid.v4();
    final course = CoursesCompanion.insert(
      id: id,
      name: name,
      code: drift.Value(code),
      instructor: drift.Value(instructor),
      location: drift.Value(location),
      color: color.value,
      description: drift.Value(description),
      createdAt: DateTime.now(),
    );

    await _database.insertCourse(course);
    return id;
  }

  /// Update a course
  Future<void> updateCourse({
    required String id,
    String? name,
    String? code,
    String? instructor,
    String? location,
    Color? color,
    String? description,
  }) async {
    final course = CoursesCompanion(
      id: drift.Value(id),
      name: name != null ? drift.Value(name) : const drift.Value.absent(),
      code: code != null ? drift.Value(code) : const drift.Value.absent(),
      instructor: instructor != null ? drift.Value(instructor) : const drift.Value.absent(),
      location: location != null ? drift.Value(location) : const drift.Value.absent(),
      color: color != null ? drift.Value(color.value) : const drift.Value.absent(),
      description: description != null ? drift.Value(description) : const drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now()),
    );

    await _database.updateCourse(course);
  }

  /// Delete a course
  Future<void> deleteCourse(String id) async {
    await _database.deleteCourse(id);
  }

  /// Add a class session to a course
  Future<String> addClassSession({
    required String courseId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? room,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final session = ClassSessionsCompanion.insert(
      id: id,
      courseId: courseId,
      dayOfWeek: dayOfWeek,
      startHour: startTime.hour,
      startMinute: startTime.minute,
      endHour: endTime.hour,
      endMinute: endTime.minute,
      room: drift.Value(room),
      notes: drift.Value(notes),
    );

    await _database.insertClassSession(session);
    return id;
  }

  /// Delete a class session
  Future<void> deleteClassSession(String id) async {
    await _database.deleteClassSession(id);
  }
}

// Helper functions to convert database models to entities
entity.Course _courseFromDb(Course course) {
  return entity.Course(
    id: course.id,
    name: course.name,
    code: course.code,
    instructor: course.instructor,
    location: course.location,
    color: Color(course.color),
    description: course.description,
    sessions: const [], // Will be loaded separately if needed
    createdAt: course.createdAt,
    updatedAt: course.updatedAt,
  );
}

entity.ClassSession _sessionFromDb(ClassSession session) {
  return entity.ClassSession(
    id: session.id,
    courseId: session.courseId,
    dayOfWeek: session.dayOfWeek,
    startTime: TimeOfDay(hour: session.startHour, minute: session.startMinute),
    endTime: TimeOfDay(hour: session.endHour, minute: session.endMinute),
    room: session.room,
    notes: session.notes,
  );
}
