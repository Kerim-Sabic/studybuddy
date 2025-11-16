import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI API Integration Service
/// Supports OpenAI and Anthropic (Claude) APIs
///
/// NOTE: Requires http package
/// Add to pubspec.yaml:
/// ```
/// http: ^1.1.0
/// ```
///
/// Environment variables needed:
/// - OPENAI_API_KEY (for OpenAI)
/// - ANTHROPIC_API_KEY (for Claude)
class AIAPIService {
  // Singleton pattern
  static final AIAPIService _instance = AIAPIService._internal();
  factory AIAPIService() => _instance;
  AIAPIService._internal();

  // API Configuration
  static const String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String anthropicEndpoint = 'https://api.anthropic.com/v1/messages';

  // Model selection
  AIProvider _provider = AIProvider.openai;
  String _openAIModel = 'gpt-4-turbo-preview';
  String _anthropicModel = 'claude-3-5-sonnet-20241022';

  // API Keys (should be loaded from secure storage)
  String? _openAIKey;
  String? _anthropicKey;

  /// Initialize with API keys
  void initialize({
    String? openAIKey,
    String? anthropicKey,
    AIProvider? preferredProvider,
  }) {
    _openAIKey = openAIKey;
    _anthropicKey = anthropicKey;

    if (preferredProvider != null) {
      _provider = preferredProvider;
    } else if (openAIKey != null) {
      _provider = AIProvider.openai;
    } else if (anthropicKey != null) {
      _provider = AIProvider.anthropic;
    }

    print('✅ AI API initialized with provider: $_provider');
  }

  /// Switch AI provider
  void setProvider(AIProvider provider) {
    _provider = provider;
  }

  /// Chat with AI (general purpose)
  Future<AIResponse> chat({
    required String message,
    List<ChatMessage>? conversationHistory,
    String? systemPrompt,
    double temperature = 0.7,
  }) async {
    try {
      switch (_provider) {
        case AIProvider.openai:
          return await _chatOpenAI(
            message: message,
            conversationHistory: conversationHistory,
            systemPrompt: systemPrompt,
            temperature: temperature,
          );

        case AIProvider.anthropic:
          return await _chatAnthropic(
            message: message,
            conversationHistory: conversationHistory,
            systemPrompt: systemPrompt,
            temperature: temperature,
          );
      }
    } catch (e) {
      return AIResponse(
        success: false,
        message: '',
        error: 'AI request failed: $e',
        provider: _provider,
      );
    }
  }

  /// Generate study recommendations
  Future<AIResponse> generateStudyRecommendations({
    required Map<String, dynamic> studentProfile,
    required List<Map<String, dynamic>> upcomingAssignments,
  }) async {
    final systemPrompt = '''
You are an expert study advisor. Analyze the student's profile and upcoming assignments
to provide personalized, actionable study recommendations.

Focus on:
- Time management strategies
- Prioritization of assignments
- Effective study techniques for each subject
- Well-being and burnout prevention
- Realistic goal setting
''';

    final userMessage = '''
Student Profile:
${_formatStudentProfile(studentProfile)}

Upcoming Assignments:
${_formatAssignments(upcomingAssignments)}

Please provide 5-7 specific, actionable study recommendations.
''';

    return await chat(
      message: userMessage,
      systemPrompt: systemPrompt,
      temperature: 0.7,
    );
  }

  /// Generate quiz from content
  Future<AIResponse> generateQuiz({
    required String content,
    required int questionCount,
    required String difficulty,
  }) async {
    final systemPrompt = '''
You are an expert quiz generator. Create high-quality, educational quiz questions
from the provided content. Format your response as JSON.
''';

    final userMessage = '''
Content:
$content

Generate $questionCount $difficulty difficulty multiple-choice questions.

Respond in this exact JSON format:
{
  "questions": [
    {
      "question": "...",
      "options": ["A", "B", "C", "D"],
      "correctAnswer": 0,
      "explanation": "..."
    }
  ]
}
''';

    return await chat(
      message: userMessage,
      systemPrompt: systemPrompt,
      temperature: 0.5,
    );
  }

