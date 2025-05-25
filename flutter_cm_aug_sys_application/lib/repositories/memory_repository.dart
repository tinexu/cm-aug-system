import 'package:hive/hive.dart';
import '../models/memory_item.dart';

class MemoryRepository {
  Box<MemoryItem>? _box;
  
  // Get the box or open it if it's not open yet
  Future<Box<MemoryItem>> get box async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<MemoryItem>('memories');
    }
    return _box!;
  }
  
  // Get all memories
  Future<List<MemoryItem>> getAllMemories() async {
    final memoryBox = await box;
    return memoryBox.values.toList();
  }
  
  // Add a memory
  Future<void> addMemory(MemoryItem memory) async {
    final memoryBox = await box;
    await memoryBox.put(memory.id, memory);
    print('Memory saved to box: ${memory.title}');
    print('Box now contains ${memoryBox.length} items');
  }
  
  // Update a memory
  Future<void> updateMemory(MemoryItem memory) async {
    final memoryBox = await box;
    await memoryBox.put(memory.id, memory);
  }
  
  // Delete a memory
  Future<void> deleteMemory(String id) async {
    final memoryBox = await box;
    await memoryBox.delete(id);
  }
}