import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:hive/hive.dart';

part 'level_hive.g.dart';


@HiveType(typeId: 21) // Unique ID for Program
class Level {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Program> programs; // List of programs under this level

  Level({
    required this.id,
    required this.name,
    required this.programs,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Level &&
              runtimeType == other.runtimeType &&
              name == other.name; // Compare based on name or a unique identifier

  @override
  int get hashCode => name.hashCode; // Use name for hashCode
}