  /// Explain concept (Feynman-style)
  Future<AIResponse> explainConcept({
    required String concept,
    required String simplificationLevel,
  }) async {
    final systemPrompt = '''
You are an expert teacher skilled in the Feynman Technique.
Explain complex concepts in simple, clear language using analogies and examples.
''';

    final userMessage = '''
Concept: $concept
Simplification Level: $simplificationLevel

Please explain this concept:
1. In simple, clear language
2. Using relevant analogies
3. With practical examples
4. Highlighting common misconceptions
''';

    return await chat(
      message: userMessage,
      systemPrompt: systemPrompt,
      temperature: 0.7,
    );
  }

  /// Summarize text
  Future<AIResponse> summarizeText({
    required String text,
    required int targetLength,
  }) async {
    final systemPrompt = '''
You are an expert at summarization. Create clear, concise summaries that
capture the main ideas and key points.
''';

    final userMessage = '''
Text to summarize:
$text

Create a summary in approximately $targetLength words.
Focus on main ideas, key concepts, and important details.
''';

    return await chat(
      message: userMessage,
      systemPrompt: systemPrompt,
      temperature: 0.5,
    );
  }

  /// Generate flashcards from content
  Future<AIResponse> generateFlashcards({
    required String content,
    required int cardCount,
  }) async {
    final systemPrompt = '''
You are an expert at creating effective flashcards for spaced repetition learning.
Create clear, focused flashcards that test understanding, not just memorization.
''';

    final userMessage = '''
Content:
$content

Generate $cardCount flashcards.

Respond in this exact JSON format:
{
  "flashcards": [
    {
      "front": "Question or prompt",
      "back": "Answer or explanation",
      "hint": "Optional hint"
    }
  ]
}
''';

    return await chat(
      message: userMessage,
      systemPrompt: systemPrompt,
      temperature: 0.6,
    );
  }

  /// Predict exam difficulty
  Future<AIResponse> predictExamDifficulty({
    required String courseContent,
    required String examType,
  }) async {
    final systemPrompt = '''
You are an expert academic advisor who can assess exam difficulty and
provide preparation strategies.
''';

    final userMessage = '''
Course Content:
$courseContent

Exam Type: $examType

Please analyze:
1. Likely difficulty level (1-10)
2. Key topics to focus on
3. Common question types
4. Recommended study time
5. Preparation strategies
''';

    return await chat(
      message: userMessage,
      systemPrompt: systemPrompt,
      temperature: 0.6,
    );
  }

  // ============================================================
  // PRIVATE METHODS - Provider-specific implementations
  // ============================================================

  Future<AIResponse> _chatOpenAI({
    required String message,
    List<ChatMessage>? conversationHistory,
    String? systemPrompt,
    required double temperature,
  }) async {
    if (_openAIKey == null) {
      return AIResponse(
        success: false,
        message: '',
        error: 'OpenAI API key not configured',
        provider: AIProvider.openai,
      );
    }

    final messages = <Map<String, String>>[];

    if (systemPrompt != null) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }

    if (conversationHistory != null) {
      for (final msg in conversationHistory) {
        messages.add({'role': msg.role, 'content': msg.content});
      }
    }

    messages.add({'role': 'user', 'content': message});

