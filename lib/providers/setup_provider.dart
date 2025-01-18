import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/models/profile_model.dart';
import 'package:boxing_timer_v1/models/setup_model.dart';
import 'package:boxing_timer_v1/providers/profile_provider.dart';
import 'package:boxing_timer_v1/screens/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class SetupProvider extends ChangeNotifier {


  Program _program = Program(
    id: 0,
    name: "Default",
    rounds: 3,
    preparationDuration: 30,
    restDuration: 30,
    workDuration: 60
  );

  Program get program => _program;



  void setProgram(Program program) {
    _program = program;
    notifyListeners();
  }
  set rounds(int value) {
    _program.rounds = value;
    notifyListeners();
  }

  void setPreparationTime(int value) {
    _program.preparationDuration = value;
    notifyListeners();
  }

  void setRoundTime(int index, int value) {
    _program.workDuration = value;
    notifyListeners();
  }

  void setBreakTime(int index, int value) {
    _program.restDuration = value;
    notifyListeners();
  }


}
