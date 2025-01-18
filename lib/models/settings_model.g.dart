// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      soundEnabled: fields[0] as bool,
      notificationsEnabled: fields[1] as bool,
      voicePromptsEnabled: fields[2] as bool,
      startBellEnabled: fields[3] as bool,
      endBellEnabled: fields[4] as bool,
      profileMade: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.soundEnabled)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.voicePromptsEnabled)
      ..writeByte(3)
      ..write(obj.startBellEnabled)
      ..writeByte(4)
      ..write(obj.endBellEnabled)
      ..writeByte(5)
      ..write(obj.profileMade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
