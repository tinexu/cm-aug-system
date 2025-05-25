import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'memory_item.g.dart';

@HiveType(typeId: 0)
class MemoryItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  DateTime createdAt;
  
  @HiveField(4)
  List<String> tags;
  
  @HiveField(5)
  double? latitude;
  
  @HiveField(6)
  double? longitude;
  
  @HiveField(7)
  String? locationName;
  
  MemoryItem({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    List<String>? tags,
    this.latitude,
    this.longitude,
    this.locationName,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    tags = tags ?? [];
}