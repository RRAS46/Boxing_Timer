import 'package:boxing_timer_v1/hives/category_hive.dart';
import 'package:boxing_timer_v1/hives/database_hive.dart';
import 'package:boxing_timer_v1/hives/level_hive.dart';
import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/models/sound_model.dart';
import 'package:boxing_timer_v1/providers/setup_provider.dart';
import 'package:boxing_timer_v1/values.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';

class SettingsProvider extends ChangeNotifier {
  Box _settingsBox = Hive.box(settings_box); // Initialize Hive box



  VolumeController volumeController = VolumeController();



  ThemeMode _themeMode = Hive.box(settings_box).get('themeMode', defaultValue: 'light') == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;

  // Getter for theme mode
  ThemeMode get themeMode => _themeMode;

  // Function to toggle between light and dark mode
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _settingsBox.put('themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  // Round Volume Control (interacts with system volume)
  Future<void> setRoundVolume(double value) async {
    // Update the volume (0.0 to 1.0 scale)
    volumeController.setVolume(value);
    notifyListeners();
  }

  Future<double> getRoundVolume() async {
    // Get the current system volume
    return await volumeController.getVolume();
  }

  // Break Volume Control (system volume as well, or separate if desired)
  Future<void> setBreakVolume(double value) async {
    // Optionally you could have a different system or app volume
    volumeController.setVolume(value);
    notifyListeners();
  }

  Future<double> getBreakVolume() async {
    return await volumeController.getVolume();
  }

  // Interval Volume Control (same or separate)
  Future<void> setIntervalVolume(double value) async {
    volumeController.setVolume(value);
    notifyListeners();
  }






  Future<double> getIntervalVolume() async {
    return await volumeController.getVolume();
  }













  void addCategoryLevelProgram({
    required BuildContext context,
    required String categoryName,
    required String levelName,
    required List<String> programNames,
  }) {
    // Access the Hive box that stores your database
    Box databaseBox = Hive.box<Database>(database_box);

    // Get the database object
    Database database = databaseBox.get(database_name);

    // Retrieve the list of categories from the database
    List<Category> categories = database.categories;

    // Find if the category already exists
    Category? existingCategory = categories.firstWhere(
          (category) => category.name == categoryName,
      orElse: () => Category(id: (categories.isNotEmpty ? (categories.last.id + 1) : 1), name: categoryName, levels: []),
    );

    // If the category is new, add it to the list of categories
    if (!categories.contains(existingCategory)) {
      categories.add(existingCategory);
    }

    // Find if the level already exists in the category
    Level? existingLevel = existingCategory.levels.firstWhere(
          (level) => level.name == levelName,
      orElse: () => Level(id: existingCategory.levels.isNotEmpty ? (existingCategory.levels.last.id + 1) : 1, name: levelName, programs: []),
    );

    // If the level is new, add it to the category's levels list
    if (!existingCategory.levels.contains(existingLevel)) {
      existingCategory.levels.add(existingLevel);
    }

    SetupProvider setupProvider = Provider.of<SetupProvider>(context, listen: false);

    // Add new programs to the existing level (if they don't exist)
    for (String programName in programNames) {
      if (existingLevel.programs.every((program) => program.name != programName)) {
        existingLevel.programs.add(
          Program(
            id: existingLevel.programs.isNotEmpty ? (existingLevel.programs.last.id + 1) : 1,
            name: programName,
            preparationDuration: setupProvider.program.preparationDuration,
            workDuration: setupProvider.program.workDuration,
            restDuration: setupProvider.program.restDuration,
            rounds: setupProvider.program.rounds,
          ),
        );
      }
    }

    // Save the updated database object back to Hive
    databaseBox.put(database_name, database);

    // Optionally notify the listeners if using ChangeNotifierProvider
    notifyListeners();
  }



  // Sound settings
  bool get soundEnabled => _settingsBox.get('soundEnabled', defaultValue: true);
  void setSoundEnabled(bool value) {
    _settingsBox.put('soundEnabled', value);
    notifyListeners();
  }

  // Voice Prompts
  bool get voicePromptsEnabled => _settingsBox.get('voicePromptsEnabled', defaultValue: true);
  void setVoicePromptsEnabled(bool value) {
    _settingsBox.put('voicePromptsEnabled', value);
    notifyListeners();
  }

  // Start Bell settings
  bool get startBellEnabled => _settingsBox.get('startBellEnabled', defaultValue: true);
  void setStartBellEnabled(bool value) {
    _settingsBox.put('startBellEnabled', value);
    notifyListeners();
  }

  // End Bell settings
  bool get endBellEnabled => _settingsBox.get('endBellEnabled', defaultValue: true);
  void setEndBellEnabled(bool value) {
    _settingsBox.put('endBellEnabled', value);
    notifyListeners();
  }

  // Notification settings
  bool get notificationsEnabled => _settingsBox.get('notificationsEnabled', defaultValue: true);
  void setNotificationsEnabled(bool value) {
    _settingsBox.put('notificationsEnabled', value);
    notifyListeners();
  }

  // Round Start/End Sound Selection
  Sound get selectedRoundSound => _settingsBox.get('selectedRoundSound', defaultValue: Sound(name: "bell", path: "boxing_bell_sound_v1.m4a"));
  void setRoundStartEndSound(Sound sound) {
    _settingsBox.put('selectedRoundSound', sound);
    notifyListeners();
  }

  // Break Start/End Sound Selection
  Sound get selectedBreakSound => _settingsBox.get('selectedBreakSound', defaultValue: Sound(name: "bell", path: "boxing_bell_sound_v1.m4a"));
  void setBreakStartEndSound(Sound sound) {
    _settingsBox.put('selectedBreakSound', sound);
    notifyListeners();
  }

  // 10-Second Warning
  bool get threeSecondWarningEnabled => _settingsBox.get('threeSecondWarningEnabled', defaultValue: true);
  void setThreeSecondWarningEnabled(bool value) {
    _settingsBox.put('threeSecondWarningEnabled', value);
    notifyListeners();
  }

  // Volume Control (for sound)
  double get volumeLevel => _settingsBox.get('volumeLevel', defaultValue: 0.5);
  void setVolumeLevel(double value) {
    _settingsBox.put('volumeLevel', value);
    notifyListeners();
  }

  // Vibration Alerts
  bool get vibrationAlertEnabled => _settingsBox.get('vibrationAlertEnabled', defaultValue: false);
  void setVibrationAlertEnabled(bool value) {
    _settingsBox.put('vibrationAlertEnabled', value);
    notifyListeners();
  }

  // Voice Announcements
  bool get voiceAnnouncementsEnabled => _settingsBox.get('voiceAnnouncementsEnabled', defaultValue: false);
  void setVoiceAnnouncementsEnabled(bool value) {
    _settingsBox.put('voiceAnnouncementsEnabled', value);
    notifyListeners();
  }
}
