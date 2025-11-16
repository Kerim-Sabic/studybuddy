import 'dart:async';
import 'dart:math' as math;
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
        final scale = isGrowing ? 1.0 + (pulseAnimation.value * 0.05) : 1.0;
        final breathe = isGrowing ? pulseAnimation.value * 0.03 : 0.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 280,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground/soil base
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 240,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                        colors: [
                          Colors.brown[800]!.withOpacity(0.4),
                          Colors.brown[600]!.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Main tree - custom painted
                Positioned(
                  bottom: 30,
                  child: CustomPaint(
                    size: const Size(200, 250),
                    painter: TreePainter(
                      growthStage: growthStage,
                      treeType: treeType,
                      breatheAnimation: breathe,
                    ),
                  ),
                ),

                // Particle effects when growing
                if (isGrowing && growthStage != TreeGrowthStage.seed)
                  ...List.generate(5, (index) {
                    final angle = (index / 5) * math.pi * 2;
                    final distance = 80 + (pulseAnimation.value * 20);
                    return Positioned(
                      left: 140 + (distance * math.cos(angle)),
                      top: 160 + (distance * math.sin(angle)),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getTreeColor(treeType)
                              .withOpacity(1 - pulseAnimation.value),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTreeColor(TreeType type) {
    switch (type) {
      case TreeType.oak:
        return Colors.green[700]!;
      case TreeType.pine:
        return Colors.green[800]!;
      case TreeType.cherry:
        return Colors.pink[300]!;
      case TreeType.maple:
        return Colors.orange[700]!;
      case TreeType.willow:
        return Colors.green[400]!;
      case TreeType.bamboo:
        return Colors.green[600]!;
      case TreeType.sakura:
        return Colors.pink[200]!;
    }
  }
}

/// Custom painter for beautiful 2D trees with depth
class TreePainter extends CustomPainter {
  final TreeGrowthStage growthStage;
  final TreeType treeType;
  final double breatheAnimation;

  TreePainter({
    required this.growthStage,
    required this.treeType,
    required this.breatheAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height;

    switch (growthStage) {
      case TreeGrowthStage.seed:
        _paintSeed(canvas, centerX, bottomY);
        break;
      case TreeGrowthStage.sprout:
        _paintSprout(canvas, centerX, bottomY);
        break;
      case TreeGrowthStage.sapling:
        _paintSapling(canvas, centerX, bottomY, size);
        break;
      case TreeGrowthStage.tree:
        _paintTree(canvas, centerX, bottomY, size);
        break;
      case TreeGrowthStage.giant:
        _paintGiantTree(canvas, centerX, bottomY, size);
        break;
    }
  }

  void _paintSeed(Canvas canvas, double x, double y) {
    // Soil mound
    final soilPaint = Paint()
      ..color = Colors.brown[700]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y - 10), 15, soilPaint);

    // Seed
    final seedPaint = Paint()
      ..color = Colors.brown[900]!
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y - 10), width: 12, height: 16),
      seedPaint,
    );

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.brown[600]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x - 2, y - 13), 3, highlightPaint);
  }

  void _paintSprout(Canvas canvas, double x, double y) {
    // Stem
    final stemPaint = Paint()
      ..color = Colors.green[700]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(x, y);
    stemPath.quadraticBezierTo(x - 5, y - 20, x, y - 35);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves
    final leafPaint = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.fill;

    // Left leaf
    final leftLeaf = Path();
    leftLeaf.moveTo(x - 10, y - 25);
    leftLeaf.quadraticBezierTo(x - 20, y - 20, x - 15, y - 15);
    leftLeaf.quadraticBezierTo(x - 10, y - 18, x - 10, y - 25);
    canvas.drawPath(leftLeaf, leafPaint);

    // Right leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(x + 10, y - 25);
    rightLeaf.quadraticBezierTo(x + 20, y - 20, x + 15, y - 15);
    rightLeaf.quadraticBezierTo(x + 10, y - 18, x + 10, y - 25);
    canvas.drawPath(rightLeaf, leafPaint);
  }

  void _paintSapling(Canvas canvas, double x, double y, Size size) {
    // Trunk
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.brown[800]!, Colors.brown[600]!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(x - 8, y - 80, 16, 80))
      ..style = PaintingStyle.fill;

    final trunk = Path();
    trunk.moveTo(x - 8, y);
    trunk.lineTo(x - 5, y - 80);
    trunk.lineTo(x + 5, y - 80);
    trunk.lineTo(x + 8, y);
    trunk.close();
    canvas.drawPath(trunk, trunkPaint);

    // Small canopy
    _paintCanopy(canvas, x, y - 80, 50, _getTreeColor(treeType));
  }

  void _paintTree(Canvas canvas, double x, double y, Size size) {
    // Trunk with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final shadow = Path();
    shadow.moveTo(x - 12 + 4, y + 2);
    shadow.lineTo(x - 8 + 4, y - 120 + 2);
    shadow.lineTo(x + 8 + 4, y - 120 + 2);
    shadow.lineTo(x + 12 + 4, y + 2);
    shadow.close();
    canvas.drawPath(shadow, shadowPaint);

    // Main trunk
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.brown[900]!, Colors.brown[700]!, Colors.brown[600]!],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x - 12, y - 120, 24, 120))
      ..style = PaintingStyle.fill;

    final trunk = Path();
    trunk.moveTo(x - 12, y);
    trunk.lineTo(x - 8, y - 120);
    trunk.lineTo(x + 8, y - 120);
    trunk.lineTo(x + 12, y);
    trunk.close();
    canvas.drawPath(trunk, trunkPaint);

    // Trunk texture
    final texturePaint = Paint()
      ..color = Colors.brown[800]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final yPos = y - 20 - (i * 20);
      canvas.drawLine(
        Offset(x - 10, yPos),
        Offset(x - 6, yPos + 3),
        texturePaint,
      );
    }

    // Larger canopy with layers
    _paintLayeredCanopy(canvas, x, y - 120, 90, _getTreeColor(treeType));
  }

  void _paintGiantTree(Canvas canvas, double x, double y, Size size) {
    // Massive trunk with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final shadow = Path();
    shadow.moveTo(x - 18 + 6, y + 3);
    shadow.lineTo(x - 12 + 6, y - 160 + 3);
    shadow.lineTo(x + 12 + 6, y - 160 + 3);
    shadow.lineTo(x + 18 + 6, y + 3);
    shadow.close();
    canvas.drawPath(shadow, shadowPaint);

    // Trunk with gradient
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.brown[900]!,
          Colors.brown[800]!,
          Colors.brown[700]!,
          Colors.brown[600]!
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(x - 18, y - 160, 36, 160))
      ..style = PaintingStyle.fill;

    final trunk = Path();
    trunk.moveTo(x - 18, y);
    trunk.quadraticBezierTo(x - 15, y - 80, x - 12, y - 160);
    trunk.lineTo(x + 12, y - 160);
    trunk.quadraticBezierTo(x + 15, y - 80, x + 18, y);
    trunk.close();
    canvas.drawPath(trunk, trunkPaint);

    // Detailed bark texture
    final barkPaint = Paint()
      ..color = Colors.brown[800]!
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final yPos = y - 15 - (i * 20);
      canvas.drawLine(
        Offset(x - 15, yPos),
        Offset(x - 10, yPos + 4),
        barkPaint,
      );
      canvas.drawLine(
        Offset(x + 10, yPos - 5),
        Offset(x + 15, yPos - 1),
        barkPaint,
      );
    }

    // Massive multi-layered canopy
    final mainColor = _getTreeColor(treeType);

    // Background layer (darkest)
    _paintCanopy(canvas, x, y - 160, 130, mainColor.withOpacity(0.6));

    // Middle layer
    _paintCanopy(canvas, x - 20, y - 170, 100, mainColor.withOpacity(0.8));
    _paintCanopy(canvas, x + 20, y - 170, 100, mainColor.withOpacity(0.8));

    // Front layer (brightest)
    _paintCanopy(canvas, x, y - 180, 110, mainColor);

    // Add some detail leaves
    _paintDetailedLeaves(canvas, x, y - 180, mainColor);
  }

  void _paintCanopy(Canvas canvas, double x, double y, double radius, Color color) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(Offset(x + 3, y + 3), radius * 0.8, shadowPaint);

    // Main canopy with gradient
    final canopyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.7),
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

    canvas.drawCircle(Offset(x, y), radius * 0.8, canopyPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2);

    canvas.drawCircle(Offset(x - radius * 0.3, y - radius * 0.3), radius * 0.2, highlightPaint);
  }

  void _paintLayeredCanopy(Canvas canvas, double x, double y, double radius, Color color) {
    // Layer 1 (back, darker)
    _paintCanopy(canvas, x, y + 10, radius * 0.9, color.withOpacity(0.7));

    // Layer 2 (front, lighter)
    _paintCanopy(canvas, x, y, radius, color);
  }

  void _paintDetailedLeaves(Canvas canvas, double x, double y, Color color) {
    final leafPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Add individual leaf clusters
    final positions = [
      Offset(x - 40, y + 20),
      Offset(x + 40, y + 20),
      Offset(x - 30, y - 20),
      Offset(x + 30, y - 20),
      Offset(x, y + 30),
    ];

    for (final pos in positions) {
      final leaf = Path();
      leaf.moveTo(pos.dx, pos.dy);
      leaf.quadraticBezierTo(pos.dx - 8, pos.dy - 10, pos.dx - 5, pos.dy - 15);
      leaf.quadraticBezierTo(pos.dx, pos.dy - 12, pos.dx, pos.dy);
      canvas.drawPath(leaf, leafPaint);
    }
  }

  Color _getTreeColor(TreeType type) {
    switch (type) {
      case TreeType.oak:
        return Colors.green[700]!;
      case TreeType.pine:
        return Colors.green[800]!;
      case TreeType.cherry:
        return Colors.pink[300]!;
      case TreeType.maple:
        return Colors.orange[700]!;
      case TreeType.willow:
        return Colors.lightGreen[400]!;
      case TreeType.bamboo:
        return Colors.green[600]!;
      case TreeType.sakura:
        return Colors.pink[200]!;
    }
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return oldDelegate.growthStage != growthStage ||
        oldDelegate.breatheAnimation != breatheAnimation;
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
