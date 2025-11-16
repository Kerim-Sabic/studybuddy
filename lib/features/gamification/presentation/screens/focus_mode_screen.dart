import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';
import 'package:studybuddy/features/gamification/domain/entities/gamification.dart';

/// Focus mode screen with tree planting (Forest-style)
class FocusModeScreen extends StatefulWidget {
  final String? taskId;
  final String? taskName;

  const FocusModeScreen({
    super.key,
    this.taskId,
    this.taskName,
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  int _selectedMinutes = 25;
  TreeType _selectedTreeType = TreeType.oak;
  bool _sessionActive = false;
  Duration _remainingTime = const Duration(minutes: 25);
  TreeGrowthStage _growthStage = TreeGrowthStage.seed;
  int _distractionCount = 0;

  Timer? _timer;
  late AnimationController _growthController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _growthController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _sessionActive = true;
      _remainingTime = Duration(minutes: _selectedMinutes);
      _growthStage = TreeGrowthStage.seed;
      _distractionCount = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
          _updateGrowthStage();
        } else {
          _completeSession();
        }
      });
    });
  }

  void _updateGrowthStage() {
    final elapsed =
        Duration(minutes: _selectedMinutes) - _remainingTime;
    final progress = elapsed.inSeconds /
        Duration(minutes: _selectedMinutes).inSeconds;

    TreeGrowthStage newStage;
    if (progress < 0.2) {
      newStage = TreeGrowthStage.seed;
    } else if (progress < 0.4) {
      newStage = TreeGrowthStage.sprout;
    } else if (progress < 0.6) {
      newStage = TreeGrowthStage.sapling;
    } else if (progress < 0.8) {
      newStage = TreeGrowthStage.tree;
    } else {
      newStage = TreeGrowthStage.giant;
    }

    if (newStage != _growthStage) {
      setState(() {
        _growthStage = newStage;
      });
      _growthController.forward(from: 0);
    }
  }

  void _pauseSession() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Leaving Focus Mode'),
        content: const Text(
          'If you leave now, your tree will die! Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay Focused'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _failSession();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Give Up'),
          ),
        ],
      ),
    );
  }

  void _failSession() {
    _timer?.cancel();
    setState(() {
      _sessionActive = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🪦 Your tree died. Try again!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _sessionActive = false;
      _growthStage = TreeGrowthStage.giant;
    });

    final xpEarned = _calculateXP();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🌳',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your tree grew successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('🎯 Focus Time: ${_selectedMinutes} minutes'),
            Text('❌ Distractions: $_distractionCount'),
            Text('✨ XP Earned: +$xpEarned'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSession();
            },
            child: const Text('Another Session'),
          ),
        ],
      ),
    );
  }

  int _calculateXP() {
    final baseXP = _selectedMinutes * 10;
    final distractionPenalty = _distractionCount * 50;
    final bonus = _distractionCount == 0 ? (baseXP * 0.5).toInt() : 0;
    return (baseXP - distractionPenalty + bonus).clamp(0, double.infinity).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
        leading: _sessionActive
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _pauseSession,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (widget.taskName != null)
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.taskName!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Tree visualization
            _TreeVisualization(
              growthStage: _growthStage,
              treeType: _selectedTreeType,
              isGrowing: _sessionActive,
              pulseAnimation: _pulseController,
            ),

            const SizedBox(height: 32),

            // Timer display
            if (_sessionActive) ...[
              Text(
                _formatDuration(_remainingTime),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getGrowthMessage(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: 1 -
                    (_remainingTime.inSeconds /
                        Duration(minutes: _selectedMinutes).inSeconds),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ] else ...[
              // Duration selector
              const Text(
                'Focus Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [25, 50, 90].map((minutes) {
                  return _DurationChip(
                    minutes: minutes,
                    isSelected: _selectedMinutes == minutes,
                    onSelected: () {
                      setState(() {
                        _selectedMinutes = minutes;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Tree type selector
              const Text(
                'Choose Your Tree',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: TreeType.values.take(4).map((type) {
                  return _TreeTypeChip(
                    type: type,
                    isSelected: _selectedTreeType == type,
                    onSelected: () {
                      setState(() {
                        _selectedTreeType = type;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Start button
              ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Start Focus Session',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getGrowthMessage() {
    switch (_growthStage) {
      case TreeGrowthStage.seed:
        return 'Your seed is planted...';
      case TreeGrowthStage.sprout:
        return 'A sprout appears!';
      case TreeGrowthStage.sapling:
        return 'Growing into a sapling...';
      case TreeGrowthStage.tree:
        return 'Your tree is taking shape!';
      case TreeGrowthStage.giant:
        return 'A magnificent tree!';
    }
  }
}

class _TreeVisualization extends StatelessWidget {
  final TreeGrowthStage growthStage;
  final TreeType treeType;
  final bool isGrowing;
  final AnimationController pulseAnimation;

  const _TreeVisualization({
    required this.growthStage,
    required this.treeType,
    required this.isGrowing,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final scale = isGrowing ? 1.0 + (pulseAnimation.value * 0.1) : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                _getTreeEmoji(),
                style: TextStyle(
                  fontSize: _getTreeSize(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTreeEmoji() {
    switch (growthStage) {
      case TreeGrowthStage.seed:
        return '🌱';
      case TreeGrowthStage.sprout:
        return '🌿';
      case TreeGrowthStage.sapling:
        return '🌳';
      case TreeGrowthStage.tree:
        return '🌲';
      case TreeGrowthStage.giant:
        return '🌴';
    }
  }

  double _getTreeSize() {
    switch (growthStage) {
      case TreeGrowthStage.seed:
        return 40;
      case TreeGrowthStage.sprout:
        return 60;
      case TreeGrowthStage.sapling:
        return 80;
      case TreeGrowthStage.tree:
        return 100;
      case TreeGrowthStage.giant:
        return 120;
    }
  }
}

class _DurationChip extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onSelected;

  const _DurationChip({
    required this.minutes,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          '$minutes min',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _TreeTypeChip extends StatelessWidget {
  final TreeType type;
  final bool isSelected;
  final VoidCallback onSelected;

  const _TreeTypeChip({
    required this.type,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.2) : Colors.grey[200],
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              _getTreeIcon(type),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              _getTreeName(type),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _getTreeIcon(TreeType type) {
    switch (type) {
      case TreeType.oak:
        return '🌳';
      case TreeType.pine:
        return '🌲';
      case TreeType.cherry:
        return '🌸';
      case TreeType.maple:
        return '🍁';
      case TreeType.willow:
        return '🌿';
      case TreeType.bamboo:
        return '🎋';
      case TreeType.sakura:
        return '🌺';
    }
  }

  String _getTreeName(TreeType type) {
    switch (type) {
      case TreeType.oak:
        return 'Oak';
      case TreeType.pine:
        return 'Pine';
      case TreeType.cherry:
        return 'Cherry';
      case TreeType.maple:
        return 'Maple';
      case TreeType.willow:
        return 'Willow';
      case TreeType.bamboo:
        return 'Bamboo';
      case TreeType.sakura:
        return 'Sakura';
    }
  }
}
