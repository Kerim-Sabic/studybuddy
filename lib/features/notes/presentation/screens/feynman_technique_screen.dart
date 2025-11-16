import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';

/// Feynman Technique Screen - "Explain it like I'm 5"
/// The best way to learn is to teach
class FeynmanTechniqueScreen extends StatefulWidget {
  final String? courseId;
  final String? courseName;
  final String? initialTopic;

  const FeynmanTechniqueScreen({
    super.key,
    this.courseId,
    this.courseName,
    this.initialTopic,
  });

  @override
  State<FeynmanTechniqueScreen> createState() => _FeynmanTechniqueScreenState();
}

class _FeynmanTechniqueScreenState extends State<FeynmanTechniqueScreen> {
  int _currentStep = 0;
  late TextEditingController _topicController;
  late TextEditingController _explanationController;
  late TextEditingController _gapController;
  late TextEditingController _revisedController;
  late TextEditingController _simplifiedController;
  late TextEditingController _analogyController;

  final List<String> _identifiedGaps = [];
  bool _useAnalogy = false;
  int _understandingScore = 5;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.initialTopic ?? '');
    _explanationController = TextEditingController();
    _gapController = TextEditingController();
    _revisedController = TextEditingController();
    _simplifiedController = TextEditingController();
    _analogyController = TextEditingController();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _explanationController.dispose();
    _gapController.dispose();
    _revisedController.dispose();
    _simplifiedController.dispose();
    _analogyController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeSession();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _addGap() {
    if (_gapController.text.isNotEmpty) {
      setState(() {
        _identifiedGaps.add(_gapController.text);
        _gapController.clear();
      });
    }
  }

  void _completeSession() {
    final duration = DateTime.now().difference(_startTime!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎓 Feynman Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Topic: ${_topicController.text}'),
            Text('Duration: ${duration.inMinutes} minutes'),
            Text('Understanding: $_understandingScore/10'),
            Text('Gaps Identified: ${_identifiedGaps.length}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Great job!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'By teaching, you\'ve deepened your understanding. Studies show the Feynman Technique improves retention by 50%!',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentStep = 0;
                _explanationController.clear();
                _revisedController.clear();
                _simplifiedController.clear();
                _analogyController.clear();
                _identifiedGaps.clear();
              });
            },
            child: const Text('New Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feynman Technique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showMethodInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Stepper
          _buildStepper(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),

          // Navigation
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (index <= _currentStep) {
                    setState(() {
                      _currentStep = index;
                    });
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.blue
                        : isCompleted
                            ? Colors.green
                            : Colors.grey[300],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              if (index < 4)
                Container(
                  width: 40,
                  height: 2,
                  color: index < _currentStep ? Colors.green : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ChooseTopic();
      case 1:
        return _buildStep2InitialExplanation();
      case 2:
        return _buildStep3IdentifyGaps();
      case 3:
        return _buildStep4Simplify();
      case 4:
        return _buildStep5Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1ChooseTopic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Step 1: Choose a Topic',
          'Pick a concept you want to deeply understand',
          Icons.topic,
          Colors.blue,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _topicController,
          decoration: const InputDecoration(
            labelText: 'What concept do you want to learn?',
            hintText: 'e.g., Photosynthesis, Quantum Entanglement',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lightbulb_outline),
          ),
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        _buildTipCard(
          'Tip: Choose a specific concept',
          'Instead of "Biology", try "How do cells produce energy through mitochondria?"',
        ),
      ],
    );
  }

  Widget _buildStep2InitialExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Step 2: Explain It Simply',
          'Pretend you\'re teaching it to a child',
          Icons.record_voice_over,
          Colors.orange,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.child_care, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Explain: ${_topicController.text}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Imagine explaining this to a 5-year-old. Use simple language, no jargon!',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _explanationController,
          maxLines: 12,
          decoration: const InputDecoration(
            hintText: 'Start explaining...\n\nUse simple words.\nAvoid technical terms.\nUse examples and analogies.',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'The Feynman Test',
          'If you can\'t explain it simply, you don\'t understand it well enough.',
        ),
      ],
    );
  }

  Widget _buildStep3IdentifyGaps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Step 3: Identify Knowledge Gaps',
          'What parts couldn\'t you explain well?',
          Icons.search,
          Colors.red,
        ),
        const SizedBox(height: 24),
        const Text(
          'Review your explanation. Where did you struggle? What terms did you use without fully understanding them?',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        if (_identifiedGaps.isNotEmpty) ...[
          const Text(
            'Gaps Identified:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._identifiedGaps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[100],
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  title: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      setState(() {
                        _identifiedGaps.removeAt(entry.key);
                      });
                    },
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _gapController,
                decoration: const InputDecoration(
                  labelText: 'What don\'t you fully understand?',
                  hintText: 'e.g., How ATP is actually produced',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addGap,
              icon: const Icon(Icons.add_circle),
              iconSize: 36,
              color: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'This is the learning moment!',
          'Gaps show where you need to study more. Go back to your materials and fill these gaps.',
        ),
      ],
    );
  }

  Widget _buildStep4Simplify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Step 4: Simplify & Use Analogies',
          'Make it even simpler and more relatable',
          Icons.auto_awesome,
          Colors.purple,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _simplifiedController,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: 'Simplified Explanation',
            hintText: 'Explain it in the simplest way possible...',
            border: const OutlineInputBorder(),
            helperText: 'Use plain language. Imagine explaining to someone with zero background.',
            helperMaxLines: 2,
          ),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Use an Analogy'),
          subtitle: const Text('Analogies make concepts stick!'),
          value: _useAnalogy,
          onChanged: (value) {
            setState(() {
              _useAnalogy = value;
            });
          },
        ),
        if (_useAnalogy) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _analogyController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Your Analogy',
              hintText: 'e.g., Mitochondria is like a power plant...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lightbulb),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildTipCard(
          'Power of Analogies',
          'Relating new concepts to familiar things makes them easier to remember and understand.',
        ),
      ],
    );
  }

  Widget _buildStep5Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Step 5: Review & Self-Assess',
          'How well do you understand now?',
          Icons.rate_review,
          Colors.green,
        ),
        const SizedBox(height: 24),
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Learning Journey:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReviewItem(
                  'Topic',
                  _topicController.text,
                  Icons.topic,
                ),
                _buildReviewItem(
                  'Gaps Identified',
                  '${_identifiedGaps.length} knowledge gaps',
                  Icons.search,
                ),
                if (_useAnalogy)
                  _buildReviewItem(
                    'Analogy Used',
                    'Yes ✓',
                    Icons.lightbulb,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Rate your understanding (1-10):',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _understandingScore.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$_understandingScore',
          onChanged: (value) {
            setState(() {
              _understandingScore = value.toInt();
            });
          },
        ),
        Center(
          child: Text(
            _getUnderstandingLabel(_understandingScore),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getUnderstandingColor(_understandingScore),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_understandingScore < 7)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.refresh, color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Keep going!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'If you\'re not at 7+, go back and study the gaps you identified. Then try explaining again!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _nextStep,
              icon: Icon(_currentStep == 4 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == 4 ? 'Complete' : 'Next Step'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMethodInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎓 The Feynman Technique'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Named after physicist Richard Feynman',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              Text(
                '"If you can\'t explain it simply, you don\'t understand it well enough."',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text('How it works:'),
              SizedBox(height: 8),
              Text('1. Pick a concept'),
              Text('2. Explain it in simple terms'),
              Text('3. Identify gaps in your knowledge'),
              Text('4. Study to fill those gaps'),
              Text('5. Simplify and use analogies'),
              SizedBox(height: 16),
              Text(
                'Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Improves retention by 50%'),
              Text('• Reveals knowledge gaps'),
              Text('• Deepens understanding'),
              Text('• Makes learning active, not passive'),
              Text('• Perfect for exam preparation'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  String _getUnderstandingLabel(int score) {
    if (score >= 9) return 'Expert Level! 🌟';
    if (score >= 7) return 'Good Understanding ✅';
    if (score >= 5) return 'Getting There 📚';
    if (score >= 3) return 'Needs More Study 📖';
    return 'Just Starting 🌱';
  }

  Color _getUnderstandingColor(int score) {
    if (score >= 9) return Colors.purple;
    if (score >= 7) return Colors.green;
    if (score >= 5) return Colors.blue;
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }
}
