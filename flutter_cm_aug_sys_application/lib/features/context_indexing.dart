import 'dart:math' as math;

class Memory {
  final String id;
  final String content;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  
  Memory({
    required this.id,
    required this.content,
    required this.context,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'context': context,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ContextIndex {
  final List<Memory> _memories = [];
  
  // Add a memory with its context
  void addMemory(String content, Map<String, dynamic> context) {
    final memory = Memory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      context: context,
      timestamp: DateTime.now(),
    );
    _memories.add(memory);
  }
  
  // Find memories that match current context
  List<Memory> findRelevantMemories(Map<String, dynamic> currentContext) {
    final relevantMemories = <Memory>[];
    
    for (final memory in _memories) {
      final score = _calculateContextSimilarity(memory.context, currentContext);
      if (score > 0.3) { // Threshold for relevance
        relevantMemories.add(memory);
      }
    }
    
    // Sort by relevance (you could also factor in recency here)
    relevantMemories.sort((a, b) {
      final scoreA = _calculateContextSimilarity(a.context, currentContext);
      final scoreB = _calculateContextSimilarity(b.context, currentContext);
      return scoreB.compareTo(scoreA);
    });
    
    return relevantMemories.take(5).toList(); // Return top 5
  }
  
  // Calculate how similar two contexts are (0.0 to 1.0)
  double _calculateContextSimilarity(Map<String, dynamic> context1, Map<String, dynamic> context2) {
    double totalWeight = 0.0;
    double matchingWeight = 0.0;
    
    // Location similarity (weight: 0.4)
    if (context1['location'] != null && context2['location'] != null) {
      totalWeight += 0.4;
      final distance = _calculateDistance(
        context1['location']['latitude'],
        context1['location']['longitude'],
        context2['location']['latitude'],
        context2['location']['longitude'],
      );
      // If within 1km, consider it a match
      if (distance < 1000) {
        matchingWeight += 0.4;
      }
    }
    
    // Activity similarity (weight: 0.3)
    if (context1['activity'] != null && context2['activity'] != null) {
      totalWeight += 0.3;
      if (context1['activity'] == context2['activity']) {
        matchingWeight += 0.3;
      }
    }
    
    // Time context similarity (weight: 0.3)
    if (context1['timeContext'] != null && context2['timeContext'] != null) {
      totalWeight += 0.3;
      double timeScore = 0.0;
      
      // Same work hours status
      if (context1['timeContext']['isWorkHours'] == context2['timeContext']['isWorkHours']) {
        timeScore += 0.5;
      }
      
      // Same weekend status
      if (context1['timeContext']['isWeekend'] == context2['timeContext']['isWeekend']) {
        timeScore += 0.5;
      }
      
      matchingWeight += 0.3 * timeScore;
    }
    
    return totalWeight > 0 ? matchingWeight / totalWeight : 0.0;
  }
  
  // Calculate distance between two points in meters
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  // Get all memories (for debugging)
  List<Memory> getAllMemories() => List.from(_memories);
}