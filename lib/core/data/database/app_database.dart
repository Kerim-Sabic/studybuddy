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

// ============================================================
// FLASHCARD & SPACED REPETITION TABLES
// ============================================================

class FlashcardDecks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get courseId => text().nullable().references(Courses, #id, onDelete: KeyAction.setNull)();
  IntColumn get totalCards => integer().withDefault(const Constant(0))();
  IntColumn get newCards => integer().withDefault(const Constant(0))();
  IntColumn get learningCards => integer().withDefault(const Constant(0))();
  IntColumn get reviewCards => integer().withDefault(const Constant(0))();
  IntColumn get masteredCards => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Flashcards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(FlashcardDecks, #id, onDelete: KeyAction.cascade)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get frontImageUrl => text().nullable()();
  TextColumn get backImageUrl => text().nullable()();
  TextColumn get hint => text().nullable()();
  TextColumn get explanation => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array

  // SuperMemo 2 (SM-2) Algorithm fields
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewDate => dateTime()();
  DateTimeColumn get lastReviewDate => dateTime().nullable()();
  TextColumn get state => text()(); // CardState enum: newCard, learning, review, mastered
  IntColumn get lapseCount => integer().withDefault(const Constant(0))();
  IntColumn get totalReviews => integer().withDefault(const Constant(0))();
  IntColumn get correctReviews => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(FlashcardDecks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get cardsReviewed => integer().withDefault(const Constant(0))();
  IntColumn get cardsCorrect => integer().withDefault(const Constant(0))();
  IntColumn get cardsAgain => integer().withDefault(const Constant(0))();
  IntColumn get cardsHard => integer().withDefault(const Constant(0))();
  IntColumn get cardsGood => integer().withDefault(const Constant(0))();
  IntColumn get cardsEasy => integer().withDefault(const Constant(0))();
  RealColumn get averageResponseTime => real().withDefault(const Constant(0.0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// NOTES & READING TABLES
// ============================================================

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get type => text()(); // NoteType enum: standard, cornell, outline, mindMap, annotation
  TextColumn get courseId => text().nullable().references(Courses, #id, onDelete: KeyAction.setNull)();
  TextColumn get assignmentId => text().nullable().references(Assignments, #id, onDelete: KeyAction.setNull)();

  // Cornell notes fields
  TextColumn get cornellCues => text().nullable()(); // JSON array
  TextColumn get cornellSummary => text().nullable()();

  // Metadata
  TextColumn get tags => text().nullable()(); // JSON array
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ReadingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get courseId => text().nullable().references(Courses, #id, onDelete: KeyAction.setNull)();
  TextColumn get method => text()(); // ReadingMethod enum: sq3r, pq4r
  TextColumn get currentStage => text()(); // ReadingStage enum
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

  // SQ3R/PQ4R stages
  TextColumn get surveyNotes => text().nullable()(); // JSON array
  TextColumn get questions => text().nullable()(); // JSON array
  TextColumn get readingNotes => text().nullable()();
  TextColumn get reciteNotes => text().nullable()();
  TextColumn get reviewNotes => text().nullable()();
  TextColumn get reflectNotes => text().nullable()(); // PQ4R only

  // Reading metrics
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  IntColumn get wordsRead => integer().withDefault(const Constant(0))();
  RealColumn get wordsPerMinute => real().withDefault(const Constant(0.0))();
  IntColumn get comprehensionScore => integer().nullable()(); // 0-100

  @override
  Set<Column> get primaryKey => {id};
}

class MindMaps extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get courseId => text().nullable().references(Courses, #id, onDelete: KeyAction.setNull)();
  TextColumn get noteId => text().nullable().references(Notes, #id, onDelete: KeyAction.setNull)();
  TextColumn get centralTopic => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MindMapNodes extends Table {
  TextColumn get id => text()();
  TextColumn get mindMapId => text().references(MindMaps, #id, onDelete: KeyAction.cascade)();
  TextColumn get parentNodeId => text().nullable()();
  TextColumn get text => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get color => integer().nullable()();
  TextColumn get icon => text().nullable()();
  RealColumn get positionX => real().withDefault(const Constant(0.0))();
  RealColumn get positionY => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class MindMapConnections extends Table {
  TextColumn get id => text()();
  TextColumn get mindMapId => text().references(MindMaps, #id, onDelete: KeyAction.cascade)();
  TextColumn get fromNodeId => text()();
  TextColumn get toNodeId => text()();
  TextColumn get label => text().nullable()();
  TextColumn get connectionType => text()(); // arrow, line, dashed

  @override
  Set<Column> get primaryKey => {id};
}

class FeynmanSessions extends Table {
  TextColumn get id => text()();
  TextColumn get topic => text()();
  TextColumn get courseId => text().nullable().references(Courses, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

  // Feynman steps
  TextColumn get initialExplanation => text().nullable()();
  TextColumn get identifiedGaps => text().nullable()(); // JSON array
  TextColumn get revisedExplanation => text().nullable()();
  TextColumn get simplifiedExplanation => text().nullable()();
  BoolColumn get useAnalogy => boolean().withDefault(const Constant(false))();
  TextColumn get analogy => text().nullable()();

  // Self-assessment
  IntColumn get understandingScore => integer().nullable()(); // 1-10
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Annotations extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()(); // AnnotationType enum: highlight, underline, comment, bookmark
  TextColumn get text => text()();
  IntColumn get color => integer().nullable()();
  TextColumn get comment => text().nullable()();
  IntColumn get startPosition => integer()();
  IntColumn get endPosition => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// GAMIFICATION TABLES
// ============================================================

class UserProfiles extends Table {
  TextColumn get userId => text()();
  IntColumn get totalXP => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  TextColumn get rank => text().withDefault(const Constant('Beginner'))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDate => dateTime().nullable()();
  TextColumn get unlockedBadges => text().nullable()(); // JSON array
  TextColumn get unlockedThemes => text().nullable()(); // JSON array
  IntColumn get streakFreezes => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

class Badges extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get icon => text()();
  TextColumn get category => text()(); // BadgeCategory enum
  TextColumn get rarity => text()(); // BadgeRarity enum: common, rare, epic, legendary
  IntColumn get xpReward => integer().withDefault(const Constant(0))();
  TextColumn get requirement => text()();
  IntColumn get requiredCount => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UnlockedBadges extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get badgeId => text().references(Badges, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get unlockedAt => dateTime()();
  IntColumn get progress => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class FocusSessions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get goalId => text().nullable().references(Goals, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get targetDurationMinutes => integer()();
  TextColumn get status => text()(); // FocusSessionStatus enum: active, paused, completed, failed

  // Tree growing
  TextColumn get treeType => text()();
  TextColumn get growthStage => text()(); // TreeGrowthStage enum: seed, sprout, sapling, tree, giant
  BoolColumn get treeGrown => boolean().withDefault(const Constant(false))();

  // Distractions
  IntColumn get distractionCount => integer().withDefault(const Constant(0))();
  TextColumn get distractionTimestamps => text().nullable()(); // JSON array

  @override
  Set<Column> get primaryKey => {id};
}

class Trees extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get focusSessionId => text().references(FocusSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get treeType => text()();
  DateTimeColumn get plantedAt => dateTime()();
  TextColumn get forestId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Forests extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get treeCount => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class XPActions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get action => text()();
  IntColumn get xpGained => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get relatedEntityType => text().nullable()();
  TextColumn get relatedEntityId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// WELL-BEING TABLES
// ============================================================

class WellbeingCheckIns extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();

  // Mental state
  IntColumn get stressLevel => integer()(); // 1-10
  IntColumn get energyLevel => integer()(); // 1-10
  IntColumn get focusLevel => integer()(); // 1-10
  IntColumn get moodScore => integer()(); // 1-10

  // Sleep
  IntColumn get hoursSlept => integer().nullable()();
  IntColumn get sleepQuality => integer().nullable()(); // 1-10

  // Study load
  IntColumn get studyHoursToday => integer().withDefault(const Constant(0))();
  IntColumn get tasksCompleted => integer().withDefault(const Constant(0))();
  BoolColumn get feltOverwhelmed => boolean().withDefault(const Constant(false))();

  // Notes
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SleepEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get bedTime => dateTime()();
  DateTimeColumn get wakeTime => dateTime()();
  IntColumn get qualityScore => integer()(); // 1-10
  TextColumn get factors => text().nullable()(); // JSON array: caffeine, stress, exercise
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BurnoutAssessments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get assessedAt => dateTime()();
  TextColumn get riskLevel => text()(); // BurnoutRiskLevel enum: low, moderate, high, critical
  RealColumn get riskScore => real()(); // 0-100

  // Contributing factors
  IntColumn get consecutiveLongDays => integer().withDefault(const Constant(0))();
  IntColumn get missedBreaks => integer().withDefault(const Constant(0))();
  IntColumn get allNighters => integer().withDefault(const Constant(0))();
  RealColumn get averageStressLevel => real().withDefault(const Constant(0.0))();
  RealColumn get averageSleepHours => real().withDefault(const Constant(0.0))();

  // Recommendations
  TextColumn get recommendations => text().nullable()(); // JSON array

  @override
  Set<Column> get primaryKey => {id};
}

class BreakReminders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get scheduledTime => dateTime()();
  TextColumn get type => text()(); // BreakType enum: pomodoro, pomodoroLong, meal, exercise, mindfulness
  IntColumn get durationMinutes => integer()();
  BoolColumn get wasTaken => boolean().withDefault(const Constant(false))();
  DateTimeColumn get actualTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BreathingExercises extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get pattern => text()(); // BreathingPattern enum: box, fourSevenEight, resonant
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get cyclesCompleted => integer().withDefault(const Constant(0))();
  IntColumn get targetCycles => integer().withDefault(const Constant(5))();

  @override
  Set<Column> get primaryKey => {id};
}

class DistractionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get appName => text()();
  IntColumn get timeSpentMinutes => integer()();
  TextColumn get category => text()(); // DistractionCategory enum: socialMedia, messaging, games, etc.

  @override
  Set<Column> get primaryKey => {id};
}

class FocusScores extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get focusMinutes => integer().withDefault(const Constant(0))();
  IntColumn get distractionMinutes => integer().withDefault(const Constant(0))();
  IntColumn get focusSessionsCount => integer().withDefault(const Constant(0))();
  IntColumn get distractionEvents => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class StudyLoadWarnings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get level => text()(); // WarningLevel enum: info, caution, warning, critical
  TextColumn get message => text()();
  IntColumn get scheduledHours => integer()();
  IntColumn get recommendedHours => integer()();
  BoolColumn get acknowledged => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  // Core tables
  Courses,
  ClassSessions,
  Assignments,
  Tasks,
  SubTasks,
  TaskCategories,
  Goals,
  Milestones,

  // Flashcard & Spaced Repetition
  FlashcardDecks,
  Flashcards,
  StudySessions,

  // Notes & Reading
  Notes,
  ReadingSessions,
  MindMaps,
  MindMapNodes,
  MindMapConnections,
  FeynmanSessions,
  Annotations,

  // Gamification
  UserProfiles,
  Badges,
  UnlockedBadges,
  FocusSessions,
  Trees,
  Forests,
  XPActions,

  // Well-being
  WellbeingCheckIns,
  SleepEntries,
  BurnoutAssessments,
  BreakReminders,
  BreathingExercises,
  DistractionLogs,
  FocusScores,
  StudyLoadWarnings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Updated from 1 to 2 for new tables

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

  // ============================================================
  // FLASHCARD & SPACED REPETITION METHODS
  // ============================================================

  // Flashcard Decks
  Future<List<FlashcardDeck>> getAllFlashcardDecks() => select(flashcardDecks).get();
  Future<FlashcardDeck?> getFlashcardDeckById(String id) =>
      (select(flashcardDecks)..where((d) => d.id.equals(id))).getSingleOrNull();
  Future<List<FlashcardDeck>> getFlashcardDecksForCourse(String courseId) =>
      (select(flashcardDecks)..where((d) => d.courseId.equals(courseId))).get();
  Future<int> insertFlashcardDeck(FlashcardDecksCompanion deck) =>
      into(flashcardDecks).insert(deck);
  Future<bool> updateFlashcardDeck(FlashcardDecksCompanion deck) =>
      update(flashcardDecks).replace(deck);
  Future<int> deleteFlashcardDeck(String id) =>
      (delete(flashcardDecks)..where((d) => d.id.equals(id))).go();

  // Flashcards
  Future<List<Flashcard>> getAllFlashcards() => select(flashcards).get();
  Future<List<Flashcard>> getFlashcardsForDeck(String deckId) =>
      (select(flashcards)..where((c) => c.deckId.equals(deckId))).get();
  Future<List<Flashcard>> getDueFlashcards(String deckId) {
    final now = DateTime.now();
    return (select(flashcards)
          ..where((c) =>
              c.deckId.equals(deckId) &
              c.nextReviewDate.isSmallerOrEqualValue(now))
          ..orderBy([(c) => OrderingTerm.asc(c.nextReviewDate)]))
        .get();
  }
  Future<List<Flashcard>> getNewFlashcards(String deckId) =>
      (select(flashcards)
            ..where((c) =>
                c.deckId.equals(deckId) & c.state.equals('newCard')))
          .get();
  Future<List<Flashcard>> getLearningFlashcards(String deckId) =>
      (select(flashcards)
            ..where((c) =>
                c.deckId.equals(deckId) & c.state.equals('learning')))
          .get();
  Future<List<Flashcard>> getMasteredFlashcards(String deckId) =>
      (select(flashcards)
            ..where((c) =>
                c.deckId.equals(deckId) & c.state.equals('mastered')))
          .get();
  Future<int> insertFlashcard(FlashcardsCompanion card) =>
      into(flashcards).insert(card);
  Future<bool> updateFlashcard(FlashcardsCompanion card) =>
      update(flashcards).replace(card);
  Future<int> deleteFlashcard(String id) =>
      (delete(flashcards)..where((c) => c.id.equals(id))).go();

  // Study Sessions
  Future<List<StudySession>> getAllStudySessions() => select(studySessions).get();
  Future<List<StudySession>> getStudySessionsForDeck(String deckId) =>
      (select(studySessions)
            ..where((s) => s.deckId.equals(deckId))
            ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
          .get();
  Future<StudySession?> getActiveStudySession(String deckId) =>
      (select(studySessions)
            ..where((s) =>
                s.deckId.equals(deckId) & s.isCompleted.equals(false)))
          .getSingleOrNull();
  Future<int> insertStudySession(StudySessionsCompanion session) =>
      into(studySessions).insert(session);
  Future<bool> updateStudySession(StudySessionsCompanion session) =>
      update(studySessions).replace(session);

  // ============================================================
  // NOTES & READING METHODS
  // ============================================================

  // Notes
  Future<List<Note>> getAllNotes() => select(notes).get();
  Future<List<Note>> getNotesForCourse(String courseId) =>
      (select(notes)..where((n) => n.courseId.equals(courseId))).get();
  Future<List<Note>> getNotesForAssignment(String assignmentId) =>
      (select(notes)..where((n) => n.assignmentId.equals(assignmentId))).get();
  Future<List<Note>> getPinnedNotes() =>
      (select(notes)..where((n) => n.isPinned.equals(true))).get();
  Future<List<Note>> getFavoriteNotes() =>
      (select(notes)..where((n) => n.isFavorite.equals(true))).get();
  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);
  Future<bool> updateNote(NotesCompanion note) => update(notes).replace(note);
  Future<int> deleteNote(String id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();

  // Reading Sessions
  Future<List<ReadingSession>> getAllReadingSessions() => select(readingSessions).get();
  Future<List<ReadingSession>> getReadingSessionsForCourse(String courseId) =>
      (select(readingSessions)..where((r) => r.courseId.equals(courseId))).get();
  Future<ReadingSession?> getActiveReadingSession() =>
      (select(readingSessions)..where((r) => r.endTime.isNull()))
          .getSingleOrNull();
  Future<int> insertReadingSession(ReadingSessionsCompanion session) =>
      into(readingSessions).insert(session);
  Future<bool> updateReadingSession(ReadingSessionsCompanion session) =>
      update(readingSessions).replace(session);
  Future<int> deleteReadingSession(String id) =>
      (delete(readingSessions)..where((r) => r.id.equals(id))).go();

  // Mind Maps
  Future<List<MindMap>> getAllMindMaps() => select(mindMaps).get();
  Future<List<MindMap>> getMindMapsForCourse(String courseId) =>
      (select(mindMaps)..where((m) => m.courseId.equals(courseId))).get();
  Future<MindMap?> getMindMapById(String id) =>
      (select(mindMaps)..where((m) => m.id.equals(id))).getSingleOrNull();
  Future<int> insertMindMap(MindMapsCompanion mindMap) =>
      into(mindMaps).insert(mindMap);
  Future<bool> updateMindMap(MindMapsCompanion mindMap) =>
      update(mindMaps).replace(mindMap);
  Future<int> deleteMindMap(String id) =>
      (delete(mindMaps)..where((m) => m.id.equals(id))).go();

  // Mind Map Nodes
  Future<List<MindMapNode>> getNodesForMindMap(String mindMapId) =>
      (select(mindMapNodes)..where((n) => n.mindMapId.equals(mindMapId))).get();
  Future<int> insertMindMapNode(MindMapNodesCompanion node) =>
      into(mindMapNodes).insert(node);
  Future<bool> updateMindMapNode(MindMapNodesCompanion node) =>
      update(mindMapNodes).replace(node);
  Future<int> deleteMindMapNode(String id) =>
      (delete(mindMapNodes)..where((n) => n.id.equals(id))).go();

  // Mind Map Connections
  Future<List<MindMapConnection>> getConnectionsForMindMap(String mindMapId) =>
      (select(mindMapConnections)..where((c) => c.mindMapId.equals(mindMapId)))
          .get();
  Future<int> insertMindMapConnection(MindMapConnectionsCompanion connection) =>
      into(mindMapConnections).insert(connection);
  Future<int> deleteMindMapConnection(String id) =>
      (delete(mindMapConnections)..where((c) => c.id.equals(id))).go();

  // Feynman Sessions
  Future<List<FeynmanSession>> getAllFeynmanSessions() =>
      select(feynmanSessions).get();
  Future<List<FeynmanSession>> getFeynmanSessionsForCourse(String courseId) =>
      (select(feynmanSessions)..where((f) => f.courseId.equals(courseId))).get();
  Future<FeynmanSession?> getActiveFeynmanSession() =>
      (select(feynmanSessions)..where((f) => f.endTime.isNull()))
          .getSingleOrNull();
  Future<int> insertFeynmanSession(FeynmanSessionsCompanion session) =>
      into(feynmanSessions).insert(session);
  Future<bool> updateFeynmanSession(FeynmanSessionsCompanion session) =>
      update(feynmanSessions).replace(session);
  Future<int> deleteFeynmanSession(String id) =>
      (delete(feynmanSessions)..where((f) => f.id.equals(id))).go();

  // Annotations
  Future<List<Annotation>> getAnnotationsForNote(String noteId) =>
      (select(annotations)..where((a) => a.noteId.equals(noteId))).get();
  Future<int> insertAnnotation(AnnotationsCompanion annotation) =>
      into(annotations).insert(annotation);
  Future<bool> updateAnnotation(AnnotationsCompanion annotation) =>
      update(annotations).replace(annotation);
  Future<int> deleteAnnotation(String id) =>
      (delete(annotations)..where((a) => a.id.equals(id))).go();

  // ============================================================
  // GAMIFICATION METHODS
  // ============================================================

  // User Profiles
  Future<UserProfile?> getUserProfile(String userId) =>
      (select(userProfiles)..where((u) => u.userId.equals(userId)))
          .getSingleOrNull();
  Future<int> insertUserProfile(UserProfilesCompanion profile) =>
      into(userProfiles).insert(profile);
  Future<bool> updateUserProfile(UserProfilesCompanion profile) =>
      update(userProfiles).replace(profile);

  // Badges
  Future<List<Badge>> getAllBadges() => select(badges).get();
  Future<Badge?> getBadgeById(String id) =>
      (select(badges)..where((b) => b.id.equals(id))).getSingleOrNull();
  Future<int> insertBadge(BadgesCompanion badge) => into(badges).insert(badge);

  // Unlocked Badges
  Future<List<UnlockedBadge>> getUnlockedBadgesForUser(String userId) =>
      (select(unlockedBadges)..where((u) => u.userId.equals(userId))).get();
  Future<int> insertUnlockedBadge(UnlockedBadgesCompanion badge) =>
      into(unlockedBadges).insert(badge);
  Future<bool> updateUnlockedBadge(UnlockedBadgesCompanion badge) =>
      update(unlockedBadges).replace(badge);

  // Focus Sessions
  Future<List<FocusSession>> getAllFocusSessions(String userId) =>
      (select(focusSessions)
            ..where((f) => f.id.isNotNull())
            ..orderBy([(f) => OrderingTerm.desc(f.startTime)]))
          .get();
  Future<FocusSession?> getActiveFocusSession() =>
      (select(focusSessions)
            ..where((f) =>
                f.status.equals('active') | f.status.equals('paused')))
          .getSingleOrNull();
  Future<int> insertFocusSession(FocusSessionsCompanion session) =>
      into(focusSessions).insert(session);
  Future<bool> updateFocusSession(FocusSessionsCompanion session) =>
      update(focusSessions).replace(session);

  // Trees
  Future<List<Tree>> getTreesForUser(String userId) =>
      (select(trees)..where((t) => t.userId.equals(userId))).get();
  Future<List<Tree>> getTreesForForest(String forestId) =>
      (select(trees)..where((t) => t.forestId.equals(forestId))).get();
  Future<int> insertTree(TreesCompanion tree) => into(trees).insert(tree);

  // Forests
  Future<List<Forest>> getForestsForUser(String userId) =>
      (select(forests)..where((f) => f.userId.equals(userId))).get();
  Future<Forest?> getDefaultForest(String userId) =>
      (select(forests)
            ..where((f) => f.userId.equals(userId) & f.isDefault.equals(true)))
          .getSingleOrNull();
  Future<int> insertForest(ForestsCompanion forest) =>
      into(forests).insert(forest);
  Future<bool> updateForest(ForestsCompanion forest) =>
      update(forests).replace(forest);

  // XP Actions
  Future<List<XPAction>> getXPActionsForUser(String userId) =>
      (select(xpActions)
            ..where((x) => x.userId.equals(userId))
            ..orderBy([(x) => OrderingTerm.desc(x.timestamp)]))
          .get();
  Future<int> insertXPAction(XPActionsCompanion action) =>
      into(xpActions).insert(action);

  // ============================================================
  // WELL-BEING METHODS
  // ============================================================

  // Wellbeing Check-ins
  Future<List<WellbeingCheckIn>> getWellbeingCheckInsForUser(String userId) =>
      (select(wellbeingCheckIns)
            ..where((w) => w.userId.equals(userId))
            ..orderBy([(w) => OrderingTerm.desc(w.date)]))
          .get();
  Future<WellbeingCheckIn?> getTodaysWellbeingCheckIn(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(wellbeingCheckIns)
          ..where((w) =>
              w.userId.equals(userId) &
              w.date.isBiggerOrEqualValue(startOfDay) &
              w.date.isSmallerThanValue(endOfDay)))
        .getSingleOrNull();
  }
  Future<int> insertWellbeingCheckIn(WellbeingCheckInsCompanion checkIn) =>
      into(wellbeingCheckIns).insert(checkIn);
  Future<bool> updateWellbeingCheckIn(WellbeingCheckInsCompanion checkIn) =>
      update(wellbeingCheckIns).replace(checkIn);

  // Sleep Entries
  Future<List<SleepEntry>> getSleepEntriesForUser(String userId) =>
      (select(sleepEntries)
            ..where((s) => s.userId.equals(userId))
            ..orderBy([(s) => OrderingTerm.desc(s.date)]))
          .get();
  Future<int> insertSleepEntry(SleepEntriesCompanion entry) =>
      into(sleepEntries).insert(entry);
  Future<bool> updateSleepEntry(SleepEntriesCompanion entry) =>
      update(sleepEntries).replace(entry);

  // Burnout Assessments
  Future<List<BurnoutAssessment>> getBurnoutAssessmentsForUser(String userId) =>
      (select(burnoutAssessments)
            ..where((b) => b.userId.equals(userId))
            ..orderBy([(b) => OrderingTerm.desc(b.assessedAt)]))
          .get();
  Future<BurnoutAssessment?> getLatestBurnoutAssessment(String userId) =>
      (select(burnoutAssessments)
            ..where((b) => b.userId.equals(userId))
            ..orderBy([(b) => OrderingTerm.desc(b.assessedAt)])
            ..limit(1))
          .getSingleOrNull();
  Future<int> insertBurnoutAssessment(BurnoutAssessmentsCompanion assessment) =>
      into(burnoutAssessments).insert(assessment);

  // Break Reminders
  Future<List<BreakReminder>> getBreakRemindersForUser(String userId) =>
      (select(breakReminders)..where((b) => b.userId.equals(userId))).get();
  Future<List<BreakReminder>> getUpcomingBreakReminders(String userId) {
    final now = DateTime.now();
    return (select(breakReminders)
          ..where((b) =>
              b.userId.equals(userId) &
              b.scheduledTime.isBiggerThanValue(now) &
              b.wasTaken.equals(false))
          ..orderBy([(b) => OrderingTerm.asc(b.scheduledTime)]))
        .get();
  }
  Future<int> insertBreakReminder(BreakRemindersCompanion reminder) =>
      into(breakReminders).insert(reminder);
  Future<bool> updateBreakReminder(BreakRemindersCompanion reminder) =>
      update(breakReminders).replace(reminder);

  // Breathing Exercises
  Future<List<BreathingExercise>> getBreathingExercisesForUser(String userId) =>
      (select(breathingExercises)
            ..where((b) => b.userId.equals(userId))
            ..orderBy([(b) => OrderingTerm.desc(b.startTime)]))
          .get();
  Future<BreathingExercise?> getActiveBreathingExercise(String userId) =>
      (select(breathingExercises)
            ..where((b) => b.userId.equals(userId) & b.endTime.isNull()))
          .getSingleOrNull();
  Future<int> insertBreathingExercise(BreathingExercisesCompanion exercise) =>
      into(breathingExercises).insert(exercise);
  Future<bool> updateBreathingExercise(BreathingExercisesCompanion exercise) =>
      update(breathingExercises).replace(exercise);

  // Distraction Logs
  Future<List<DistractionLog>> getDistractionLogsForUser(String userId) =>
      (select(distractionLogs)
            ..where((d) => d.userId.equals(userId))
            ..orderBy([(d) => OrderingTerm.desc(d.date)]))
          .get();
  Future<int> insertDistractionLog(DistractionLogsCompanion log) =>
      into(distractionLogs).insert(log);

  // Focus Scores
  Future<List<FocusScore>> getFocusScoresForUser(String userId) =>
      (select(focusScores)
            ..where((f) => f.userId.equals(userId))
            ..orderBy([(f) => OrderingTerm.desc(f.date)]))
          .get();
  Future<FocusScore?> getTodaysFocusScore(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(focusScores)
          ..where((f) =>
              f.userId.equals(userId) &
              f.date.isBiggerOrEqualValue(startOfDay) &
              f.date.isSmallerThanValue(endOfDay)))
        .getSingleOrNull();
  }
  Future<int> insertFocusScore(FocusScoresCompanion score) =>
      into(focusScores).insert(score);
  Future<bool> updateFocusScore(FocusScoresCompanion score) =>
      update(focusScores).replace(score);

  // Study Load Warnings
  Future<List<StudyLoadWarning>> getStudyLoadWarningsForUser(String userId) =>
      (select(studyLoadWarnings)
            ..where((w) => w.userId.equals(userId))
            ..orderBy([(w) => OrderingTerm.desc(w.date)]))
          .get();
  Future<List<StudyLoadWarning>> getUnacknowledgedWarnings(String userId) =>
      (select(studyLoadWarnings)
            ..where(
                (w) => w.userId.equals(userId) & w.acknowledged.equals(false)))
          .get();
  Future<int> insertStudyLoadWarning(StudyLoadWarningsCompanion warning) =>
      into(studyLoadWarnings).insert(warning);
  Future<bool> updateStudyLoadWarning(StudyLoadWarningsCompanion warning) =>
      update(studyLoadWarnings).replace(warning);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'studybuddy.db'));
    return NativeDatabase(file);
  });
}
