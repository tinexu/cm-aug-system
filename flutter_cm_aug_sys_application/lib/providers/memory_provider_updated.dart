import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/memory_item.dart';

class MemoryProvider with ChangeNotifier {
  List<MemoryItem> _memories = [];
  
  MemoryProvider() {
    _initializeMemories();
  }
  
  Future<void> _initializeMemories() async {
    await _loadMemories();
  }
  
  Future<void> _loadMemories() async {
    try {
      final box = Hive.box<MemoryItem>('memories');
      _memories = box.values.toList();
      print("Loaded ${_memories.length} memories from Hive");
      notifyListeners();
    } catch (e) {
      print("Error loading memories: $e");
      _memories = [];
      notifyListeners();
    }
  }
  
  List<MemoryItem> get memories => [..._memories]; // Return a copy
  
  int get memoryCount => _memories.length;
  
  Future<void> refreshMemories() async {
    await _loadMemories();
  }
  
  Future<void> addMemory(
    String title, 
    String content, 
    List<String> tags, {
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    try {
      print("Adding new memory: $title");
      final memory = MemoryItem(
        id: Uuid().v4(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        tags: tags,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      );
      
      // Add to local list first for immediate UI update
      _memories.add(memory);
      notifyListeners();
      
      // Then add to Hive
      final box = Hive.box<MemoryItem>('memories');
      await box.add(memory);
      print("Memory added to Hive, box length: ${box.length}");
      
      // Reload from Hive to ensure consistency
      await _loadMemories();
    } catch (e) {
      print("Error adding memory: $e");
      // Reload to ensure UI matches actual storage
      await _loadMemories();
    }
  }
  
  Future<void> deleteMemory(String id) async {
    try {
      print("Deleting memory with ID: $id");
      
      // Update local list first for immediate UI update
      final localIndex = _memories.indexWhere((memory) => memory.id == id);
      if (localIndex != -1) {
        _memories.removeAt(localIndex);
        notifyListeners();
      }
      
      // Then update Hive
      final box = Hive.box<MemoryItem>('memories');
      final memoryIndex = box.values.toList().indexWhere((memory) => memory.id == id);
      
      if (memoryIndex != -1) {
        await box.deleteAt(memoryIndex);
        print("Memory deleted from Hive at index: $memoryIndex");
      } else {
        print("Memory with ID $id not found in Hive for deletion");
      }
      
      // Reload from Hive to ensure consistency
      await _loadMemories();
    } catch (e) {
      print("Error deleting memory: $e");
      // Reload to ensure UI matches actual storage
      await _loadMemories();
    }
  }
}