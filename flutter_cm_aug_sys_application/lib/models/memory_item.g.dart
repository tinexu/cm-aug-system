// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryItemAdapter extends TypeAdapter<MemoryItem> {
  @override
  final int typeId = 0;

  @override
  MemoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryItem(
      id: fields[0] as String?,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      latitude: fields[4] as double?,
      longitude: fields[5] as double?,
      locationName: fields[6] as String?,
      tags: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MemoryItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.locationName)
      ..writeByte(7)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
