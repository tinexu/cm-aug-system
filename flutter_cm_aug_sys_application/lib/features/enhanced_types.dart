enum MemoryType {
  note,
  codeSnippet,
  webBookmark,
  bugSolution,
  meetingNote,
  learningResource,
  projectIdea,
  taskReminder,
}

class EnhancedMemory {
  final String id;
  final String title;
  final String content;
  final MemoryType type;
  final Map<String, dynamic> context;
  final Map<String, dynamic> workContext;
  final DateTime timestamp;
  final List<String> tags;
  final Map<String, dynamic>? metadata; // Extra data based on type
  
  EnhancedMemory({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.context,
    required this.workContext,
    required this.timestamp,
    this.tags = const [],
    this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.toString(),
    'context': context,
    'workContext': workContext,
    'timestamp': timestamp.toIso8601String(),
    'tags': tags,
    'metadata': metadata,
  };
}

// Specialized memory types
class CodeSnippetMemory extends EnhancedMemory {
  CodeSnippetMemory({
    required String id,
    required String title,
    required String content,
    required Map<String, dynamic> context,
    required Map<String, dynamic> workContext,
    required DateTime timestamp,
    String? language,
    String? fileName,
    List<String> tags = const [],
  }) : super(
    id: id,
    title: title,
    content: content,
    type: MemoryType.codeSnippet,
    context: context,
    workContext: workContext,
    timestamp: timestamp,
    tags: tags,
    metadata: {
      'language': language,
      'fileName': fileName,
    },
  );
}

class WebBookmarkMemory extends EnhancedMemory {
  WebBookmarkMemory({
    required String id,
    required String title,
    required String content,
    required Map<String, dynamic> context,
    required Map<String, dynamic> workContext,
    required DateTime timestamp,
    String? url,
    String? domain,
    List<String> tags = const [],
  }) : super(
    id: id,
    title: title,
    content: content,
    type: MemoryType.webBookmark,
    context: context,
    workContext: workContext,
    timestamp: timestamp,
    tags: tags,
    metadata: {
      'url': url,
      'domain': domain,
    },
  );
}

class BugSolutionMemory extends EnhancedMemory {
  BugSolutionMemory({
    required String id,
    required String title,
    required String content,
    required Map<String, dynamic> context,
    required Map<String, dynamic> workContext,
    required DateTime timestamp,
    String? errorMessage,
    String? solution,
    String? stackTrace,
    List<String> tags = const [],
  }) : super(
    id: id,
    title: title,
    content: content,
    type: MemoryType.bugSolution,
    context: context,
    workContext: workContext,
    timestamp: timestamp,
    tags: tags,
    metadata: {
      'errorMessage': errorMessage,
      'solution': solution,
      'stackTrace': stackTrace,
    },
  );
}