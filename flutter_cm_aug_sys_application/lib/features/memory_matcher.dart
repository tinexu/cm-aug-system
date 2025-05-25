import 'dart:math' as math;

class SemanticMemoryMatcher {
  
  // Extract keywords from memory content
  List<String> extractKeywords(String content) {
    // Convert to lowercase and split into words
    final words = content.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && word.length > 2)
        .toList();
    
    // Remove common stop words
    final stopWords = {
      'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 
      'her', 'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his', 
      'how', 'its', 'new', 'now', 'old', 'see', 'two', 'who', 'boy', 'did',
      'what', 'when', 'where', 'why', 'this', 'that', 'with', 'have', 'from',
      'they', 'know', 'want', 'been', 'good', 'much', 'some', 'time', 'very',
      'will', 'just', 'like', 'long', 'make', 'many', 'over', 'such', 'take',
      'than', 'them', 'well', 'were', 'here', 'come', 'could', 'would', 'should'
    };
    
    return words.where((word) => !stopWords.contains(word)).toList();
  }
  
  // Calculate semantic similarity between two pieces of content
  double calculateSemanticSimilarity(String content1, String content2) {
    final keywords1 = extractKeywords(content1).toSet();
    final keywords2 = extractKeywords(content2).toSet();
    
    if (keywords1.isEmpty || keywords2.isEmpty) return 0.0;
    
    // Jaccard similarity: intersection / union
    final intersection = keywords1.intersection(keywords2).length;
    final union = keywords1.union(keywords2).length;
    
    return intersection / union;
  }
  
  // Detect memory categories based on content
  String detectMemoryCategory(String content) {
    final keywords = extractKeywords(content);
    final contentLower = content.toLowerCase();
    
    // Work-related keywords
    if (_containsAny(keywords, ['work', 'meeting', 'project', 'code', 'coding', 
                               'client', 'deadline', 'presentation', 'office', 
                               'colleague', 'boss', 'task', 'email', 'zoom'])) {
      return 'work';
    }
    
    // Learning-related keywords
    if (_containsAny(keywords, ['learn', 'learning', 'study', 'read', 'book',
                               'course', 'tutorial', 'research', 'understand',
                               'knowledge', 'skill', 'practice'])) {
      return 'learning';
    }
    
    // Social/relationship keywords
    if (_containsAny(keywords, ['friend', 'family', 'date', 'dinner', 'party',
                               'conversation', 'fun', 'laugh', 'together',
                               'visited', 'hang', 'social'])) {
      return 'social';
    }
    
    // Creative keywords
    if (_containsAny(keywords, ['create', 'creative', 'idea', 'design', 'art',
                               'music', 'write', 'writing', 'inspiration',
                               'project', 'build', 'make'])) {
      return 'creative';
    }
    
    // Health/fitness keywords
    if (_containsAny(keywords, ['workout', 'exercise', 'run', 'running', 'gym',
                               'health', 'fitness', 'walk', 'walking', 'bike',
                               'sport', 'training'])) {
      return 'health';
    }
    
    // Food-related keywords
    if (_containsAny(keywords, ['food', 'eat', 'eating', 'restaurant', 'cook',
                               'cooking', 'recipe', 'meal', 'lunch', 'dinner',
                               'breakfast', 'taste', 'delicious'])) {
      return 'food';
    }
    
    // Travel keywords
    if (_containsAny(keywords, ['travel', 'trip', 'vacation', 'visit', 'airport',
                               'hotel', 'flight', 'explore', 'adventure',
                               'journey', 'destination'])) {
      return 'travel';
    }
    
    // Problem-solving keywords
    if (_containsAny(keywords, ['problem', 'solve', 'solution', 'fix', 'bug',
                               'issue', 'challenge', 'difficult', 'struggle',
                               'breakthrough', 'figured'])) {
      return 'problem_solving';
    }
    
    return 'general';
  }
  
  // Extract emotional tone from content
  String detectEmotionalTone(String content) {
    final contentLower = content.toLowerCase();
    
    // Positive emotions
    final positiveWords = ['happy', 'excited', 'great', 'amazing', 'awesome',
                          'love', 'wonderful', 'fantastic', 'brilliant', 'success',
                          'achieved', 'proud', 'joy', 'celebrate', 'perfect'];
    
    // Negative emotions
    final negativeWords = ['sad', 'frustrated', 'angry', 'disappointed', 'stress',
                          'worried', 'anxious', 'difficult', 'hard', 'struggle',
                          'failed', 'problem', 'issue', 'wrong', 'bad'];
    
    // Reflective/thoughtful
    final reflectiveWords = ['think', 'thinking', 'reflect', 'realize', 'understand',
                            'learn', 'insight', 'perspective', 'consider', 'wonder'];
    
    int positiveCount = _countMatches(contentLower, positiveWords);
    int negativeCount = _countMatches(contentLower, negativeWords);
    int reflectiveCount = _countMatches(contentLower, reflectiveWords);
    
    if (positiveCount > negativeCount && positiveCount > reflectiveCount) {
      return 'positive';
    } else if (negativeCount > positiveCount && negativeCount > reflectiveCount) {
      return 'negative';
    } else if (reflectiveCount > 0) {
      return 'reflective';
    }
    
    return 'neutral';
  }
  
  // Helper method to check if any keywords match
  bool _containsAny(List<String> keywords, List<String> targets) {
    return keywords.any((keyword) => targets.contains(keyword));
  }
  
  // Helper method to count word matches
  int _countMatches(String content, List<String> words) {
    int count = 0;
    for (String word in words) {
      if (content.contains(word)) count++;
    }
    return count;
  }
  
  // Enhanced memory scoring that combines context + semantic + emotional factors
  double calculateEnhancedRelevanceScore({
    required double contextSimilarity,
    required double semanticSimilarity,
    required String currentCategory,
    required String memoryCategory,
    required String currentTone,
    required String memoryTone,
    required DateTime currentTime,
    required DateTime memoryTime,
  }) {
    double score = 0.0;
    
    // Context similarity (40% weight)
    score += contextSimilarity * 0.4;
    
    // Semantic similarity (30% weight)
    score += semanticSimilarity * 0.3;
    
    // Category match (15% weight)
    if (currentCategory == memoryCategory) {
      score += 0.15;
    }
    
    // Emotional tone match (10% weight)
    if (currentTone == memoryTone) {
      score += 0.1;
    }
    
    // Recency bonus (5% weight) - more recent memories get slight boost
    final daysDiff = currentTime.difference(memoryTime).inDays;
    final recencyBonus = math.max(0, (30 - daysDiff) / 30) * 0.05;
    score += recencyBonus;
    
    return math.min(1.0, score); // Cap at 1.0
  }
}