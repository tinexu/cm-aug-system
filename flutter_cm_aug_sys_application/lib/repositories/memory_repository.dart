import 'package:hive/hive.dart';
import '../models/memory_item.dart';

class MemoryRepository {
  Box<MemoryItem>? _box;
  
  Box<MemoryItem> get box {
    if (_box == null || !_box!.isOpen) {
      _box = Hive.box<MemoryItem>('memories');
    }
    return _box!;
  }
  
  List<MemoryItem> getAllMemories() {
    return box.values.toList();
  }
  
  Future<void> addMemory(MemoryItem memory) async {
    await box.put(memory.id, memory);
  }
  
  Future<void> updateMemory(MemoryItem memory) async {
    await box.put(memory.id, memory);
  }
  
  Future<void> deleteMemory(String id) async {
    await box.delete(id);
  }
}