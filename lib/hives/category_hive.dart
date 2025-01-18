import 'package:boxing_timer_v1/hives/level_hive.dart';
import 'package:hive/hive.dart';

part 'category_hive.g.dart';


@HiveType(typeId: 22) // Unique ID for Category
class Category {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Level> levels; // List of levels under this category

  Category({
    required this.id,
    required this.name,
    required this.levels,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Category &&
              runtimeType == other.runtimeType &&
              name == other.name; // Compare based on name or a unique identifier

  @override
  int get hashCode => name.hashCode; // Use name for hashCode
}
