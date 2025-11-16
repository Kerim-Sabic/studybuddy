import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/flashcards/domain/entities/flashcard.dart';

void main() {
  group('Flashcard SuperMemo 2 Algorithm Tests', () {
    late Flashcard testCard;

    setUp(() {
      testCard = Flashcard(
        id: 'test-1',
        deckId: 'deck-1',
        front: 'What is the capital of France?',
        back: 'Paris',
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        nextReviewDate: DateTime.now(),
        state: CardState.newCard,
        lapseCount: 0,
        totalReviews: 0,
        correctReviews: 0,
        createdAt: DateTime.now(),
      );
    });

    test('New card reviewed as "Good" should move to learning state with 1-day interval', () {
      final updatedCard = testCard.calculateNextReview(CardDifficulty.good);

      expect(updatedCard.state, CardState.review);
      expect(updatedCard.interval, 1);
      expect(updatedCard.repetitions, 1);
      expect(updatedCard.totalReviews, 1);
      expect(updatedCard.correctReviews, 1);
    });

    test('Card reviewed as "Again" should reset to learning state', () {
      // First, advance the card
      var card = testCard.calculateNextReview(CardDifficulty.good);
      card = card.calculateNextReview(CardDifficulty.good);

      // Now forget it
      final forgottenCard = card.calculateNextReview(CardDifficulty.again);

      expect(forgottenCard.state, CardState.learning);
      expect(forgottenCard.interval, 0);
      expect(forgottenCard.repetitions, 0);
      expect(forgottenCard.lapseCount, 1);
    });

    test('Card reviewed as "Easy" should have longer intervals', () {
      var card = testCard;

      // First review: Easy
      card = card.calculateNextReview(CardDifficulty.easy);
      expect(card.interval, 4); // Should skip to 4 days

      // Second review: Easy
      final interval1 = card.interval;
      card = card.calculateNextReview(CardDifficulty.easy);
      expect(card.interval, greaterThan(interval1)); // Should increase

      // Ease factor should increase
      expect(card.easeFactor, greaterThan(2.5));
    });

    test('Card reviewed as "Hard" should increase interval slower', () {
      var card = testCard;

      // First review: Hard
      card = card.calculateNextReview(CardDifficulty.hard);
      expect(card.interval, 1);

      // Second review: Hard
      card = card.calculateNextReview(CardDifficulty.hard);
      expect(card.interval, 6);

      // Third review: Hard (20% increase)
      final interval2 = card.interval;
      card = card.calculateNextReview(CardDifficulty.hard);
      expect(card.interval, (interval2 * 1.2).ceil());

      // Ease factor should be lower than default
      expect(card.easeFactor, lessThan(2.5));
    });

    test('Ease factor should never drop below 1.3', () {
      var card = testCard;

      // Review as "Again" many times to try to lower ease factor
      for (int i = 0; i < 10; i++) {
        card = card.calculateNextReview(CardDifficulty.good);
        card = card.calculateNextReview(CardDifficulty.again);
      }

      expect(card.easeFactor, greaterThanOrEqualTo(1.3));
    });

    test('Mastery level should increase with successful reviews', () {
      var card = testCard;

      expect(card.masteryLevel, 0.0);

      // Successful review
      card = card.calculateNextReview(CardDifficulty.good);

      expect(card.masteryLevel, greaterThan(0.0));

      // More successful reviews
      for (int i = 0; i < 10; i++) {
        card = card.calculateNextReview(CardDifficulty.good);
      }

      expect(card.masteryLevel, greaterThan(50.0));
    });

    test('Mastery level should cap at 100', () {
      var card = testCard;

      // Many successful reviews
      for (int i = 0; i < 50; i++) {
        card = card.calculateNextReview(CardDifficulty.easy);
      }

      expect(card.masteryLevel, lessThanOrEqualTo(100.0));
    });

    test('Card should reach mastered state after multiple successful reviews', () {
      var card = testCard;

      // Review successfully many times
      for (int i = 0; i < 10; i++) {
        card = card.calculateNextReview(CardDifficulty.good);
      }

      expect(card.state, CardState.mastered);
    });

    test('Next review date should be calculated correctly', () {
      final now = DateTime.now();
      final card = testCard.calculateNextReview(CardDifficulty.good);

      final daysDifference = card.nextReviewDate.difference(now).inDays;
      expect(daysDifference, equals(card.interval));
    });

    test('Statistics should update correctly', () {
      var card = testCard;

      // Correct review
      card = card.calculateNextReview(CardDifficulty.good);
      expect(card.totalReviews, 1);
      expect(card.correctReviews, 1);

      // Another correct review
      card = card.calculateNextReview(CardDifficulty.easy);
      expect(card.totalReviews, 2);
      expect(card.correctReviews, 2);

      // Incorrect review
      card = card.calculateNextReview(CardDifficulty.again);
      expect(card.totalReviews, 3);
      expect(card.correctReviews, 2); // Should not increase

      // Lapse count should increase
      expect(card.lapseCount, 1);
    });

    test('Due status should be calculated correctly', () {
      final now = DateTime.now();

      // Card due yesterday
      final overdueCard = testCard.copyWith(
        nextReviewDate: now.subtract(const Duration(days: 1)),
      );
      expect(overdueCard.isDue, true);

      // Card due today
      final dueTodayCard = testCard.copyWith(
        nextReviewDate: now,
      );
      expect(dueTodayCard.isDue, true);

      // Card due tomorrow
      final dueTomorrowCard = testCard.copyWith(
        nextReviewDate: now.add(const Duration(days: 1)),
      );
      expect(dueTomorrowCard.isDue, false);
    });

    test('SuperMemo 2 formula should produce exponential intervals', () {
      var card = testCard;
      final intervals = <int>[];

      // Track intervals for 10 successful "Good" reviews
      for (int i = 0; i < 10; i++) {
        card = card.calculateNextReview(CardDifficulty.good);
        intervals.add(card.interval);
      }

      // Intervals should generally increase
      for (int i = 1; i < intervals.length; i++) {
        expect(intervals[i], greaterThanOrEqualTo(intervals[i - 1]));
      }

      // Later intervals should be significantly larger
      expect(intervals.last, greaterThan(intervals.first * 5));

      print('Interval progression: $intervals');
    });
  });

  group('FlashcardDeck Statistics Tests', () {
    test('Deck statistics should calculate correctly', () {
      final now = DateTime.now();

      final deck = FlashcardDeck(
        id: 'deck-1',
        name: 'French Vocabulary',
        courseId: 'course-1',
        totalCards: 100,
        newCards: 30,
        learningCards: 20,
        reviewCards: 40,
        masteredCards: 10,
        createdAt: now,
      );

      expect(deck.totalCards, 100);
      expect(deck.newCards + deck.learningCards + deck.reviewCards + deck.masteredCards,
             100);

      // Calculate percentages
      final masteredPercentage = (deck.masteredCards / deck.totalCards) * 100;
      expect(masteredPercentage, 10.0);
    });
  });
}
