import 'package:hive/hive.dart';

part 'sound_model.g.dart'; // Generated file

@HiveType(typeId: 2)  // Assign a unique typeId for this adapter
class Sound {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String path;

  Sound({required this.name, required this.path});
}
