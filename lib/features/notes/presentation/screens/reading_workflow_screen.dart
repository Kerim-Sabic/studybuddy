import 'package:flutter/material.dart';
import 'package:studybuddy/core/widgets/glass_card.dart';
import 'package:studybuddy/features/notes/domain/entities/note.dart';

/// SQ3R/PQ4R Reading Comprehension Workflow Screen
/// SQ3R: Survey, Question, Read, Recite, Review
/// PQ4R: Preview, Question, Read, Reflect, Recite, Review
class ReadingWorkflowScreen extends StatefulWidget {
  final String? courseId;
  final String? courseName;
  final ReadingMethod method;

  const ReadingWorkflowScreen({
    super.key,
    this.courseId,
    this.courseName,
    this.method = ReadingMethod.sq3r,
  });

  @override
  State<ReadingWorkflowScreen> createState() => _ReadingWorkflowScreenState();
}

class _ReadingWorkflowScreenState extends State<ReadingWorkflowScreen> {
  late ReadingStage _currentStage;
  late TextEditingController _titleController;
  late TextEditingController _currentController;

  // Stage data
  final List<String> _surveyNotes = [];
  final List<String> _questions = [];
  String _readingNotes = '';
  String _reflectNotes = '';
  String _reciteNotes = '';
  String _reviewNotes = '';

  DateTime? _startTime;
  int _pagesRead = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentStage = widget.method == ReadingMethod.sq3r
        ? ReadingStage.survey
        : ReadingStage.preview;
    _titleController = TextEditingController();
    _currentController = TextEditingController();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  void _nextStage() {
    setState(() {
      // Save current stage data
      _saveCurrentStageData();

      // Move to next stage
      switch (_currentStage) {
        case ReadingStage.survey:
        case ReadingStage.preview:
          _currentStage = ReadingStage.question;
          break;
        case ReadingStage.question:
          _currentStage = ReadingStage.read;
          break;
        case ReadingStage.read:
          _currentStage = widget.method == ReadingMethod.pq4r
              ? ReadingStage.reflect
              : ReadingStage.recite;
          break;
        case ReadingStage.reflect:
          _currentStage = ReadingStage.recite;
          break;
        case ReadingStage.recite:
          _currentStage = ReadingStage.review;
          break;
        case ReadingStage.review:
          _completeReading();
          return;
      }

      _currentController.clear();
    });
  }

  void _previousStage() {
    setState(() {
      switch (_currentStage) {
        case ReadingStage.question:
          _currentStage = widget.method == ReadingMethod.sq3r
              ? ReadingStage.survey
              : ReadingStage.preview;
          break;
        case ReadingStage.read:
          _currentStage = ReadingStage.question;
          break;
        case ReadingStage.reflect:
          _currentStage = ReadingStage.read;
          break;
        case ReadingStage.recite:
          _currentStage = widget.method == ReadingMethod.pq4r
              ? ReadingStage.reflect
              : ReadingStage.read;
          break;
        case ReadingStage.review:
          _currentStage = ReadingStage.recite;
          break;
        default:
          break;
      }
    });
  }

  void _saveCurrentStageData() {
    switch (_currentStage) {
      case ReadingStage.survey:
      case ReadingStage.preview:
        if (_currentController.text.isNotEmpty) {
          _surveyNotes.add(_currentController.text);
        }
        break;
      case ReadingStage.question:
        if (_currentController.text.isNotEmpty) {
          _questions.add(_currentController.text);
        }
        break;
      case ReadingStage.read:
        _readingNotes = _currentController.text;
        break;
      case ReadingStage.reflect:
        _reflectNotes = _currentController.text;
        break;
      case ReadingStage.recite:
        _reciteNotes = _currentController.text;
        break;
      case ReadingStage.review:
        _reviewNotes = _currentController.text;
        break;
    }
  }

