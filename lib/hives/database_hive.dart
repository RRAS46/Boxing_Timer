import 'package:boxing_timer_v1/hives/category_hive.dart';
import 'package:hive/hive.dart';


part 'database_hive.g.dart';


@HiveType(typeId: 23) // Unique ID for Category
class Database {

  @HiveField(0)
  List<Category> categories; // List of levels under this category

  Database({
    required this.categories,
  });
}
