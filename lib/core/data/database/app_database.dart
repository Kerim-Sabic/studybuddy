import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// Tables for Courses
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get instructor => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get color => integer()(); // Color value
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ClassSessions extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().references(Courses, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayOfWeek => integer()(); // 1-7
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get room => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Tables for Assignments
class Assignments extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().references(Courses, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // AssignmentType enum as string
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get priority => text()(); // Priority enum as string
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get estimatedMinutes => integer().nullable()();
  IntColumn get actualMinutes => integer().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON array
  TextColumn get tags => text().nullable()(); // JSON array
  RealColumn get grade => real().nullable()();
  RealColumn get maxGrade => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Tables for Tasks
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get priority => text()(); // Priority enum as string
  TextColumn get categoryId => text().nullable()();
  TextColumn get courseId => text().nullable().references(Courses, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get reminderTime => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get recurrence => text().nullable()(); // JSON RecurrenceRule
  TextColumn get tags => text().nullable()(); // JSON array
  IntColumn get estimatedMinutes => integer().nullable()();
  IntColumn get actualMinutes => integer().nullable()();
  TextColumn get parentTaskId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SubTasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class TaskCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Tables for Goals
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // GoalType enum as string
  TextColumn get category => text()(); // GoalCategory enum as string
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime()();
  RealColumn get targetValue => real()();
  RealColumn get currentValue => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text()();
  TextColumn get courseId => text().nullable().references(Courses, #id, onDelete: KeyAction.setNull)();
  TextColumn get tags => text().nullable()(); // JSON array
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Milestones extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().references(Goals, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  RealColumn get targetValue => real()();
  DateTimeColumn get targetDate => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Courses,
  ClassSessions,
  Assignments,
  Tasks,
  SubTasks,
  TaskCategories,
  Goals,
  Milestones,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Courses
  Future<List<Course>> getAllCourses() => select(courses).get();
  Future<Course?> getCourseById(String id) =>
      (select(courses)..where((c) => c.id.equals(id))).getSingleOrNull();
  Future<int> insertCourse(CoursesCompanion course) => into(courses).insert(course);
  Future<bool> updateCourse(CoursesCompanion course) => update(courses).replace(course);
  Future<int> deleteCourse(String id) =>
      (delete(courses)..where((c) => c.id.equals(id))).go();

  // Class Sessions
  Future<List<ClassSession>> getClassSessionsForCourse(String courseId) =>
      (select(classSessions)..where((s) => s.courseId.equals(courseId))).get();
  Future<int> insertClassSession(ClassSessionsCompanion session) =>
      into(classSessions).insert(session);
  Future<int> deleteClassSession(String id) =>
      (delete(classSessions)..where((s) => s.id.equals(id))).go();

  // Assignments
  Future<List<Assignment>> getAllAssignments() => select(assignments).get();
  Future<List<Assignment>> getAssignmentsForCourse(String courseId) =>
      (select(assignments)..where((a) => a.courseId.equals(courseId))).get();
  Future<List<Assignment>> getPendingAssignments() =>
      (select(assignments)..where((a) => a.isCompleted.equals(false))).get();
  Future<List<Assignment>> getUpcomingAssignments() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return (select(assignments)
          ..where((a) =>
              a.isCompleted.equals(false) &
              a.dueDate.isBiggerThanValue(now) &
              a.dueDate.isSmallerThanValue(weekFromNow))
          ..orderBy([(a) => OrderingTerm.asc(a.dueDate)]))
        .get();
  }
  Future<int> insertAssignment(AssignmentsCompanion assignment) =>
      into(assignments).insert(assignment);
  Future<bool> updateAssignment(AssignmentsCompanion assignment) =>
      update(assignments).replace(assignment);
  Future<int> deleteAssignment(String id) =>
      (delete(assignments)..where((a) => a.id.equals(id))).go();

  // Tasks
  Future<List<Task>> getAllTasks() => select(tasks).get();
  Future<List<Task>> getPendingTasks() =>
      (select(tasks)..where((t) => t.isCompleted.equals(false))).get();
  Future<List<Task>> getTasksForToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(tasks)
          ..where((t) =>
              t.dueDate.isBiggerOrEqualValue(startOfDay) &
              t.dueDate.isSmallerThanValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);
  Future<bool> updateTask(TasksCompanion task) => update(tasks).replace(task);
  Future<int> deleteTask(String id) => (delete(tasks)..where((t) => t.id.equals(id))).go();

  // Subtasks
  Future<List<SubTask>> getSubTasksForTask(String taskId) =>
      (select(subTasks)..where((s) => s.taskId.equals(taskId))).get();
  Future<int> insertSubTask(SubTasksCompanion subtask) => into(subTasks).insert(subtask);
  Future<bool> updateSubTask(SubTasksCompanion subtask) => update(subTasks).replace(subtask);
  Future<int> deleteSubTask(String id) =>
      (delete(subTasks)..where((s) => s.id.equals(id))).go();

  // Task Categories
  Future<List<TaskCategory>> getAllTaskCategories() => select(taskCategories).get();
  Future<int> insertTaskCategory(TaskCategoriesCompanion category) =>
      into(taskCategories).insert(category);
  Future<int> deleteTaskCategory(String id) =>
      (delete(taskCategories)..where((c) => c.id.equals(id))).go();

  // Goals
  Future<List<Goal>> getAllGoals() => select(goals).get();
  Future<List<Goal>> getActiveGoals() =>
      (select(goals)..where((g) => g.isCompleted.equals(false))).get();
  Future<Goal?> getGoalById(String id) =>
      (select(goals)..where((g) => g.id.equals(id))).getSingleOrNull();
  Future<int> insertGoal(GoalsCompanion goal) => into(goals).insert(goal);
  Future<bool> updateGoal(GoalsCompanion goal) => update(goals).replace(goal);
  Future<int> deleteGoal(String id) => (delete(goals)..where((g) => g.id.equals(id))).go();

  // Milestones
  Future<List<Milestone>> getMilestonesForGoal(String goalId) =>
      (select(milestones)..where((m) => m.goalId.equals(goalId))).get();
  Future<int> insertMilestone(MilestonesCompanion milestone) =>
      into(milestones).insert(milestone);
  Future<bool> updateMilestone(MilestonesCompanion milestone) =>
      update(milestones).replace(milestone);
  Future<int> deleteMilestone(String id) =>
      (delete(milestones)..where((m) => m.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'studybuddy.db'));
    return NativeDatabase(file);
  });
}
