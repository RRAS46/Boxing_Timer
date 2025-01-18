import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boxing_timer_v1/screens/boxing_timer_screen.dart';
import 'package:boxing_timer_v1/hives/category_hive.dart';
import 'package:boxing_timer_v1/hives/database_hive.dart';
import 'package:boxing_timer_v1/hives/level_hive.dart';
import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/models/profile_model.dart';
import 'package:boxing_timer_v1/models/settings_model.dart';
import 'package:boxing_timer_v1/models/sound_model.dart';
import 'package:boxing_timer_v1/providers/audio_provider.dart';
import 'package:boxing_timer_v1/providers/profile_provider.dart';
import 'package:boxing_timer_v1/providers/settings_provider.dart';
import 'package:boxing_timer_v1/providers/setup_provider.dart';
import 'package:boxing_timer_v1/screens/information_screen.dart';
import 'package:boxing_timer_v1/screens/profile_edit_screen.dart';
import 'package:boxing_timer_v1/screens/profile_maker_screen.dart';
import 'package:boxing_timer_v1/screens/profile_view_screen.dart';
import 'package:boxing_timer_v1/screens/settings_screen.dart';
import 'package:boxing_timer_v1/screens/setup_screen.dart';
import 'package:boxing_timer_v1/themes.dart';
import 'package:boxing_timer_v1/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue,
    elevation: 0,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueGrey,
    elevation: 0,
  ),
);

void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Register your adapters here
  Hive.registerAdapter(DatabaseAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(LevelAdapter());
  Hive.registerAdapter(ProgramAdapter());
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(SoundAdapter());  // Register the adapter

  var databaseBox = await Hive.openBox<Database>(database_box); // Box for storing categories
  await Hive.openBox(settings_box); // Example box
  await Hive.openBox<Profile>(profile_box);  // Open the Hive box for storing profiles

  if (databaseBox.isEmpty) {
    await saveProgramsToHive();
    print('niaouuuuuuuuuuu');
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  AwesomeNotifications().initialize(
    'resource://mipmap/boxing_timer_logo_gradient', // app icon
    [
      NotificationChannel(
        channelKey: 'boxing_timer_channel',
        channelName: 'Boxing Timer Notifications',
        channelDescription: 'Notifications for the boxing timer',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        enableVibration: false,
        defaultRingtoneType: DefaultRingtoneType.Notification,
        criticalAlerts: false,
        enableLights: false,
        playSound: false, // Disable sound
        soundSource: "",
        onlyAlertOnce: false,
      ),
    ],
  );

  // Ensure status bar is fully transparent
  // Hide the system UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight,DeviceOrientation.portraitUp]);
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
        ChangeNotifierProvider<AudioProvider>(create: (_) => AudioProvider()),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<SetupProvider>(create: (_) => SetupProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Boxing Timer',
            debugShowCheckedModeBanner: false,
            theme: lightMode,
            darkTheme: darkMode,
            themeMode: settingsProvider.themeMode, // Access theme mode from SettingsProvider
            initialRoute: '/', // Starting route
            routes: {
              '/': (context) => Provider.of<ProfileProvider>(context).isProfileAvailable
                  ? SetupPage()
                  : ProfileMakerScreen(),
              '/edit_profile': (context) => ProfileEditPage(),
              '/view_profile': (context) => ProfileViewPage(),
              '/boxing_timer': (context) => BoxingTimerPage(),
              '/info_page': (context) => InfoPage(),

              // Add more routes here as needed
            },
          );
        },
      ),
    );
  }
}



