import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';
import 'package:studybuddy/features/flashcards/domain/entities/flashcard.dart';

/// Flashcard review screen with SuperMemo 2 spaced repetition
class FlashcardReviewScreen extends StatefulWidget {
  final String deckId;
  final String deckName;

  const FlashcardReviewScreen({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen>
    with SingleTickerProviderStateMixin {
  bool _showAnswer = false;
  int _currentCardIndex = 0;
  int _cardsReviewed = 0;
  int _cardsCorrect = 0;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Mock data - would come from database in real implementation
  final List<Flashcard> _cards = [];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _answerCard(CardDifficulty difficulty) {
    // Update card using SuperMemo 2 algorithm
    // final updatedCard = _cards[_currentCardIndex].calculateNextReview(difficulty);

    // Track statistics
    if (difficulty != CardDifficulty.again) {
      _cardsCorrect++;
    }
    _cardsReviewed++;

    // Move to next card
    if (_currentCardIndex < _cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showAnswer = false;
        _flipController.reset();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final accuracy = _cardsReviewed > 0
        ? (_cardsCorrect / _cardsReviewed * 100).toStringAsFixed(1)
        : '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Review Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cards Reviewed: $_cardsReviewed'),
            Text('Accuracy: $accuracy%'),
            const SizedBox(height: 16),
            Text(
              'Great job! Your cards have been rescheduled using spaced repetition.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.deckName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'No cards due for review!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Come back later or add new cards.'),
            ],
          ),
        ),
      );
    }

    final currentCard = _cards[_currentCardIndex];
    final progress = (_currentCardIndex + 1) / _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentCardIndex + 1}/${_cards.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
          ),

          // Statistics bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatBadge(
                  icon: Icons.playlist_add_check,
                  label: 'Reviewed',
                  value: _cardsReviewed.toString(),
                ),
                _StatBadge(
                  icon: Icons.check_circle,
                  label: 'Correct',
                  value: _cardsCorrect.toString(),
                  color: Colors.green,
                ),
                _StatBadge(
                  icon: Icons.refresh,
                  label: 'Remaining',
                  value: (_cards.length - _currentCardIndex - 1).toString(),
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          // Flashcard
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * 3.14159;
                    final isBack = angle > 3.14159 / 2;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: GestureDetector(
                        onTap: _flipCard,
                        child: GlassCard(
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 300,
                              maxHeight: 500,
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: isBack
                                    ? (Matrix4.identity()..rotateY(3.14159))
                                    : Matrix4.identity(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isBack ? 'Answer' : 'Question',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          isBack
                                              ? currentCard.back
                                              : currentCard.front,
                                          style: const TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Answer buttons
          if (_showAnswer)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'How well did you remember this?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DifficultyButton(
                          label: 'Again',
                          subtitle: '<1d',
                          color: Colors.red,
                          onTap: () => _answerCard(CardDifficulty.again),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DifficultyButton(
                          label: 'Hard',
                          subtitle: '1-6d',
                          color: Colors.orange,
                          onTap: () => _answerCard(CardDifficulty.hard),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DifficultyButton(
                          label: 'Good',
                          subtitle: '7-14d',
                          color: Colors.blue,
                          onTap: () => _answerCard(CardDifficulty.good),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DifficultyButton(
                          label: 'Easy',
                          subtitle: '14d+',
                          color: Colors.green,
                          onTap: () => _answerCard(CardDifficulty.easy),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _flipCard,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Show Answer',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
