// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgramAdapter extends TypeAdapter<Program> {
  @override
  final int typeId = 20;

  @override
  Program read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Program(
      id: fields[0] as int,
      name: fields[1] as String,
      rounds: fields[2] as int,
      preparationDuration: fields[3] as int,
      workDuration: fields[4] as int,
      restDuration: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Program obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.rounds)
      ..writeByte(3)
      ..write(obj.preparationDuration)
      ..writeByte(4)
      ..write(obj.workDuration)
      ..writeByte(5)
      ..write(obj.restDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
