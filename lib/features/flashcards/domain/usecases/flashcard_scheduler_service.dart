import 'package:studybuddy/features/flashcards/domain/entities/flashcard.dart';

/// Service for scheduling flashcard reviews using SuperMemo 2 algorithm
class FlashcardSchedulerService {
  /// Get daily review schedule for a deck
  Future<ReviewSchedule> getDailySchedule({
    required String deckId,
    required List<Flashcard> allCards,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Cards due today or overdue
    final dueCards = allCards.where((card) {
      return card.nextReviewDate.isBefore(endOfDay);
    }).toList();

    // Sort by priority: overdue first, then by next review date
    dueCards.sort((a, b) {
      final aOverdue = a.nextReviewDate.isBefore(DateTime.now());
      final bOverdue = b.nextReviewDate.isBefore(DateTime.now());

      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;

      return a.nextReviewDate.compareTo(b.nextReviewDate);
    });

    // Separate new cards
    final newCards = allCards.where((card) {
      return card.state == CardState.newCard;
    }).toList();

    // Calculate estimated study time
    final estimatedMinutes = _calculateEstimatedTime(dueCards, newCards);

    return ReviewSchedule(
      date: date,
      dueCards: dueCards,
      newCards: newCards,
      estimatedMinutes: estimatedMinutes,
      recommendedNewCardsPerDay: _getRecommendedNewCardsCount(dueCards.length),
    );
  }

  /// Calculate optimal number of new cards to introduce
  int _getRecommendedNewCardsCount(int dueCardCount) {
    // Don't introduce new cards if review load is high
    if (dueCardCount > 100) return 0;
    if (dueCardCount > 50) return 5;
    if (dueCardCount > 25) return 10;
    return 20; // Default: 20 new cards per day
  }

  /// Estimate study time in minutes
  int _calculateEstimatedTime(List<Flashcard> dueCards, List<Flashcard> newCards) {
    // Average time per card:
    // - New cards: 30 seconds (learn)
    // - Review cards: 10 seconds (quick review)
    // - Learning cards: 20 seconds (harder review)

    int totalSeconds = 0;

    for (final card in dueCards) {
      if (card.state == CardState.learning) {
        totalSeconds += 20;
      } else {
        totalSeconds += 10;
      }
    }

    // Add time for new cards (limited by recommended count)
    final newCardsToStudy = _getRecommendedNewCardsCount(dueCards.length);
    totalSeconds += newCardsToStudy * 30;

    return (totalSeconds / 60).ceil();
  }

  /// Process a card review and update using SuperMemo 2
  Flashcard processReview({
    required Flashcard card,
    required CardDifficulty difficulty,
    required int responseTimeSeconds,
  }) {
    return card.calculateNextReview(difficulty);
  }

  /// Analyze deck statistics
  DeckStatistics analyzeDeck(List<Flashcard> cards) {
    final now = DateTime.now();

    final newCount = cards.where((c) => c.state == CardState.newCard).length;
    final learningCount = cards.where((c) => c.state == CardState.learning).length;
    final reviewCount = cards.where((c) => c.state == CardState.review).length;
    final masteredCount = cards.where((c) => c.state == CardState.mastered).length;

    final dueCount = cards.where((c) => c.nextReviewDate.isBefore(now)).length;
    final overdueCount = cards.where((c) {
      final daysDue = now.difference(c.nextReviewDate).inDays;
      return daysDue > 1;
    }).length;

    // Calculate average ease factor
    final cardsWithReviews = cards.where((c) => c.totalReviews > 0);
    final avgEaseFactor = cardsWithReviews.isNotEmpty
        ? cardsWithReviews.map((c) => c.easeFactor).reduce((a, b) => a + b) /
            cardsWithReviews.length
        : 2.5;

    // Calculate retention rate
    final totalReviews = cards.fold<int>(0, (sum, c) => sum + c.totalReviews);
    final totalCorrect = cards.fold<int>(0, (sum, c) => sum + c.correctReviews);
    final retentionRate = totalReviews > 0 ? (totalCorrect / totalReviews) * 100 : 0.0;

    return DeckStatistics(
      totalCards: cards.length,
      newCards: newCount,
      learningCards: learningCount,
      reviewCards: reviewCount,
      masteredCards: masteredCount,
      dueToday: dueCount,
      overdue: overdueCount,
      averageEaseFactor: avgEaseFactor,
      retentionRate: retentionRate,
    );
  }

  /// Get forecast for upcoming reviews
  List<ForecastDay> getForecast({
    required List<Flashcard> cards,
    required int days,
  }) {
    final forecast = <ForecastDay>[];
    final today = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = today.add(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dueCards = cards.where((card) {
        return card.nextReviewDate.isAfter(startOfDay) &&
            card.nextReviewDate.isBefore(endOfDay);
      }).length;

      forecast.add(ForecastDay(
        date: date,
        reviewCount: dueCards,
      ));
    }

    return forecast;
  }

  /// Detect cards that might need attention (leeches)
  List<Flashcard> detectLeeches(List<Flashcard> cards) {
    // Leeches: cards with many lapses and low ease factor
    return cards.where((card) {
      return card.lapseCount >= 4 && card.easeFactor < 1.7;
    }).toList();
  }

  /// Suggest optimal study session length
  StudySessionRecommendation getStudyRecommendation({
    required List<Flashcard> dueCards,
    required List<Flashcard> newCards,
    required int availableMinutes,
  }) {
    final statistics = analyzeDeck([...dueCards, ...newCards]);

    // Prioritize overdue cards
    final overdueCards = dueCards.where((card) {
      final daysDue = DateTime.now().difference(card.nextReviewDate).inDays;
      return daysDue > 1;
    }).length;

    String recommendation;
    int suggestedDuration;

    if (overdueCards > 50) {
      recommendation = 'You have many overdue cards. Focus on reviewing them first.';
      suggestedDuration = 45;
    } else if (dueCards.length > 100) {
      recommendation = 'Heavy review load today. Consider splitting into multiple sessions.';
      suggestedDuration = 30;
    } else if (dueCards.length < 10) {
      recommendation = 'Light review day! Good time to learn new cards.';
      suggestedDuration = 20;
    } else {
      recommendation = 'Normal review session. Stay consistent!';
      suggestedDuration = 25;
    }

    return StudySessionRecommendation(
      recommendation: recommendation,
      suggestedDurationMinutes: suggestedDuration,
      prioritizeOverdue: overdueCards > 0,
      introduceNewCards: dueCards.length < 50,
      maxNewCards: _getRecommendedNewCardsCount(dueCards.length),
    );
  }
}

/// Daily review schedule
class ReviewSchedule {
  final DateTime date;
  final List<Flashcard> dueCards;
  final List<Flashcard> newCards;
  final int estimatedMinutes;
  final int recommendedNewCardsPerDay;

  const ReviewSchedule({
    required this.date,
    required this.dueCards,
    required this.newCards,
    required this.estimatedMinutes,
    required this.recommendedNewCardsPerDay,
  });
}

/// Deck statistics
class DeckStatistics {
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int masteredCards;
  final int dueToday;
  final int overdue;
  final double averageEaseFactor;
  final double retentionRate;

  const DeckStatistics({
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.masteredCards,
    required this.dueToday,
    required this.overdue,
    required this.averageEaseFactor,
    required this.retentionRate,
  });
}

/// Forecast for a single day
class ForecastDay {
  final DateTime date;
  final int reviewCount;

  const ForecastDay({
    required this.date,
    required this.reviewCount,
  });
}

/// Study session recommendation
class StudySessionRecommendation {
  final String recommendation;
  final int suggestedDurationMinutes;
  final bool prioritizeOverdue;
  final bool introduceNewCards;
  final int maxNewCards;

  const StudySessionRecommendation({
    required this.recommendation,
    required this.suggestedDurationMinutes,
    required this.prioritizeOverdue,
    required this.introduceNewCards,
    required this.maxNewCards,
  });
}
