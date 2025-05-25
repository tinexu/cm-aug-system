import 'context_indexing.dart';
import 'context.dart'; // Your existing context detection service
import '../providers/memory_provider_updated.dart';

class MemoryService {
  static final MemoryService _instance = MemoryService._internal();
  factory MemoryService() => _instance;
  MemoryService._internal();
  
  final ContextIndex _contextIndex = ContextIndex();
  final ContextDetectionService _contextService = ContextDetectionService();
  
  // When user creates a memory with context
  Future<void> saveMemoryWithContext(
    String title,
    String content,
    List<String> tags, {
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    // Get current context from your context detection service
    final currentContext = await _contextService.getCurrentContext();
    
    // Override location data if provided (from your location selection)
    if (latitude != null && longitude != null) {
      currentContext['location'] = {
        'latitude': latitude,
        'longitude': longitude,
        'address': locationName ?? 'Custom location',
      };
    }
    
    // Add to context index with combined title + content
    final memoryContent = '$title: $content';
    _contextIndex.addMemory(memoryContent, currentContext);
    
    print('Memory saved with context: $title');
  }
  
  // When you want to surface relevant memories
  Future<List<Memory>> getRelevantMemories() async {
    final currentContext = await _contextService.getCurrentContext();
    final relevantMemories = _contextIndex.findRelevantMemories(currentContext);
    
    print('Found ${relevantMemories.length} relevant memories');
    for (final memory in relevantMemories) {
      print('Relevant memory: ${memory.content}');
    }
    
    return relevantMemories;
  }
  
  // Get all memories (for debugging or showing in UI)
  List<Memory> getAllMemories() {
    return _contextIndex.getAllMemories();
  }
  
  // Get current context (useful for debugging)
  Future<Map<String, dynamic>> getCurrentContext() async {
    return await _contextService.getCurrentContext();
  }
}