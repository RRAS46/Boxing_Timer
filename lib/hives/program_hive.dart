import 'package:hive/hive.dart';


part 'program_hive.g.dart';


@HiveType(typeId: 20) // Unique ID for Program
class Program {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int rounds;

  @HiveField(3)
  int preparationDuration; // in seconds

  @HiveField(4)
  int workDuration; // in seconds

  @HiveField(5)
  int restDuration; // in seconds

  Program({
    required this.id,
    required this.name,
    required this.rounds,
    required this.preparationDuration,
    required this.workDuration,
    required this.restDuration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Program &&
              runtimeType == other.runtimeType &&
              name == other.name; // Compare based on name or a unique identifier

  @override
  int get hashCode => name.hashCode; // Use name for hashCode

}
