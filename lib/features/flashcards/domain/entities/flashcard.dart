import 'package:equatable/equatable.dart';

/// Flashcard entity with SuperMemo 2 algorithm support
class Flashcard extends Equatable {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? frontImage;
  final String? backImage;
  final List<String> tags;

  // SuperMemo 2 (SM-2) algorithm fields
  final double easeFactor; // Default: 2.5
  final int interval; // Days until next review
  final int repetitions; // Number of successful repetitions
  final DateTime? nextReviewDate;
  final DateTime? lastReviewDate;

  // Learning state
  final CardState state;
  final int lapseCount; // Times the card was forgotten
  final DateTime createdAt;
  final DateTime updatedAt;

  // Statistics
  final int totalReviews;
  final int correctReviews;
  final double averageResponseTime; // Seconds

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.frontImage,
    this.backImage,
    this.tags = const [],
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReviewDate,
    this.lastReviewDate,
    this.state = CardState.newCard,
    this.lapseCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.totalReviews = 0,
    this.correctReviews = 0,
    this.averageResponseTime = 0.0,
  });

  /// Calculate next review using SuperMemo 2 algorithm
  Flashcard calculateNextReview(CardDifficulty difficulty) {
    double newEaseFactor = easeFactor;
    int newInterval = interval;
    int newRepetitions = repetitions;
    CardState newState = state;
    int newLapseCount = lapseCount;

    switch (difficulty) {
      case CardDifficulty.again:
        // Forgot the card - reset to learning
        newRepetitions = 0;
        newInterval = 0;
        newState = CardState.learning;
        newLapseCount = lapseCount + 1;
        newEaseFactor = _adjustEaseFactor(easeFactor, 0);
        break;

      case CardDifficulty.hard:
        // Difficult but remembered
        newEaseFactor = _adjustEaseFactor(easeFactor, 3);
        newRepetitions = repetitions + 1;

        if (newRepetitions == 1) {
          newInterval = 1; // 1 day
        } else if (newRepetitions == 2) {
          newInterval = 6; // 6 days
        } else {
          newInterval = (interval * 1.2).ceil(); // 20% increase
        }

        newState = CardState.review;
        break;

      case CardDifficulty.good:
        // Standard correct answer
        newEaseFactor = _adjustEaseFactor(easeFactor, 4);
        newRepetitions = repetitions + 1;

        if (newRepetitions == 1) {
          newInterval = 1; // 1 day
        } else if (newRepetitions == 2) {
          newInterval = 6; // 6 days
        } else {
          newInterval = (interval * easeFactor).ceil();
        }

        newState = CardState.review;
        break;

      case CardDifficulty.easy:
        // Very easy - longer interval
        newEaseFactor = _adjustEaseFactor(easeFactor, 5);
        newRepetitions = repetitions + 1;

        if (newRepetitions == 1) {
          newInterval = 4; // 4 days (skip to longer interval)
        } else if (newRepetitions == 2) {
          newInterval = 10; // 10 days
        } else {
          newInterval = (interval * easeFactor * 1.3).ceil(); // 30% bonus
        }

        newState = CardState.review;
        break;
    }

    final now = DateTime.now();
    final nextReview = now.add(Duration(days: newInterval));

    return copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      nextReviewDate: nextReview,
      lastReviewDate: now,
      state: newState,
      lapseCount: newLapseCount,
      updatedAt: now,
      totalReviews: totalReviews + 1,
      correctReviews: difficulty != CardDifficulty.again
          ? correctReviews + 1
          : correctReviews,
    );
  }

  /// Adjust ease factor based on quality (0-5)
  static double _adjustEaseFactor(double currentEF, int quality) {
    final newEF = currentEF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // Ease factor should be at least 1.3
    if (newEF < 1.3) {
      return 1.3;
    }

    return newEF;
  }

  /// Check if card is due for review
  bool get isDue {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  /// Get retention rate (percentage of correct reviews)
  double get retentionRate {
    if (totalReviews == 0) return 0.0;
    return (correctReviews / totalReviews) * 100;
  }

  /// Estimate mastery level (0-100)
  int get masteryLevel {
    if (state == CardState.newCard) return 0;
    if (state == CardState.learning) return 25;

    // Based on ease factor, interval, and retention
    final efScore = ((easeFactor - 1.3) / 1.7) * 30; // Max 30 points
    final intervalScore = (interval / 365.0) * 30; // Max 30 points (1 year interval)
    final retentionScore = retentionRate * 0.4; // Max 40 points

    return (efScore + intervalScore.clamp(0, 30) + retentionScore).clamp(0, 100).toInt();
  }

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    String? frontImage,
    String? backImage,
    List<String>? tags,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? nextReviewDate,
    DateTime? lastReviewDate,
    CardState? state,
    int? lapseCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalReviews,
    int? correctReviews,
    double? averageResponseTime,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      tags: tags ?? this.tags,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      state: state ?? this.state,
      lapseCount: lapseCount ?? this.lapseCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalReviews: totalReviews ?? this.totalReviews,
      correctReviews: correctReviews ?? this.correctReviews,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        front,
        back,
        frontImage,
        backImage,
        tags,
        easeFactor,
        interval,
        repetitions,
        nextReviewDate,
        lastReviewDate,
        state,
        lapseCount,
        createdAt,
        updatedAt,
        totalReviews,
        correctReviews,
        averageResponseTime,
      ];
}

/// Flashcard deck for organizing cards
class FlashcardDeck extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? courseId;
  final int color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Statistics
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int masteredCards;

  const FlashcardDeck({
    required this.id,
    required this.name,
    this.description,
    this.courseId,
    required this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.totalCards = 0,
    this.newCards = 0,
    this.learningCards = 0,
    this.reviewCards = 0,
    this.masteredCards = 0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        courseId,
        color,
        icon,
        createdAt,
        updatedAt,
        totalCards,
        newCards,
        learningCards,
        reviewCards,
        masteredCards,
      ];
}

/// Card learning state
enum CardState {
  newCard,    // Never reviewed
  learning,   // Currently learning (interval < 1 day)
  review,     // In review rotation (interval >= 1 day)
  mastered,   // Highly mastered (interval > 180 days)
}

/// User's difficulty rating for a card (SuperMemo 2)
enum CardDifficulty {
  again,  // Quality 0-1: Complete blackout, wrong response
  hard,   // Quality 2-3: Correct response with difficulty
  good,   // Quality 4: Correct response with hesitation
  easy,   // Quality 5: Perfect response
}

/// Study session for a flashcard deck
class StudySession extends Equatable {
  final String id;
  final String deckId;
  final DateTime startTime;
  final DateTime? endTime;
  final int cardsReviewed;
  final int cardsCorrect;
  final double averageResponseTime;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;

  const StudySession({
    required this.id,
    required this.deckId,
    required this.startTime,
    this.endTime,
    this.cardsReviewed = 0,
    this.cardsCorrect = 0,
    this.averageResponseTime = 0.0,
    this.againCount = 0,
    this.hardCount = 0,
    this.goodCount = 0,
    this.easyCount = 0,
  });

  /// Duration of the study session
  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  /// Accuracy percentage
  double get accuracy {
    if (cardsReviewed == 0) return 0.0;
    return (cardsCorrect / cardsReviewed) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        startTime,
        endTime,
        cardsReviewed,
        cardsCorrect,
        averageResponseTime,
        againCount,
        hardCount,
        goodCount,
        easyCount,
      ];
}
