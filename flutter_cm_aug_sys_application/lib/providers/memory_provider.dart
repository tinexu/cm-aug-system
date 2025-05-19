import 'package:flutter/foundation.dart';
import '../models/memory_item.dart';
import '../repositories/memory_repository.dart';

class MemoryProvider with ChangeNotifier {
  final _repository = MemoryRepository();
  
  List<MemoryItem> _memories = [];
  
  List<MemoryItem> get memories => _memories;
  
  MemoryProvider() {
    _loadMemories();
  }
  
  void _loadMemories() {
    _memories = _repository.getAllMemories();
    // Sort by most recent first
    _memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }
  
  Future<void> addMemory(String title, String content, List<String>? tags) async {
    final memory = MemoryItem(
      title: title,
      content: content,
      tags: tags,
    );
    
    await _repository.addMemory(memory);
    _loadMemories();
  }
  
  Future<void> updateMemory(MemoryItem memory) async {
    await _repository.updateMemory(memory);
    _loadMemories();
  }
  
  Future<void> deleteMemory(String id) async {
    await _repository.deleteMemory(id);
    _loadMemories();
  }
}