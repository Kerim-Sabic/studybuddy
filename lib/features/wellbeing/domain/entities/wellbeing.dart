import 'package:equatable/equatable.dart';

/// Daily wellbeing check-in
class WellbeingCheckIn extends Equatable {
  final String id;
  final String userId;
  final DateTime date;

  // Mental state
  final int stressLevel; // 1-10
  final int energyLevel; // 1-10
  final int focusLevel; // 1-10
  final int moodScore; // 1-10

  // Sleep
  final int? hoursSlept;
  final int? sleepQuality; // 1-10

  // Study load
  final int studyHoursToday;
  final int tasksCompleted;
  final bool feltOverwhelmed;

  // Notes
  final String? notes;

  const WellbeingCheckIn({
    required this.id,
    required this.userId,
    required this.date,
    required this.stressLevel,
    required this.energyLevel,
    required this.focusLevel,
    required this.moodScore,
    this.hoursSlept,
    this.sleepQuality,
    this.studyHoursToday = 0,
    this.tasksCompleted = 0,
    this.feltOverwhelmed = false,
    this.notes,
  });

  /// Calculate overall wellbeing score (0-100)
  double get overallWellbeingScore {
    final stressScore = (10 - stressLevel) * 10; // Lower stress is better
    final energyScore = energyLevel * 10;
    final focusScore = focusLevel * 10;
    final moodScoreNormalized = moodScore * 10;

    return (stressScore + energyScore + focusScore + moodScoreNormalized) / 4;
  }

  /// Check if user might be at risk of burnout
  bool get burnoutRisk {
    return stressLevel >= 8 &&
        energyLevel <= 3 &&
        (studyHoursToday >= 12 || feltOverwhelmed);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        stressLevel,
        energyLevel,
        focusLevel,
        moodScore,
        hoursSlept,
        sleepQuality,
        studyHoursToday,
        tasksCompleted,
        feltOverwhelmed,
        notes,
      ];
}

/// Sleep tracking entry
class SleepEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int qualityScore; // 1-10
  final List<String> factors; // caffeine, stress, exercise, etc.
  final String? notes;

  const SleepEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.qualityScore,
    this.factors = const [],
    this.notes,
  });

  /// Calculate sleep duration in hours
  double get hoursSlept {
    return wakeTime.difference(bedTime).inMinutes / 60.0;
  }

  /// Check if sleep was adequate (7-9 hours recommended)
  bool get adequateSleep {
    final hours = hoursSlept;
    return hours >= 7 && hours <= 9;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        bedTime,
        wakeTime,
        qualityScore,
        factors,
        notes,
      ];
}

/// Burnout risk assessment
class BurnoutAssessment extends Equatable {
  final String id;
  final String userId;
  final DateTime assessedAt;
  final BurnoutRiskLevel riskLevel;
  final double riskScore; // 0-100

  // Contributing factors
  final int consecutiveLongDays; // Days with 10+ study hours
  final int missedBreaks;
  final int allNighters;
  final double averageStressLevel; // Last 7 days
  final double averageSleepHours; // Last 7 days

  // Recommendations
  final List<String> recommendations;

  const BurnoutAssessment({
    required this.id,
    required this.userId,
    required this.assessedAt,
    required this.riskLevel,
    required this.riskScore,
    this.consecutiveLongDays = 0,
    this.missedBreaks = 0,
    this.allNighters = 0,
    this.averageStressLevel = 0.0,
    this.averageSleepHours = 0.0,
    this.recommendations = const [],
  });

  /// Generate recommendations based on risk factors
  static List<String> generateRecommendations(BurnoutAssessment assessment) {
    final recommendations = <String>[];

    if (assessment.consecutiveLongDays >= 3) {
      recommendations.add('Consider reducing study hours - you\'ve worked ${assessment.consecutiveLongDays} consecutive long days');
    }

    if (assessment.averageSleepHours < 7) {
      recommendations.add('Prioritize sleep - averaging ${assessment.averageSleepHours.toStringAsFixed(1)} hours (7-9 recommended)');
    }

    if (assessment.missedBreaks >= 5) {
      recommendations.add('Take more breaks - you\'ve missed ${assessment.missedBreaks} recommended breaks');
    }

    if (assessment.averageStressLevel >= 7) {
      recommendations.add('High stress detected - consider stress management techniques or counseling');
    }

    if (assessment.allNighters > 0) {
      recommendations.add('Avoid all-nighters - they reduce retention by 30% and increase burnout risk');
    }

    return recommendations;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        assessedAt,
        riskLevel,
        riskScore,
        consecutiveLongDays,
        missedBreaks,
        allNighters,
        averageStressLevel,
        averageSleepHours,
        recommendations,
      ];
}

