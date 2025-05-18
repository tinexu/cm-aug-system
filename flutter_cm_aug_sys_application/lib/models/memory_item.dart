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
  double? latitude;
  
  @HiveField(5)
  double? longitude;
  
  @HiveField(6)
  String? locationName;
  
  @HiveField(7)
  List<String> tags;
  
  MemoryItem({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.latitude,
    this.longitude,
    this.locationName,
    List<String>? tags,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    tags = tags ?? [];
}