    final response = await http.post(
      Uri.parse(openAIEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAIKey',
      },
      body: jsonEncode({
        'model': _openAIModel,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': 2000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final usage = data['usage'];

      return AIResponse(
        success: true,
        message: content,
        provider: AIProvider.openai,
        tokensUsed: usage['total_tokens'],
        model: _openAIModel,
      );
    } else {
      return AIResponse(
        success: false,
        message: '',
        error: 'API Error: ${response.statusCode} - ${response.body}',
        provider: AIProvider.openai,
      );
    }
  }

  Future<AIResponse> _chatAnthropic({
    required String message,
    List<ChatMessage>? conversationHistory,
    String? systemPrompt,
    required double temperature,
  }) async {
    if (_anthropicKey == null) {
      return AIResponse(
        success: false,
        message: '',
        error: 'Anthropic API key not configured',
        provider: AIProvider.anthropic,
      );
    }

    final messages = <Map<String, String>>[];

    if (conversationHistory != null) {
      for (final msg in conversationHistory) {
        messages.add({'role': msg.role, 'content': msg.content});
      }
    }

    messages.add({'role': 'user', 'content': message});

    final requestBody = {
      'model': _anthropicModel,
      'messages': messages,
      'max_tokens': 2000,
      'temperature': temperature,
    };

    if (systemPrompt != null) {
      requestBody['system'] = systemPrompt;
    }

    final response = await http.post(
      Uri.parse(anthropicEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _anthropicKey!,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['content'][0]['text'];
      final usage = data['usage'];

      return AIResponse(
        success: true,
        message: content,
        provider: AIProvider.anthropic,
        tokensUsed: usage['input_tokens'] + usage['output_tokens'],
        model: _anthropicModel,
      );
    } else {
      return AIResponse(
        success: false,
        message: '',
        error: 'API Error: ${response.statusCode} - ${response.body}',
        provider: AIProvider.anthropic,
      );
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  String _formatStudentProfile(Map<String, dynamic> profile) {
    final buffer = StringBuffer();
    profile.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }

  String _formatAssignments(List<Map<String, dynamic>> assignments) {
    final buffer = StringBuffer();
    for (int i = 0; i < assignments.length; i++) {
      final assignment = assignments[i];
      buffer.writeln('${i + 1}. ${assignment['title']}');
      buffer.writeln('   Due: ${assignment['dueDate']}');
      buffer.writeln('   Course: ${assignment['course']}');
      buffer.writeln('   Estimated Time: ${assignment['estimatedMinutes']} min');
      buffer.writeln('');
    }
    return buffer.toString();
  }

  /// Test API connection
  Future<bool> testConnection() async {
    final response = await chat(
      message: 'Hello! Please respond with a simple greeting.',
      temperature: 0.1,
    );

    return response.success;
  }

  /// Get available models for current provider
  List<String> getAvailableModels() {
    switch (_provider) {
      case AIProvider.openai:
        return [
          'gpt-4-turbo-preview',
          'gpt-4',
          'gpt-3.5-turbo',
        ];
      case AIProvider.anthropic:
        return [
          'claude-3-5-sonnet-20241022',
          'claude-3-opus-20240229',
          'claude-3-sonnet-20240229',
          'claude-3-haiku-20240307',
        ];
    }
  }

  /// Set custom model
  void setModel(String model) {
    switch (_provider) {
      case AIProvider.openai:
        _openAIModel = model;
        break;
      case AIProvider.anthropic:
        _anthropicModel = model;
        break;
    }
  }
}

/// AI Provider enum
enum AIProvider {
  openai,
  anthropic,
}

/// Chat message for conversation history
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });
}

/// AI Response
class AIResponse {
  final bool success;
  final String message;
  final String? error;
  final AIProvider provider;
  final int? tokensUsed;
  final String? model;

  AIResponse({
    required this.success,
    required this.message,
    this.error,
    required this.provider,
    this.tokensUsed,
    this.model,
  });

  /// Parse JSON response (for structured responses)
  Map<String, dynamic>? parseJSON() {
    try {
      // Try to extract JSON from markdown code blocks
      final jsonMatch = RegExp(r'```json\n(.*?)\n```', dotAll: true)
          .firstMatch(message);

      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(1)!);
      }

      // Try direct JSON parse
      return jsonDecode(message);
    } catch (e) {
      print('Failed to parse JSON response: $e');
      return null;
    }
  }
}
