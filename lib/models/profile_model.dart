import 'package:boxing_timer_v1/models/settings_model.dart';
import 'package:hive/hive.dart';

import '../hives/category_hive.dart';
import '../hives/level_hive.dart';
import '../hives/program_hive.dart';


part 'profile_model.g.dart';



@HiveType(typeId: 0)
class Profile {
  @HiveField(0)
  final int id;

  @HiveField(1)
  String username;

  @HiveField(2)
  Category category;

  @HiveField(3)
  Level level;


  @HiveField(4)
  Program program;

  @HiveField(5)
  Settings settings;


  @HiveField(6)
  DateTime registrationDate;

  Profile({
    required this.id,
    required this.username,
    required this.category,
    required this.level,
    required this.program,
    required this.settings,
    required this.registrationDate,
  });
}
