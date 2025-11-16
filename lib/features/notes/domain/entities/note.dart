import 'package:equatable/equatable.dart';

/// Note entity supporting multiple note-taking methods
class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final String? courseId;
  final String? assignmentId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Cornell Notes specific fields
  final String? cues;
  final String? summary;

  // Annotations
  final List<Annotation> annotations;

  // Mind map reference
  final String? mindMapId;

  // Images and attachments
  final List<String> imageUrls;
  final List<String> attachmentUrls;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.type = NoteType.standard,
    this.courseId,
    this.assignmentId,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.cues,
    this.summary,
    this.annotations = const [],
    this.mindMapId,
    this.imageUrls = const [],
    this.attachmentUrls = const [],
  });

  /// Check if note uses Cornell method
  bool get isCornellNote => type == NoteType.cornell && cues != null && summary != null;

  /// Word count for tracking reading progress
  int get wordCount {
    return content.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        type,
        courseId,
        assignmentId,
        tags,
        createdAt,
        updatedAt,
        cues,
        summary,
        annotations,
        mindMapId,
        imageUrls,
        attachmentUrls,
      ];
}

/// Types of notes
enum NoteType {
  standard,      // Regular notes
  cornell,       // Cornell note-taking system
  outline,       // Hierarchical outline
  mindMap,       // Mind map reference
  annotation,    // Annotated document
}

/// Annotation for highlighting and commenting
class Annotation extends Equatable {
  final String id;
  final String noteId;
  final String text;
  final String? comment;
  final AnnotationType type;
  final int startOffset;
  final int endOffset;
  final int color;
  final DateTime createdAt;

  const Annotation({
    required this.id,
    required this.noteId,
    required this.text,
    this.comment,
    this.type = AnnotationType.highlight,
    required this.startOffset,
    required this.endOffset,
    required this.color,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        noteId,
        text,
        comment,
        type,
        startOffset,
        endOffset,
        color,
        createdAt,
      ];
}

/// Annotation types
enum AnnotationType {
  highlight,   // Yellow highlight
  underline,   // Underline text
  comment,     // Comment with note
  bookmark,    // Bookmark for quick access
}

/// Reading session with SQ3R/PQ4R workflow support
class ReadingSession extends Equatable {
  final String id;
  final String title;
  final String? courseId;
  final ReadingMethod method;
  final ReadingStage currentStage;
  final DateTime startTime;
  final DateTime? endTime;

  // SQ3R/PQ4R stages
  final List<String> surveyNotes;
  final List<String> questions;
  final String? readingNotes;
  final String? reciteNotes;
  final String? reviewNotes;
  final String? reflectNotes; // PQ4R only

  // Reading metrics
  final int totalPages;
  final int pagesRead;
  final int wordsRead;
  final double wordsPerMinute;

  // Comprehension
  final int? comprehensionScore; // 0-100

  const ReadingSession({
    required this.id,
    required this.title,
    this.courseId,
    this.method = ReadingMethod.sq3r,
    this.currentStage = ReadingStage.survey,
    required this.startTime,
    this.endTime,
    this.surveyNotes = const [],
    this.questions = const [],
    this.readingNotes,
    this.reciteNotes,
    this.reviewNotes,
    this.reflectNotes,
    this.totalPages = 0,
    this.pagesRead = 0,
    this.wordsRead = 0,
    this.wordsPerMinute = 0.0,
    this.comprehensionScore,
  });

  /// Calculate reading progress percentage
  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return (pagesRead / totalPages) * 100;
  }

  /// Check if session is complete
  bool get isComplete {
    switch (method) {
      case ReadingMethod.sq3r:
        return currentStage == ReadingStage.review && endTime != null;
      case ReadingMethod.pq4r:
        return currentStage == ReadingStage.reflect && endTime != null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        courseId,
        method,
        currentStage,
        startTime,
        endTime,
        surveyNotes,
        questions,
        readingNotes,
        reciteNotes,
        reviewNotes,
        reflectNotes,
        totalPages,
        pagesRead,
        wordsRead,
        wordsPerMinute,
        comprehensionScore,
      ];
}

/// Reading methods
enum ReadingMethod {
  sq3r,   // Survey, Question, Read, Recite, Review
  pq4r,   // Preview, Question, Read, Reflect, Recite, Review
}

/// Reading stages for SQ3R/PQ4R
enum ReadingStage {
  survey,    // Survey/Preview
  question,  // Generate questions
  read,      // Active reading
  recite,    // Recite from memory
  review,    // Review and summarize
  reflect,   // Reflect (PQ4R only)
}

/// Mind map for visual learning
class MindMap extends Equatable {
  final String id;
  final String title;
  final String? courseId;
  final String centralTopic;
  final List<MindMapNode> nodes;
  final List<MindMapConnection> connections;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MindMap({
    required this.id,
    required this.title,
    this.courseId,
    required this.centralTopic,
    this.nodes = const [],
    this.connections = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        courseId,
        centralTopic,
        nodes,
        connections,
        createdAt,
        updatedAt,
      ];
}

/// Node in a mind map
class MindMapNode extends Equatable {
  final String id;
  final String mindMapId;
  final String text;
  final int level; // Distance from central topic (0 = central)
  final String? parentId;
  final int color;
  final String? imageUrl;
  final double x; // Position for layout
  final double y;

  const MindMapNode({
    required this.id,
    required this.mindMapId,
    required this.text,
    required this.level,
    this.parentId,
    required this.color,
    this.imageUrl,
    this.x = 0,
    this.y = 0,
  });

  @override
  List<Object?> get props => [
        id,
        mindMapId,
        text,
        level,
        parentId,
        color,
        imageUrl,
        x,
        y,
      ];
}

/// Connection between mind map nodes
class MindMapConnection extends Equatable {
  final String id;
  final String mindMapId;
  final String fromNodeId;
  final String toNodeId;
  final String? label;
  final int color;

  const MindMapConnection({
    required this.id,
    required this.mindMapId,
    required this.fromNodeId,
    required this.toNodeId,
    this.label,
    required this.color,
  });

  @override
  List<Object?> get props => [
        id,
        mindMapId,
        fromNodeId,
        toNodeId,
        label,
        color,
      ];
}

/// Feynman Technique explain-it-back session
class FeynmanSession extends Equatable {
  final String id;
  final String topic;
  final String? courseId;
  final DateTime startTime;
  final DateTime? endTime;

  // Feynman steps
  final String? initialExplanation;
  final List<String> identifiedGaps;
  final String? revisedExplanation;
  final String? simplifiedExplanation;
  final bool useAnalogy;
  final String? analogy;

  // Self-assessment
  final int? understandingScore; // 1-10

  const FeynmanSession({
    required this.id,
    required this.topic,
    this.courseId,
    required this.startTime,
    this.endTime,
    this.initialExplanation,
    this.identifiedGaps = const [],
    this.revisedExplanation,
    this.simplifiedExplanation,
    this.useAnalogy = false,
    this.analogy,
    this.understandingScore,
  });

  /// Check if session is complete
  bool get isComplete {
    return endTime != null &&
        initialExplanation != null &&
        simplifiedExplanation != null &&
        understandingScore != null;
  }

  @override
  List<Object?> get props => [
        id,
        topic,
        courseId,
        startTime,
        endTime,
        initialExplanation,
        identifiedGaps,
        revisedExplanation,
        simplifiedExplanation,
        useAnalogy,
        analogy,
        understandingScore,
      ];
}
