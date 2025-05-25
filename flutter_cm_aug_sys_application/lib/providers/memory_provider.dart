import 'package:flutter/foundation.dart';
import 'package:flutter_cm_aug_sys_application/features/location.dart';
import 'package:hive/hive.dart';
import '../models/memory_item.dart';
import '../repositories/memory_repository.dart';

import 'package:uuid/uuid.dart';

class MemoryProvider with ChangeNotifier {
  final _repository = MemoryRepository();
  List<MemoryItem> _memories = [];
  
  List<MemoryItem> get memories => _memories;
  
  MemoryProvider() {
    _loadMemories();
  }

  void refreshMemories() {
    // This empty method just triggers notifyListeners
    notifyListeners();
  }
  
  Future<void> _loadMemories() async {
    print('Loading memories...');
    _memories = await _repository.getAllMemories();
    print('Loaded ${_memories.length} memories');
    notifyListeners();
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
    
    final box = Hive.box<MemoryItem>('memories');
    await box.add(memory);
    
    notifyListeners();  // Make sure this line is here
  } catch (e) {
    print("Error adding memory: $e");
  }
}
  
  Future<void> updateMemory(MemoryItem memory) async {
    await _repository.updateMemory(memory);
    await _loadMemories();
  }
  
  // In your MemoryProvider class
Future<void> deleteMemory(String id) async {
  try {
    // First, update the in-memory list for immediate UI feedback
    final memoryIndex = _memories.indexWhere((memory) => memory.id == id);
    if (memoryIndex != -1) {
      _memories.removeAt(memoryIndex);
      // Notify listeners BEFORE the async operation to update UI immediately
      notifyListeners();
    }
    
    // Then perform the Hive operation
    final box = Hive.box<MemoryItem>('memories');
    final hiveIndex = box.values.toList().indexWhere((memory) => memory.id == id);
    
    if (hiveIndex != -1) {
      await box.deleteAt(hiveIndex);
      print("Memory deleted at index: $hiveIndex");
    }
  } catch (e) {
    print("Error deleting memory: $e");
    // If there was an error, reload the original data
    _loadMemories();
  }
}
  final LocationService _locationService = LocationService();

  Future<void> addMemoryWithLocation(String title, String content, List<String> tags) async {
    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();
      String? locationName;
      
      if (position != null) {
        // Convert coordinates to address
        locationName = await _locationService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        await addMemory(
          title, 
          content, 
          tags,
          latitude: position.latitude,
          longitude: position.longitude,
          locationName: locationName,
        );
      } else {
        // No location available
        await addMemory(title, content, tags);
      }
    } catch (e) {
      print('Error adding memory with location: $e');
      // Fallback to adding memory without location
      await addMemory(title, content, tags);
    }
  }
}