Future<void> saveProgramsToHive() async {
  var databaseBox = Hive.box<Database>(database_box);

  // Create Program instances
  // Boxing Programs
  List<Program> programsBoxingBeginner = [
    Program(id: 0, name: 'Intro to Boxing', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 15),
    Program(id: 1, name: 'Basic Shadow Boxing', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 20),
    Program(id: 2, name: 'Jab & Cross Drills', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 15),
    Program(id: 3, name: 'Footwork Fundamentals', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 15),
    Program(id: 4, name: 'Basic Punching Bag', rounds: 4, preparationDuration: 20, workDuration: 60, restDuration: 20),
  ];

  List<Program> programsBoxingMiddle = [
    Program(id: 0, name: 'Punch Combinations', rounds: 4, preparationDuration: 30, workDuration: 50, restDuration: 25),
    Program(id: 1, name: 'Intermediate Shadow Fight', rounds: 4, preparationDuration: 30, workDuration: 60, restDuration: 30),
    Program(id: 2, name: 'Advanced Jab & Cross', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 35),
    Program(id: 3, name: 'Dynamic Footwork', rounds: 4, preparationDuration: 30, workDuration: 60, restDuration: 25),
    Program(id: 4, name: 'Bag Work Intensity', rounds: 5, preparationDuration: 30, workDuration: 90, restDuration: 45),
  ];

  List<Program> programsBoxingAdvanced = [
    Program(id: 0, name: 'Advanced Punch Combos', rounds: 5, preparationDuration: 45, workDuration: 120, restDuration: 60),
    Program(id: 1, name: 'Sparring Techniques', rounds: 5, preparationDuration: 45, workDuration: 150, restDuration: 70),
    Program(id: 2, name: 'Counter Punching', rounds: 5, preparationDuration: 45, workDuration: 135, restDuration: 60),
    Program(id: 3, name: 'High Intensity Footwork', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 50),
    Program(id: 4, name: 'Bag Work Power Shots', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];

// Kickboxing Programs
  List<Program> programsKickboxingBeginner = [
    Program(id: 0, name: 'Intro to Kickboxing', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 10),
    Program(id: 1, name: 'Kickboxing Basics', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 15),
    Program(id: 2, name: 'Low Kick Drills', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 20),
    Program(id: 3, name: 'Punch & Kick Combos', rounds: 3, preparationDuration: 20, workDuration: 60, restDuration: 30),
    Program(id: 4, name: 'Bag Work for Beginners', rounds: 4, preparationDuration: 20, workDuration: 50, restDuration: 20),
  ];

  List<Program> programsKickboxingMiddle = [
    Program(id: 0, name: 'Punch & Kick Techniques', rounds: 4, preparationDuration: 30, workDuration: 50, restDuration: 25),
    Program(id: 1, name: 'Mid-Level Shadow Fight', rounds: 4, preparationDuration: 30, workDuration: 70, restDuration: 30),
    Program(id: 2, name: 'Knee Strike Power', rounds: 4, preparationDuration: 30, workDuration: 80, restDuration: 30),
    Program(id: 3, name: 'Advanced Punch & Kick Combos', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 35),
    Program(id: 4, name: 'Bag Work Intensity', rounds: 5, preparationDuration: 30, workDuration: 100, restDuration: 40),
  ];

  List<Program> programsKickboxingAdvanced = [
    Program(id: 0, name: 'High-Intensity Bag Work', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 60),
    Program(id: 1, name: 'Full Contact Sparring', rounds: 5, preparationDuration: 45, workDuration: 150, restDuration: 60),
    Program(id: 2, name: 'Kickboxing Endurance', rounds: 5, preparationDuration: 45, workDuration: 120, restDuration: 60),
    Program(id: 3, name: 'Power Kick Combos', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 40),
    Program(id: 4, name: 'Bag Work Power Shots', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];

// MMA Programs
  List<Program> programsMMABeginner = [
    Program(id: 0, name: 'MMA Basics', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 10),
    Program(id: 1, name: 'Basic Striking Techniques', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 15),
    Program(id: 2, name: 'Intro to Grappling', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 15),
    Program(id: 3, name: 'Basic Strikes & Takedowns', rounds: 3, preparationDuration: 20, workDuration: 50, restDuration: 20),
    Program(id: 4, name: 'Simple Sparring', rounds: 4, preparationDuration: 20, workDuration: 60, restDuration: 25),
  ];

  List<Program> programsMMAMiddle = [
    Program(id: 0, name: 'Striking & Grappling', rounds: 4, preparationDuration: 30, workDuration: 60, restDuration: 30),
    Program(id: 1, name: 'Intermediate Striking', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 30),
    Program(id: 2, name: 'Grappling Techniques', rounds: 4, preparationDuration: 30, workDuration: 90, restDuration: 30),
    Program(id: 3, name: 'Takedown Defense', rounds: 4, preparationDuration: 30, workDuration: 70, restDuration: 25),
    Program(id: 4, name: 'Sparring Rounds', rounds: 5, preparationDuration: 30, workDuration: 90, restDuration: 40),
  ];

  List<Program> programsMMAAdvanced = [
    Program(id: 0, name: 'Advanced Striking & Grappling', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 50),
    Program(id: 1, name: 'Full Contact Sparring', rounds: 5, preparationDuration: 40, workDuration: 150, restDuration: 60),
    Program(id: 2, name: 'Takedown Mastery', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 50),
    Program(id: 3, name: 'High-Level Ground Game', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 45),
    Program(id: 4, name: 'Mixed Martial Arts Combat', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];

  // BJJ Programs
  List<Program> programsBJJBeginner = [
    Program(id: 0, name: 'Intro to BJJ', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 10),
    Program(id: 1, name: 'Basic Guard Drills', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 15),
    Program(id: 2, name: 'Simple Submissions', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 15),
    Program(id: 3, name: 'Escapes & Transitions', rounds: 3, preparationDuration: 20, workDuration: 50, restDuration: 20),
    Program(id: 4, name: 'Basic Rolling', rounds: 4, preparationDuration: 20, workDuration: 60, restDuration: 25),
  ];

  List<Program> programsBJJMiddle = [
    Program(id: 0, name: 'Advanced Guard Techniques', rounds: 4, preparationDuration: 30, workDuration: 60, restDuration: 30),
    Program(id: 1, name: 'Sweeps & Reversals', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 30),
    Program(id: 2, name: 'Takedown Drills', rounds: 4, preparationDuration: 30, workDuration: 90, restDuration: 30),
    Program(id: 3, name: 'Guard Passes', rounds: 4, preparationDuration: 30, workDuration: 70, restDuration: 25),
    Program(id: 4, name: 'Rolling Rounds', rounds: 5, preparationDuration: 30, workDuration: 90, restDuration: 40),
  ];

  List<Program> programsBJJAdvanced = [
    Program(id: 0, name: 'High-Level Guard Work', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 50),
    Program(id: 1, name: 'Advanced Submissions', rounds: 5, preparationDuration: 40, workDuration: 150, restDuration: 60),
    Program(id: 2, name: 'Leg Locks & Transitions', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 50),
    Program(id: 3, name: 'Live Sparring', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 45),
    Program(id: 4, name: 'Competition Simulation', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];

// Capoeira Programs
  List<Program> programsCapoeiraBeginner = [
    Program(id: 0, name: 'Ginga Basics', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 10),
    Program(id: 1, name: 'Basic Kicks & Dodges', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 15),
    Program(id: 2, name: 'Simple Combos', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 20),
    Program(id: 3, name: 'Flow & Rhythm', rounds: 3, preparationDuration: 20, workDuration: 60, restDuration: 30),
    Program(id: 4, name: 'Beginner Sparring', rounds: 4, preparationDuration: 20, workDuration: 50, restDuration: 20),
  ];

  List<Program> programsCapoeiraMiddle = [
    Program(id: 0, name: 'Advanced Ginga', rounds: 4, preparationDuration: 30, workDuration: 50, restDuration: 25),
    Program(id: 1, name: 'Flipping Techniques', rounds: 4, preparationDuration: 30, workDuration: 70, restDuration: 30),
    Program(id: 2, name: 'Intermediate Combos', rounds: 4, preparationDuration: 30, workDuration: 80, restDuration: 30),
    Program(id: 3, name: 'Flow & Acrobatics', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 35),
    Program(id: 4, name: 'Sparring Practice', rounds: 5, preparationDuration: 30, workDuration: 100, restDuration: 40),
  ];

  List<Program> programsCapoeiraAdvanced = [
    Program(id: 0, name: 'Advanced Acrobatics', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 60),
    Program(id: 1, name: 'Sparring & Flow', rounds: 5, preparationDuration: 45, workDuration: 150, restDuration: 60),
    Program(id: 2, name: 'Capoeira Combat', rounds: 5, preparationDuration: 45, workDuration: 120, restDuration: 60),
    Program(id: 3, name: 'Power Combos', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 40),
    Program(id: 4, name: 'High-Level Performance', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];

// Karate Programs
  List<Program> programsKarateBeginner = [
    Program(id: 0, name: 'Karate Basics', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 10),
    Program(id: 1, name: 'Basic Strikes & Blocks', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 15),
    Program(id: 2, name: 'Simple Katas', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 20),
    Program(id: 3, name: 'Karate Combos', rounds: 3, preparationDuration: 20, workDuration: 60, restDuration: 30),
    Program(id: 4, name: 'Beginner Sparring', rounds: 4, preparationDuration: 20, workDuration: 50, restDuration: 20),
  ];

  List<Program> programsKarateMiddle = [
    Program(id: 0, name: 'Kata Practice', rounds: 4, preparationDuration: 30, workDuration: 50, restDuration: 25),
    Program(id: 1, name: 'Intermediate Striking', rounds: 4, preparationDuration: 30, workDuration: 70, restDuration: 30),
    Program(id: 2, name: 'Sparring Drills', rounds: 4, preparationDuration: 30, workDuration: 80, restDuration: 30),
    Program(id: 3, name: 'Advanced Katas', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 35),
    Program(id: 4, name: 'Karate Combat', rounds: 5, preparationDuration: 30, workDuration: 100, restDuration: 40),
  ];

  List<Program> programsKarateAdvanced = [
    Program(id: 0, name: 'Advanced Striking Techniques', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 60),
    Program(id: 1, name: 'Full-Contact Sparring', rounds: 5, preparationDuration: 45, workDuration: 150, restDuration: 60),
    Program(id: 2, name: 'High-Level Katas', rounds: 5, preparationDuration: 45, workDuration: 120, restDuration: 60),
    Program(id: 3, name: 'Dynamic Sparring', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 40),
    Program(id: 4, name: 'Karate Combat Simulation', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];

// Taekwondo Programs
  List<Program> programsTKDBeginner = [
    Program(id: 0, name: 'Intro to Taekwondo', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 10),
    Program(id: 1, name: 'Basic Kicks & Strikes', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 15),
    Program(id: 2, name: 'Simple Forms (Poomsae)', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 20),
    Program(id: 3, name: 'Beginner Sparring', rounds: 3, preparationDuration: 20, workDuration: 60, restDuration: 30),
    Program(id: 4, name: 'Kicking Drills', rounds: 4, preparationDuration: 20, workDuration: 50, restDuration: 20),
  ];

  List<Program> programsTKDMiddle = [
    Program(id: 0, name: 'Intermediate Forms', rounds: 4, preparationDuration: 30, workDuration: 50, restDuration: 25),
    Program(id: 1, name: 'Advanced Kicking Techniques', rounds: 4, preparationDuration: 30, workDuration: 70, restDuration: 30),
    Program(id: 2, name: 'Mid-Level Sparring', rounds: 4, preparationDuration: 30, workDuration: 80, restDuration: 30),
    Program(id: 3, name: 'Combination Drills', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 35),
    Program(id: 4, name: 'Taekwondo Combat', rounds: 5, preparationDuration: 30, workDuration: 100, restDuration: 40),
  ];

  List<Program> programsTKDAdvanced = [
    Program(id: 0, name: 'Advanced Sparring & Forms', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 60),
    Program(id: 1, name: 'Full Contact Combat', rounds: 5, preparationDuration: 45, workDuration: 150, restDuration: 60),
    Program(id: 2, name: 'Dynamic Kicking Techniques', rounds: 5, preparationDuration: 45, workDuration: 120, restDuration: 60),
    Program(id: 3, name: 'High-Intensity Drills', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 40),
    Program(id: 4, name: 'Taekwondo Combat Simulation', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];

// Gym Workouts
  List<Program> programsGymBeginner = [
    Program(id: 0, name: 'Basic Strength Training', rounds: 3, preparationDuration: 20, workDuration: 30, restDuration: 10),
    Program(id: 1, name: 'Cardio & Core', rounds: 3, preparationDuration: 20, workDuration: 40, restDuration: 15),
    Program(id: 2, name: 'Full Body Workout', rounds: 3, preparationDuration: 20, workDuration: 45, restDuration: 20),
    Program(id: 3, name: 'Upper Body Strength', rounds: 3, preparationDuration: 20, workDuration: 60, restDuration: 30),
    Program(id: 4, name: 'Lower Body Workout', rounds: 4, preparationDuration: 20, workDuration: 50, restDuration: 20),
  ];

  List<Program> programsGymMiddle = [
    Program(id: 0, name: 'Intermediate Strength Training', rounds: 4, preparationDuration: 30, workDuration: 50, restDuration: 25),
    Program(id: 1, name: 'Cardio & Core Blast', rounds: 4, preparationDuration: 30, workDuration: 70, restDuration: 30),
    Program(id: 2, name: 'Bodybuilding Basics', rounds: 4, preparationDuration: 30, workDuration: 80, restDuration: 30),
    Program(id: 3, name: 'Upper Body Power', rounds: 4, preparationDuration: 30, workDuration: 75, restDuration: 35),
    Program(id: 4, name: 'Leg Day Intensity', rounds: 5, preparationDuration: 30, workDuration: 100, restDuration: 40),
  ];

  List<Program> programsGymAdvanced = [
    Program(id: 0, name: 'Advanced Strength Training', rounds: 5, preparationDuration: 40, workDuration: 120, restDuration: 60),
    Program(id: 1, name: 'Endurance & Power', rounds: 5, preparationDuration: 45, workDuration: 150, restDuration: 60),
    Program(id: 2, name: 'High-Intensity Interval Training (HIIT)', rounds: 5, preparationDuration: 45, workDuration: 120, restDuration: 60),
    Program(id: 3, name: 'Full-Body Power', rounds: 5, preparationDuration: 45, workDuration: 90, restDuration: 40),
    Program(id: 4, name: 'Strength & Conditioning Challenge', rounds: 6, preparationDuration: 45, workDuration: 180, restDuration: 90),
  ];




  // Create Levels with Programs

  // Create Levels for BJJ, Capoeira, Karate, Taekwondo, Gym Workouts
  List<Level> levelsBJJ = [
    Level(id: 1, name: 'Beginner Level', programs: programsBJJBeginner),
    Level(id: 2, name: 'Middle Level', programs: programsBJJMiddle),
    Level(id: 3, name: 'Advanced Level', programs: programsBJJAdvanced),
  ];

  List<Level> levelsCapoeira = [
    Level(id: 1, name: 'Beginner Level', programs: programsCapoeiraBeginner),
    Level(id: 2, name: 'Middle Level', programs: programsCapoeiraMiddle),
    Level(id: 3, name: 'Advanced Level', programs: programsCapoeiraAdvanced),
  ];

  List<Level> levelsKarate = [
    Level(id: 1, name: 'Beginner Level', programs: programsKarateBeginner),
    Level(id: 2, name: 'Middle Level', programs: programsKarateMiddle),
    Level(id: 3, name: 'Advanced Level', programs: programsKarateAdvanced),
  ];

  List<Level> levelsTKD = [
    Level(id: 1, name: 'Beginner Level', programs: programsTKDBeginner),
    Level(id: 2, name: 'Middle Level', programs: programsTKDMiddle),
    Level(id: 3, name: 'Advanced Level', programs: programsTKDAdvanced),
  ];

  List<Level> levelsGym = [
    Level(id: 1, name: 'Beginner Level', programs: programsGymBeginner),
    Level(id: 2, name: 'Middle Level', programs: programsGymMiddle),
    Level(id: 3, name: 'Advanced Level', programs: programsGymAdvanced),
  ];

  List<Level> levelsBoxing = [
    Level(id: 1,name: 'Beginner Level', programs: programsBoxingBeginner),
    Level(id: 2,name: 'Middle Level', programs: programsBoxingMiddle),
    Level(id: 3,name: 'Advanced Level', programs: programsBoxingAdvanced),
  ];
  List<Level> levelsKickboxing = [
    Level(id: 1,name: 'Beginner Level', programs: programsKickboxingBeginner),
    Level(id: 2,name: 'Middle Level', programs: programsKickboxingMiddle),
    Level(id: 3,name: 'Advanced Level', programs: programsKickboxingAdvanced),
  ];
  List<Level> levelsMMA = [
    Level(id: 1,name: 'Beginner Level', programs: programsMMABeginner),
    Level(id: 2,name: 'Middle Level', programs: programsMMAMiddle),
    Level(id: 3,name: 'Advanced Level', programs: programsMMAAdvanced),
  ];

  // Create Categories with Levels
  List<Category> categories = [
    Category(id: 1, name: 'Boxing', levels: levelsBoxing),
    Category(id: 2, name: 'Kickboxing', levels: levelsKickboxing),
    Category(id: 3, name: 'MMA', levels: levelsMMA),
    Category(id: 4, name: 'Brazilian Jiu-Jitsu (BJJ)', levels: levelsBJJ),
    Category(id: 5, name: 'Capoeira', levels: levelsCapoeira),
    Category(id: 6, name: 'Karate', levels: levelsKarate),
    Category(id: 7, name: 'Taekwondo', levels: levelsTKD),
    Category(id: 8, name: 'Gym Workouts', levels: levelsGym),
  ];




  Database database=Database(categories: categories);

  databaseBox.put(database_name, database); // Use the category name as key
  databaseBox.put(database_const_name, database);
}


class BluetoothConnectionPage extends StatefulWidget {
  @override
  _BluetoothConnectionPageState createState() => _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  bool isConnecting = false;
  bool isConnected = false;
  bool isDisconnecting = false;
  List<BluetoothDiscoveryResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    _bluetoothState = await _bluetooth.state;
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await _bluetooth.requestEnable();
    }
    _bluetooth.onStateChanged().listen((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  void startScan() {
    _bluetooth.startDiscovery().listen((result) {
      setState(() {
        _scanResults.add(result);
      });
    }).onDone(() {
      print('Scan complete');
    });
  }

  void stopScan() {
    _bluetooth.cancelDiscovery();
  }

  Future<void> connect(BluetoothDevice device) async {
    setState(() {
      isConnecting = true;
    });

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');
      setState(() {
        _connection = connection;
        isConnecting = false;
        isConnected = true;

      });

      connection.input?.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Echoing the data back to the device

        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
          setState(() {
            isConnected = false;
          });
        }
      }).onDone(() {
        print('Disconnected by remote request');
        setState(() {
          isConnected = false;
        });
      });
    } catch (exception) {
      print('Cannot connect, exception occurred: $exception');
      setState(() {
        isConnecting = false;
      });
    }
  }

  void disconnect() async {
    if (_connection != null) {
      setState(() {
        isDisconnecting = true;
      });
      await _connection!.close();
      setState(() {
        isDisconnecting = false;
        isConnected = false;
      });
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Connection'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: startScan,
          ),
          if (isConnecting) CircularProgressIndicator(),
          if (isDisconnecting) CircularProgressIndicator(),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Bluetooth State: $_bluetoothState'),
            subtitle: Text('Scanning ${isConnecting ? '...': ''}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final device = _scanResults[index].device;
                return ListTile(
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Text(device.address),
                  trailing: isConnected && _selectedDevice == device
                      ? Icon(Icons.bluetooth_connected, color: Colors.blue)
                      : Icon(Icons.bluetooth, color: Colors.grey),
                  onTap: () {
                    if (isConnected && _selectedDevice == device) {
                      disconnect();
                    } else {
                      connect(device);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
