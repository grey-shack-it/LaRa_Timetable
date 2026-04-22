// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 0;

  @override
  Schedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Schedule(
      title: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      dayOfWeek: fields[3] as int,
      memo: fields[5] as String,
      iconName: fields[4] as String?,
      colorValue: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.dayOfWeek)
      ..writeByte(4)
      ..write(obj.iconName)
      ..writeByte(5)
      ..write(obj.memo)
      ..writeByte(6)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