  void _completeReading() {
    final duration = DateTime.now().difference(_startTime!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Reading Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Method: ${widget.method == ReadingMethod.sq3r ? 'SQ3R' : 'PQ4R'}'),
            Text('Duration: ${duration.inMinutes} minutes'),
            Text('Pages Read: $_pagesRead${_totalPages > 0 ? '/$_totalPages' : ''}'),
            const SizedBox(height: 16),
            const Text(
              'Your reading session has been saved with comprehensive notes!',
              style: TextStyle(fontSize: 14),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgressValue();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.method == ReadingMethod.sq3r ? 'SQ3R Reading' : 'PQ4R Reading'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showMethodInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressBar(progress),

          // Stage Header
          _buildStageHeader(),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (first stage only)
                  if (_currentStage == ReadingStage.survey ||
                      _currentStage == ReadingStage.preview)
                    _buildTitleField(),

                  const SizedBox(height: 16),

                  // Stage Instructions
                  _buildStageInstructions(),

                  const SizedBox(height: 24),

                  // Input Area
                  _buildInputArea(),

                  const SizedBox(height: 24),

                  // Previously Collected Data
                  _buildPreviousData(),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: Colors.grey[200],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getStageName(_currentStage),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Step ${_getStageIndex() + 1} of ${_getTotalStages()}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStageHeader() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStageColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStageIcon(),
                color: _getStageColor(),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStageName(_currentStage).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getStageColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStageDescription(),
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

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Reading Title',
        hintText: 'e.g., Chapter 3: Cell Biology',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.book),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildStageInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'Instructions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDetailedInstructions(),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    switch (_currentStage) {
      case ReadingStage.survey:
      case ReadingStage.preview:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Survey Notes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._surveyNotes.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${entry.key + 1}'),
                    ),
                    title: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        setState(() {
                          _surveyNotes.removeAt(entry.key);
                        });
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            TextField(
              controller: _currentController,
              decoration: const InputDecoration(
                labelText: 'Add observation',
                hintText: 'What did you notice?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (_currentController.text.isNotEmpty) {
                  setState(() {
                    _surveyNotes.add(_currentController.text);
                    _currentController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
            ),
          ],
        );

      case ReadingStage.question:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Questions Generated:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._questions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.orange),
                    title: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        setState(() {
                          _questions.removeAt(entry.key);
                        });
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            TextField(
              controller: _currentController,
              decoration: const InputDecoration(
                labelText: 'Add question',
                hintText: 'What do I want to learn?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.question_mark),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (_currentController.text.isNotEmpty) {
                  setState(() {
                    _questions.add(_currentController.text);
                    _currentController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
          ],
        );

      default:
        return TextField(
          controller: _currentController,
          maxLines: 15,
          decoration: InputDecoration(
            hintText: _getInputHint(),
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 14, height: 1.5),
        );
    }
  }

  Widget _buildPreviousData() {
    final data = <Widget>[];

    if (_surveyNotes.isNotEmpty && _currentStage.index > ReadingStage.preview.index) {
      data.add(_buildDataSection(
        'Survey Notes',
        _surveyNotes.join('\n• '),
        Icons.visibility,
      ));
    }

    if (_questions.isNotEmpty && _currentStage.index > ReadingStage.question.index) {
      data.add(_buildDataSection(
        'Questions',
        _questions.join('\n? '),
        Icons.help_outline,
      ));
    }

    if (_readingNotes.isNotEmpty && _currentStage.index > ReadingStage.read.index) {
      data.add(_buildDataSection(
        'Reading Notes',
        _readingNotes,
        Icons.menu_book,
      ));
    }

    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Previous Stages:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...data,
      ],
    );
  }

  Widget _buildDataSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
          if (_currentStage != ReadingStage.survey &&
              _currentStage != ReadingStage.preview)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          if (_currentStage != ReadingStage.survey &&
              _currentStage != ReadingStage.preview)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _nextStage,
              icon: Icon(_currentStage == ReadingStage.review
                  ? Icons.check
                  : Icons.arrow_forward),
              label: Text(_currentStage == ReadingStage.review
                  ? 'Complete'
                  : 'Next Stage'),
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
        title: Text(widget.method == ReadingMethod.sq3r
            ? '📖 SQ3R Method'
            : '📖 PQ4R Method'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.method == ReadingMethod.sq3r) ...[
                const Text(
                  'SQ3R: Survey, Question, Read, Recite, Review',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('1. SURVEY: Scan headings and summaries'),
                const Text('2. QUESTION: Turn headings into questions'),
                const Text('3. READ: Read actively to answer questions'),
                const Text('4. RECITE: Explain in your own words'),
                const Text('5. REVIEW: Summarize key points'),
              ] else ...[
                const Text(
                  'PQ4R: Preview, Question, Read, Reflect, Recite, Review',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('1. PREVIEW: Scan the material'),
                const Text('2. QUESTION: Generate questions'),
                const Text('3. READ: Read to answer questions'),
                const Text('4. REFLECT: Connect to prior knowledge'),
                const Text('5. RECITE: Explain without looking'),
                const Text('6. REVIEW: Consolidate learning'),
              ],
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
                    Text(
                      'Benefits:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Improves comprehension by 40%'),
                    const Text('• Increases retention'),
                    const Text('• Promotes active reading'),
                    const Text('• Structures study sessions'),
                  ],
                ),
              ),
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

  // Helper methods
  double _getProgressValue() {
    return (_getStageIndex() + 1) / _getTotalStages();
  }

  int _getStageIndex() {
    final stages = _getStages();
    return stages.indexOf(_currentStage);
  }

  int _getTotalStages() {
    return _getStages().length;
  }

  List<ReadingStage> _getStages() {
    return widget.method == ReadingMethod.sq3r
        ? [
            ReadingStage.survey,
            ReadingStage.question,
            ReadingStage.read,
            ReadingStage.recite,
            ReadingStage.review,
          ]
        : [
            ReadingStage.preview,
            ReadingStage.question,
            ReadingStage.read,
            ReadingStage.reflect,
            ReadingStage.recite,
            ReadingStage.review,
          ];
  }

  String _getStageName(ReadingStage stage) {
    switch (stage) {
      case ReadingStage.survey:
        return 'Survey';
      case ReadingStage.preview:
        return 'Preview';
      case ReadingStage.question:
        return 'Question';
      case ReadingStage.read:
        return 'Read';
      case ReadingStage.reflect:
        return 'Reflect';
      case ReadingStage.recite:
        return 'Recite';
      case ReadingStage.review:
        return 'Review';
    }
  }

  String _getStageDescription() {
    switch (_currentStage) {
      case ReadingStage.survey:
      case ReadingStage.preview:
        return 'Scan the material quickly';
      case ReadingStage.question:
        return 'Generate questions to guide reading';
      case ReadingStage.read:
        return 'Read actively to answer questions';
      case ReadingStage.reflect:
        return 'Connect to what you already know';
      case ReadingStage.recite:
        return 'Explain in your own words';
      case ReadingStage.review:
        return 'Summarize and consolidate';
    }
  }

  String _getDetailedInstructions() {
    switch (_currentStage) {
      case ReadingStage.survey:
      case ReadingStage.preview:
        return '• Look at headings, subheadings, and graphics\n'
            '• Read the introduction and summary\n'
            '• Note key terms in bold\n'
            '• Get an overview of the content';
      case ReadingStage.question:
        return '• Turn headings into questions\n'
            '• Ask "Who, What, When, Where, Why, How?"\n'
            '• These questions will guide your reading\n'
            '• Aim for 3-5 key questions';
      case ReadingStage.read:
        return '• Read actively to answer your questions\n'
            '• Take notes as you read\n'
            '• Highlight important information\n'
            '• Look for answers to your questions';
      case ReadingStage.reflect:
        return '• How does this relate to what you already know?\n'
            '• Can you think of examples?\n'
            '• How might you use this information?\n'
            '• Make connections to other subjects';
      case ReadingStage.recite:
        return '• Close the book and explain the main ideas\n'
            '• Answer your questions from memory\n'
            '• Use your own words\n'
            '• Check what you missed';
      case ReadingStage.review:
        return '• Review your notes and highlights\n'
            '• Summarize the main points\n'
            '• Revisit difficult sections\n'
            '• Test yourself on key concepts';
    }
  }

  String _getInputHint() {
    switch (_currentStage) {
      case ReadingStage.read:
        return 'Take notes while reading...\n\nAnswer your questions here.';
      case ReadingStage.reflect:
        return 'How does this connect to what you know?\n\nWrite your connections...';
      case ReadingStage.recite:
        return 'Explain the main ideas in your own words...';
      case ReadingStage.review:
        return 'Summarize the key points...';
      default:
        return '';
    }
  }

  IconData _getStageIcon() {
    switch (_currentStage) {
      case ReadingStage.survey:
      case ReadingStage.preview:
        return Icons.visibility;
      case ReadingStage.question:
        return Icons.help_outline;
      case ReadingStage.read:
        return Icons.menu_book;
      case ReadingStage.reflect:
        return Icons.lightbulb_outline;
      case ReadingStage.recite:
        return Icons.record_voice_over;
      case ReadingStage.review:
        return Icons.rate_review;
    }
  }

  Color _getStageColor() {
    switch (_currentStage) {
      case ReadingStage.survey:
      case ReadingStage.preview:
        return Colors.blue;
      case ReadingStage.question:
        return Colors.orange;
      case ReadingStage.read:
        return Colors.green;
      case ReadingStage.reflect:
        return Colors.purple;
      case ReadingStage.recite:
        return Colors.teal;
      case ReadingStage.review:
        return Colors.red;
    }
  }
}