/// Burnout risk levels
enum BurnoutRiskLevel {
  low,       // 0-30
  moderate,  // 31-60
  high,      // 61-80
  critical,  // 81-100
}

/// Break reminder
class BreakReminder extends Equatable {
  final String id;
  final String userId;
  final DateTime scheduledTime;
  final BreakType type;
  final int durationMinutes;
  final bool wasTaken;
  final DateTime? actualTime;

  const BreakReminder({
    required this.id,
    required this.userId,
    required this.scheduledTime,
    required this.type,
    required this.durationMinutes,
    this.wasTaken = false,
    this.actualTime,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        scheduledTime,
        type,
        durationMinutes,
        wasTaken,
        actualTime,
      ];
}

/// Break types
enum BreakType {
  pomodoro,      // 5-minute Pomodoro break
  pomodoroLong,  // 15-minute Pomodoro long break
  meal,          // Meal break
  exercise,      // Movement/exercise break
  mindfulness,   // Meditation/breathing
}

/// Breathing exercise session
class BreathingExercise extends Equatable {
  final String id;
  final String userId;
  final BreathingPattern pattern;
  final DateTime startTime;
  final DateTime? endTime;
  final int cyclesCompleted;
  final int targetCycles;

  const BreathingExercise({
    required this.id,
    required this.userId,
    required this.pattern,
    required this.startTime,
    this.endTime,
    this.cyclesCompleted = 0,
    this.targetCycles = 5,
  });

  /// Check if exercise is complete
  bool get isComplete {
    return cyclesCompleted >= targetCycles && endTime != null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        pattern,
        startTime,
        endTime,
        cyclesCompleted,
        targetCycles,
      ];
}

/// Breathing patterns for stress reduction
enum BreathingPattern {
  box,          // 4-4-4-4 (inhale-hold-exhale-hold)
  fourSevenEight, // 4-7-8 (Dr. Weil's pattern)
  resonant,     // 5-5 (resonant breathing)
}

/// Focus distraction tracking
class DistractionLog extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String appName;
  final int timeSpentMinutes;
  final DistractionCategory category;

  const DistractionLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.appName,
    required this.timeSpentMinutes,
    required this.category,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        appName,
        timeSpentMinutes,
        category,
      ];
}

/// Distraction categories
enum DistractionCategory {
  socialMedia,
  messaging,
  games,
  entertainment,
  news,
  other,
}

/// Daily focus score
class FocusScore extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final int focusMinutes;
  final int distractionMinutes;
  final int focusSessions;
  final int distractionEvents;

  const FocusScore({
    required this.id,
    required this.userId,
    required this.date,
    this.focusMinutes = 0,
    this.distractionMinutes = 0,
    this.focusSessions = 0,
    this.distractionEvents = 0,
  });

  /// Calculate focus score (0-100)
  double get score {
    final totalMinutes = focusMinutes + distractionMinutes;
    if (totalMinutes == 0) return 0;

    final focusRatio = focusMinutes / totalMinutes;
    final sessionBonus = (focusSessions / 10).clamp(0, 0.2); // Up to 20% bonus

    return ((focusRatio + sessionBonus) * 100).clamp(0, 100);
  }

  /// Focus percentage
  double get focusPercentage {
    final totalMinutes = focusMinutes + distractionMinutes;
    if (totalMinutes == 0) return 0;
    return (focusMinutes / totalMinutes) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        focusMinutes,
        distractionMinutes,
        focusSessions,
        distractionEvents,
      ];
}

/// Study load warning
class StudyLoadWarning extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final WarningLevel level;
  final String message;
  final int scheduledHours;
  final int recommendedHours;
  final bool acknowledged;

  const StudyLoadWarning({
    required this.id,
    required this.userId,
    required this.date,
    required this.level,
    required this.message,
    required this.scheduledHours,
    required this.recommendedHours,
    this.acknowledged = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        level,
        message,
        scheduledHours,
        recommendedHours,
        acknowledged,
      ];
}

/// Warning severity levels
enum WarningLevel {
  info,       // Informational
  caution,    // Approaching limits
  warning,    // Over recommended limits
  critical,   // Dangerous overload
}
