import 'package:hive/hive.dart';



part 'settings_model.g.dart';


@HiveType(typeId: 1) // Set a unique typeId for this model
class Settings {

  @HiveField(0)
  bool soundEnabled;

  @HiveField(1)
  bool notificationsEnabled;

  @HiveField(2)
  bool voicePromptsEnabled;

  @HiveField(3)
  bool startBellEnabled;

  @HiveField(4)
  bool endBellEnabled;

  @HiveField(5)
  bool profileMade;

  Settings({
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.voicePromptsEnabled = true,
    this.startBellEnabled = true,
    this.endBellEnabled = true,
    this.profileMade = false,
  });

  static Settings get defaultSettings {
    return Settings();
  }
  
}
