import 'dart:async';
import 'package:boxing_timer_v1/screens/boxing_timer_screen.dart';
import 'package:boxing_timer_v1/hives/category_hive.dart';
import 'package:boxing_timer_v1/hives/database_hive.dart';
import 'package:boxing_timer_v1/hives/level_hive.dart';
import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/models/profile_model.dart';
import 'package:boxing_timer_v1/providers/profile_provider.dart';
import 'package:boxing_timer_v1/providers/settings_provider.dart';
import 'package:boxing_timer_v1/providers/setup_provider.dart';
import 'package:boxing_timer_v1/screens/add_custom_category_screen.dart';
import 'package:boxing_timer_v1/screens/profile_maker_screen.dart';
import 'package:boxing_timer_v1/screens/profile_view_screen.dart';
import 'package:boxing_timer_v1/screens/settings_screen.dart';
import 'package:boxing_timer_v1/screens/profile_edit_screen.dart';
import 'package:boxing_timer_v1/themes.dart';
import 'package:boxing_timer_v1/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';


dynamic getResponsiveValue({
  required BuildContext context,
  required dynamic smallAndroidPhoneValue,   // Value for Small Android Phones (<360dp width)
  required dynamic largeAndroidPhoneValue,   // Value for Large Android Phones (360dp - 400dp width)
  required dynamic iPhoneValue,              // Value for iPhones (400dp - 600dp width)
  required dynamic smallTabletValue,         // Value for Small Tablets (600dp - 720dp width)
  required dynamic largeTabletValue,         // Value for Large Tablets (720dp - 900dp width)
  required dynamic iPadValue,                // Value for iPads (900dp - 1200dp width)
  required dynamic desktopValue              // Value for Desktop or larger screens
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Determine orientation
  var orientation = MediaQuery.of(context).orientation;
  bool isPortrait = orientation == Orientation.portrait;

  // Use height for portrait, width for landscape
  double responsiveSize = isPortrait ? screenHeight : screenWidth;

  if (responsiveSize < 360) {
    // Small Android phones
    return smallAndroidPhoneValue;
  } else if (responsiveSize >= 360 && responsiveSize < 400) {
    // Large Android phones
    return largeAndroidPhoneValue;
  } else if (responsiveSize >= 400 && responsiveSize < 600) {
    // iPhones
    return iPhoneValue;
  } else if (responsiveSize >= 600 && responsiveSize < 720) {
    // Small Tablets
    return smallTabletValue;
  } else if (responsiveSize >= 720 && responsiveSize < 900) {
    // Large Tablets
    return largeTabletValue;
  } else if (responsiveSize >= 900 && responsiveSize < 1200) {
    // iPads
    return iPadValue;
  } else {
    // Desktop or large screens
    return desktopValue;
  }
}

dynamic getResponsiveValueGeneral({
  required BuildContext context,
  required dynamic mobileDevices,   // Value for Small Android Phones (<360dp width)
  required dynamic tablets,   // Value for Large Android Phones (360dp - 400dp width)
  required dynamic laptops,              // Value for iPhones (400dp - 600dp width)
  required dynamic desktops,         // Value for Small Tablets (600dp - 720dp width)
  required dynamic tv,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Determine orientation
  var orientation = MediaQuery.of(context).orientation;
  bool isPortrait = orientation == Orientation.portrait;

  // Use height for portrait, width for landscape
  double responsiveSize = !isPortrait ? screenHeight : screenWidth;

  if (responsiveSize <= 480) {
    // Small Android phones
    return mobileDevices;
  } else if (responsiveSize > 480 && responsiveSize <= 768) {
    // Large Android phones
    return tablets;
  } else if (responsiveSize > 769 && responsiveSize <= 1024) {
    // iPhones
    return laptops;
  } else if (responsiveSize > 1025 && responsiveSize <= 1200  ) {
    // Small Tablets
    return desktops;
  } else{
    // Large Tablets
    return tv;
  }
}


class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {

  Box<Database> databaseBox=Hive.box<Database>(database_box);

  List<Category> availableCategories =[];

  bool isCustomMode = false;
  List<String> constCategoryNames=[];

  @override
  void initState() {
    super.initState();
    SetupProvider setupProvider=Provider.of<SetupProvider>(context,listen: false);
    ProfileProvider profileProvider =Provider.of<ProfileProvider>(context,listen: false);
    setupProvider.setProgram(profileProvider.getProfile()!.program);
    availableCategories=databaseBox.get(database_name)!.categories;
    constCategoryNames=setCategoryNames(databaseBox.get(database_const_name)!.categories);

  }


  List<String> setCategoryNames(List<Category> categories){
    List<String> temp=[];
    for(var category in categories){
      temp.add(category.name);
      print(category.name);
    }
    return temp;
  }


  void _showTimerPicker(BuildContext context, Duration initialTimer, Function(Duration) onTimerChanged) {
    Duration selectedDuration = initialTimer;
    final screenSize = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    bool isPortrait = orientation == Orientation.portrait;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        SetupProvider setupProvider = Provider.of<SetupProvider>(context, listen: false);
        ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);

        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            height: isPortrait ? screenSize.height * 0.4 : screenSize.height * 0.6,
            width: isPortrait ? screenSize.width * 0.8 : screenSize.width * 0.4,
            child: Column(
              children: [
                // Header with Title and Close Button
                Container(
                  width: screenSize.width,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Set Timer',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Timer Picker
                Expanded(
                  child: CupertinoTimerPicker(
                    itemExtent: 36.0,
                    alignment: Alignment.center,
                    mode: CupertinoTimerPickerMode.ms,
                    initialTimerDuration: initialTimer,
                    onTimerDurationChanged: (Duration newDuration) {
                      selectedDuration = newDuration;
                    },
                  ),
                ),
                // OK Button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CupertinoButton(
                    color: Colors.blueAccent,
                    child: Text('OK', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (selectedDuration.inSeconds == 0) {
                        selectedDuration = Duration(seconds: 1);
                      }
                      onTimerChanged(selectedDuration);
                      setProgramToCustom(setupProvider, profileProvider);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRoundsPicker(BuildContext context, int initialRounds, Function(int) onRoundsChanged) {
    int selectedRounds = initialRounds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            height: 300,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                // Header with Title and Close Button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Select Rounds',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Rounds Picker
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36.0,
                    scrollController: FixedExtentScrollController(initialItem: initialRounds - 1),
                    onSelectedItemChanged: (int index) {
                      selectedRounds = index + 1;
                    },
                    children: List<Widget>.generate(100, (int index) {
                      return Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(fontSize: 25),
                        ),
                      );
                    }),
                  ),
                ),
                // OK Button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CupertinoButton(
                    color: Colors.blueAccent,
                    child: Text('OK', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      onRoundsChanged(selectedRounds);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  String _formatTime(int seconds, bool checkNumberCount) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');

    String tempString = "";

    if (checkNumberCount) {
      if (seconds < 60) {
        // Less than a minute, show only seconds
        tempString = '$secs';
      } else if (seconds < 3600) {
        // Less than an hour, show minutes and seconds
        tempString = '$minutes:$secs';
      } else {
        // More than an hour, show hours, minutes, and seconds
        tempString = '$hours:$minutes:$secs';
      }
    } else {
      // Always show hours, minutes, and seconds
      tempString = '$hours:$minutes:$secs';
    }

    return tempString;
  }


  int calculateTotalDuration(Program program) {
    int totalTime = 0;

    // Add preparation time
    totalTime += program.preparationDuration;

    // Iterate through all rounds and sum up round times and break times
    print(program.restDuration);
    totalTime += (program.workDuration * program.rounds);
    totalTime += (program.restDuration * (program.rounds-1));

    return totalTime;
  }

  void _saveSetup() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoxingTimerPage(),
      ),
    );
  }

  void _openSettingsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final setupProvider = Provider.of<SetupProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    Profile? profile = profileProvider.getProfile();
    var orientation = MediaQuery.of(context).orientation;
    bool isPortrait = orientation == Orientation.portrait;
    isPortrait ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]):
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    bool isLightMode = Theme.of(context).brightness == Brightness.light;


    // Check if the profile is available
    if (!profileProvider.isProfileAvailable) {
      return Scaffold(
        body: Container(
          height: screenSize.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent], // Set your gradient colors here
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
              child: profile == null ? Column(
                children: [
                  Text(
                    'No profile found.',
                    style: TextStyle(
                      fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                        backgroundColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.1))
                    ),
                    onPressed: () {
                      Navigator.popAndPushNamed(context, '/');
                    },
                    child: Text(
                      'Make Profile',
                      style: TextStyle(
                        fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ) : CircularProgressIndicator()
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLightMode ? colorSetupScreenBackgroundLight : colorSetupScreenBackgroundDark, // Set your gradient colors here
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: screenSize.height,

                  child: Column(
                    children: [
                      isPortrait ? SizedBox(height: screenSize.height * getResponsiveValueGeneral(context: context, mobileDevices: .16, tablets: .15, laptops: .1, desktops: .1, tv: .1)) : SizedBox(),
                      // Change layout based on orientation
                      isPortrait
                          ? buildPortraitLayout(setupProvider, profileProvider, context,isLightMode)
                          : Expanded(child: buildLandscapeLayout(setupProvider, profileProvider, context,isLightMode)),
                      if (isPortrait) ...[
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: screenSize.width * .25,
                            child: MaterialButton(
                              onPressed: _saveSetup,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Total Time: ${_formatTime(calculateTotalDuration(setupProvider.program), true)}",
                                    style: TextStyle(
                                      fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 15.0, tablets: 18.0, laptops: 20.0, desktops: 20.0, tv: 20.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Start',
                                    style: TextStyle(
                                      fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 37.0, tablets: 52.0, laptops: 47.0, desktops: 47.0, tv: 47.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              minWidth: screenSize.width,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * .2,
                                vertical: screenSize.height * .01,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: isLightMode ? colorSetupScreenStartButtonBackgroundLight : colorSetupScreenStartButtonBackgroundDark,
                              textColor: isLightMode ? colorSetupScreenStartButtonTextLight : colorSetupScreenStartButtonTextDark,
                            ),
                          ),
                        )
                      ] else ...[
                        Container()
                      ]
                    ],
                  ),
                ),
              ),
            ),
            isPortrait
                ? Column(
              children: [
                SizedBox(height: screenSize.height * getResponsiveValueGeneral(context: context, mobileDevices: .075, tablets: .05, laptops: .05, desktops: .05, tv: .05)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenSize.width * .05),
                  child: Row(
                    children: [
                      IconButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(isLightMode ? colorSetupScreenMenuButtonBackgroundLight : colorSetupScreenMenuButtonBackgroundDark),
                        ),
                        padding: EdgeInsets.all(10),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileViewPage()));
                        },
                        icon: Icon(Icons.person, size: getResponsiveValueGeneral(context: context, mobileDevices: 32.0, tablets: 40.0, laptops: 40.0, desktops: 40.0, tv: 40.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark),
                      ),
                      Spacer(),
                      IconButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(isLightMode ? colorSetupScreenMenuButtonBackgroundLight : colorSetupScreenMenuButtonBackgroundDark),
                        ),
                        padding: EdgeInsets.all(10),
                        onPressed: () {
                          _showSelectCategoryDialog();
                        },
                        icon: Icon(Icons.upload, size: getResponsiveValueGeneral(context: context, mobileDevices: 32.0, tablets: 40.0, laptops: 40.0, desktops: 40.0, tv: 40.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark),
                      ),
                      Spacer(),
                      IconButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(isLightMode ? colorSetupScreenMenuButtonBackgroundLight : colorSetupScreenMenuButtonBackgroundDark),
                        ),
                        padding: EdgeInsets.all(10),
                        onPressed: () {
                          showProgramSelectorBottomSheet(context);
                        },
                        icon: Icon(Icons.fitness_center, size: getResponsiveValueGeneral(context: context, mobileDevices: 32.0, tablets: 40.0, laptops: 40.0, desktops: 40.0, tv: 40.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark),
                      ),
                    ],
                  ),
                ),
              ],
            )
                : Container(),
          ],
        ),
      ),
    );
  }


  void _showAddProgramDialog(Category category) {
    SetupProvider setupProvider=Provider.of<SetupProvider>(context,listen: false);
    String newProgramName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Program'),
          content: TextField(
            onChanged: (value) {
              newProgramName = value;
            },
            decoration: InputDecoration(hintText: 'Program Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                category.levels.first.programs.add(Program(id: category.levels.first.programs.length + 1, name: newProgramName, rounds: setupProvider.program.rounds, preparationDuration: setupProvider.program.preparationDuration, workDuration: setupProvider.program.workDuration, restDuration: setupProvider.program.restDuration));
                databaseBox.put(database_name, Database(categories: availableCategories));
                ProfileProvider profileProvider=Provider.of<ProfileProvider>(context,listen: false);
                Profile profile=profileProvider.getProfile()!;
                profile.category = category;
                profile.level = category.levels.first;
                profile.program = category.levels.first.programs.last;
                profileProvider.saveProfile(profile);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  bool checkCategoryNameInConstantCategoryNames(List<String> names,String checkName){
    for(var name in names){
      if(checkName == name){
        return true;
      }
    }
    return false;
  }


  void _showSelectCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Container(
            // Set height for the dialog content to make it scrollable if necessary
            height: 300,
            width: 300,
            child: availableCategories.isNotEmpty ? ListView.builder(
              itemCount: availableCategories.length,
              itemBuilder: (BuildContext context, int index) {

                Category category = availableCategories[index];
                if(!checkCategoryNameInConstantCategoryNames(constCategoryNames, availableCategories[index].name)){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      tileColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Text("${index-(constCategoryNames.length-1)}) ${category.name}",style: TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.of(context).pop(); // Close the category selection dialog
                        _showAddProgramDialog(category); // Proceed to add program to the selected category
                      },
                    ),
                  );
                }else{
                  return Container();
                }

              },
            ) : Center(
              child: Text("data"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  Widget buildPortraitLayout(SetupProvider setupProvider, ProfileProvider profileProvider, BuildContext context,bool isLightMode) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showTimerPicker(context, Duration(seconds: setupProvider.program.preparationDuration), (Duration newTimer) {
            setupProvider.setPreparationTime(newTimer.inSeconds);
          }),
          child: _buildTimerDisplay('Preparation Time', setupProvider.program.preparationDuration, false,isPortrait: true,isLightMode: isLightMode),
        ),
        Divider(),
        GestureDetector(
          onTap: () => _showTimerPicker(context, Duration(seconds: setupProvider.program.workDuration), (Duration newTimer) {
            setupProvider.setRoundTime(0, newTimer.inSeconds);
          }),
          child: _buildTimerDisplay('Round Time', setupProvider.program.workDuration, true,isPortrait: true,isLightMode: isLightMode),
        ),
        Divider(),
        GestureDetector(
          onTap: () => _showTimerPicker(context, Duration(seconds: setupProvider.program.restDuration), (Duration newTimer) {
            setupProvider.setBreakTime(0, newTimer.inSeconds);
          }),
          child: _buildTimerDisplay('Break Time', setupProvider.program.restDuration, false,isPortrait: true,isLightMode: isLightMode),
        ),
        Divider(),
        GestureDetector(
          onTap: () => _showRoundsPicker(context, setupProvider.program.rounds, (int newRounds) {
            setupProvider.rounds = newRounds;
            setProgramToCustom(setupProvider, profileProvider);
          }),
          child: buildRoundDisplay(setupProvider, context,isLightMode),
        ),
      ],
    );
  }

  Widget buildLandscapeLayout(SetupProvider setupProvider, ProfileProvider profileProvider, BuildContext context,bool isLightMode) {
    final screenSize=MediaQuery.of(context).size;

    return Container(
      height: screenSize.height,
      child: Row(
        children: [
          // Left Side: Start Button
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(height: screenSize.height * .05),

                            // Profile Button
                            Container(
                              width: screenSize.width * .15,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLightMode ? colorSetupScreenMenuButtonBackgroundLight : colorSetupScreenMenuButtonBackgroundDark, // Background color
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileViewPage()));
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Minimize the space taken by the column
                                  children: [
                                    Icon(Icons.person, size: getResponsiveValueGeneral(context: context, mobileDevices: 45.0, tablets: 48.0, laptops: 48.0, desktops: 48.0, tv: 48.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark,), // Profile icon
                                    SizedBox(height: 5), // Space between icon and text
                                    Text("Profile", style: TextStyle(fontSize:getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 18.0, laptops: 18.0, desktops: 18.0, tv: 18.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark,)), // Profile text
                                  ],
                                ),
                              ),
                            ),

                            Spacer(),


                            // Program Selector Button
                            Container(

                              width: screenSize.width * .15,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLightMode ? colorSetupScreenMenuButtonBackgroundLight : colorSetupScreenMenuButtonBackgroundDark, // Background color
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                                  ),
                                ),
                                onPressed: () {
                                  _showSelectCategoryDialog();
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Minimize the space taken by the column
                                  children: [
                                    Icon(Icons.upload, size: getResponsiveValueGeneral(context: context, mobileDevices: 45.0, tablets: 48.0, laptops: 48.0, desktops: 48.0, tv: 48.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark,), // Fitness icon
                                    SizedBox(height: 5), // Space between icon and text
                                    Text("Upload", style: TextStyle(fontSize:getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 18.0, laptops: 18.0, desktops: 18.0, tv: 18.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark,)), // Program text
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenSize.height * .05,
                        ),
                        Row(
                          children: [
                            Spacer(),
                            Container(

                              width: screenSize.width * .15,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLightMode ? colorSetupScreenMenuButtonBackgroundLight : colorSetupScreenMenuButtonBackgroundDark, // Background color
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                                  ),
                                ),
                                onPressed: () {
                                  showProgramSelectorBottomSheet(context);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Minimize the space taken by the column
                                  children: [
                                    Icon(Icons.fitness_center, size: getResponsiveValueGeneral(context: context, mobileDevices: 45.0, tablets: 48.0, laptops: 48.0, desktops: 48.0, tv: 48.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark,), // Fitness icon
                                    SizedBox(height: 5), // Space between icon and text
                                    Text("Programs", style: TextStyle(fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 18.0, laptops: 18.0, desktops: 18.0, tv: 18.0), color: isLightMode ? colorSetupScreenMenuButtonIconLight : colorSetupScreenMenuButtonIconDark,)), // Program text
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),

                  ),
                  Spacer(),
                  MaterialButton(
                    onPressed: _saveSetup,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Total Time: ${_formatTime(calculateTotalDuration(setupProvider.program),true)}",
                          style: TextStyle(
                            fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 15.0, tablets: 20.0, laptops: 20.0, desktops: 20.0, tv: 20.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Start',
                          style: TextStyle(
                            fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 32.0, tablets: 40.0, laptops: 40.0, desktops: 40.0, tv: 40.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    minWidth: screenSize.width * 0.8, // Adjusted width
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: screenSize.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(  
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: isLightMode ? colorSetupScreenStartButtonBackgroundLight : colorSetupScreenStartButtonBackgroundDark,
                    textColor:  isLightMode ? colorSetupScreenStartButtonTextLight : colorSetupScreenStartButtonTextDark,
                  ),
                ],
              ),
            ),
          ),

          // Right Side: Timer Settings and Profile Button
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 2),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => _showTimerPicker(context, Duration(seconds: setupProvider.program.preparationDuration), (Duration newTimer) {
                        setupProvider.setPreparationTime(newTimer.inSeconds);
                      }),
                      child: _buildTimerDisplay('Preparation Time', setupProvider.program.preparationDuration, false, isPortrait: false,isLightMode: isLightMode),
                    ),
                    Divider(),
                    GestureDetector(
                      onTap: () => _showTimerPicker(context, Duration(seconds: setupProvider.program.workDuration), (Duration newTimer) {
                        setupProvider.setRoundTime(0, newTimer.inSeconds);
                      }),
                      child: _buildTimerDisplay('Round Time', setupProvider.program.workDuration, true, isPortrait: false,isLightMode: isLightMode),
                    ),
                    Divider(),
                    GestureDetector(
                      onTap: () => _showTimerPicker(context, Duration(seconds: setupProvider.program.restDuration), (Duration newTimer) {
                        setupProvider.setBreakTime(0, newTimer.inSeconds);
                      }),
                      child: _buildTimerDisplay('Break Time', setupProvider.program.restDuration, false, isPortrait: false,isLightMode: isLightMode),
                    ),
                    Divider(),
                    GestureDetector(
                      onTap: () => _showRoundsPicker(context, setupProvider.program.rounds, (int newRounds) {
                        setupProvider.rounds = newRounds;
                        setProgramToCustom(setupProvider, profileProvider);
                      }),
                      child: buildRoundDisplay(setupProvider, context,isLightMode),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),

          ),
        ],
      ),
    );
  }

  Widget buildRoundDisplay(SetupProvider setupProvider, BuildContext context,bool isLightMode) {
    final screenSize=MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLightMode ? colorSetupScreenCardBackgroundReverseLight : colorSetupScreenCardBackgroundReverseDark,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rounds',
            style: TextStyle(
              fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 30.0, tablets: 34.0, laptops: 34.0, desktops: 34.0, tv: 34.0),
              fontWeight: FontWeight.bold,
              color: isLightMode ? colorSetupScreenCardTextLight : colorSetupScreenCardTextDark,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 2),
          Text(
            '${setupProvider.program.rounds}',
            style: TextStyle(
              color: isLightMode ? colorSetupScreenCardTextLight : colorSetupScreenCardTextDark,
              fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 32.0, tablets: 35.0, laptops: 35.0, desktops: 35.0, tv: 35.0),
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void setProgramToCustom(SetupProvider setupProvider,ProfileProvider profileProvider){
    //setupProvider.program.name="Default Program";
    Profile profile=profileProvider.getProfile()!;
    // if(findSpecificProgramId(profile.level.programs, 0)){
    //   profile.program=setupProvider.program;
    // }
  }

  bool findSpecificProgramId(List<Program> programs,int id){
    for(var program in programs){
      if(program.id==id){
        return true;
      }
    }
    return false;
  }

  void showProgramSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      scrollControlDisabledMaxHeightRatio: 1,
      enableDrag: true,
      backgroundColor: Colors.white.withOpacity(0.2),

      builder: (context) {
        return MyDraggableSheet();
      },
    );
  }


  Widget _buildTimerDisplay(String label, int seconds,bool reverse,
      {required bool isPortrait,required bool isLightMode}) {
    final screenSize=MediaQuery.of(context).size;

    return Container(

      width: screenSize.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLightMode ? reverse ? colorSetupScreenCardBackgroundReverseLight : colorSetupScreenCardBackgroundLight : reverse ? colorSetupScreenCardBackgroundReverseDark : colorSetupScreenCardBackgroundDark,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 24.0, tablets: 26.0, laptops: 26.0, desktops: 26.0, tv: 26.0),
              fontWeight: FontWeight.bold,
              color: isLightMode ? colorSetupScreenCardTextLight : colorSetupScreenCardTextDark,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              color:isLightMode ? colorSetupScreenCardTextLight : colorSetupScreenCardTextDark,
              fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 30.0, tablets: 34.0, laptops: 34.0, desktops: 34.0, tv: 34.0),
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyDraggableSheet extends StatefulWidget {
  const MyDraggableSheet({super.key});

  @override
  State<MyDraggableSheet> createState() => _MyDraggableSheetState();
}

class _MyDraggableSheetState extends State<MyDraggableSheet> {
  Box<Database> databaseBox = Hive.box<Database>(database_box);
  final _sheet = GlobalKey();
  final _controller = DraggableScrollableController();
  bool deleteMode = false; // To toggle delete mode
  Set<int> selectedCategories = {}; // To track selected categories for deletion
  Set<Program> selectedPrograms={};
  List<Category> availableCategories = [];
  List<String> constCategoryNames=[];

  @override
  void initState() {
    super.initState();
    availableCategories = databaseBox.get(database_name)!.categories;
    constCategoryNames=setCategoryNames(databaseBox.get(database_const_name)!.categories);
  }

  List<String> setCategoryNames(List<Category> categories){
    List<String> temp=[];
    for(var category in categories){
      temp.add(category.name);
    }
    return temp;
  }


  @override
  Widget build(BuildContext context) {
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    return DraggableScrollableSheet(
      key: _sheet,
      initialChildSize: 0.5,
      maxChildSize: 1.0,
      minChildSize: 0.1,
      expand: true,
      controller: _controller,
      builder: (BuildContext context, ScrollController scrollController) {
        return DecoratedBox(

          decoration: BoxDecoration(
            color: isLightMode ? colorSetupScreenDraggableSheetBackgroundLight : colorSetupScreenDraggableSheetBackgroundDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12.0,
                spreadRadius: 3.0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Program Selector title with add and delete buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Spacer(),
                    Text(
                      'Program Selector',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? colorSetupScreenDraggableSheetTitleTextLight : colorSetupScreenDraggableSheetTitleTextDark,
                      ),
                    ),
                    Spacer(),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          deleteMode = !deleteMode; // Toggle delete mode
                          selectedCategories.clear(); // Clear selection when toggling
                          selectedPrograms.clear();
                        });
                      },
                      icon: Icon(
                        deleteMode ? Icons.close : Icons.delete,
                        color: deleteMode ? Colors.red : isLightMode ? colorSetupScreenDraggableSheetTitleTextLight : colorSetupScreenDraggableSheetTitleTextDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete selected categories button (only shows in delete mode)
              if (deleteMode && (selectedCategories.isNotEmpty || selectedPrograms.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _showDeleteConfirmationDialog, // Show confirmation dialog
                    child: Builder(
                        builder: (context) {
                          if(selectedCategories.isNotEmpty && selectedPrograms.isNotEmpty){
                            return Text("Delete Selected Objects");
                          }else if(selectedCategories.isNotEmpty && selectedPrograms.isEmpty){
                            return Text("Delete Selected Categories");
                          }else if(selectedCategories.isEmpty && selectedPrograms.isNotEmpty){
                            return Text("Delete Selected Programs");
                          }else{
                            return Text("");
                          }
                        },
                    )
                  ),
                ),
              // Expansion List
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildExpansionTile(isLightMode),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool checkCategoryNameInConstantCategoryNames(List<String> names,String checkName){
    for(var name in names){
      if(checkName == name){
        return true;
      }
    }
    return false;
  }

  Widget _buildExpansionTile(bool isLightMode) {
    SetupProvider setupProvider = Provider.of<SetupProvider>(context, listen: false);
    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          ...availableCategories.map((category) {
            bool isCategorySelected = selectedCategories.contains(category.id);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ExpansionTile(
                collapsedBackgroundColor: isLightMode ? colorSetupScreenDraggableSheetCategoryBackgroundCollapsedLight : colorSetupScreenDraggableSheetCategoryBackgroundCollapsedDark ,
                backgroundColor: isLightMode ? colorSetupScreenDraggableSheetCategoryBackgroundLight : colorSetupScreenDraggableSheetCategoryBackgroundDark ,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                enabled: (checkCategoryNameInConstantCategoryNames(constCategoryNames, category.name)) && deleteMode ? false :true,
                leading: deleteMode && (!checkCategoryNameInConstantCategoryNames(constCategoryNames, category.name))
                    ? Checkbox(
                  value: isCategorySelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedCategories.add(category.id);
                      } else {
                        selectedCategories.remove(category.id);
                      }
                    });
                  },
                )
                    : Icon(Icons.category, color: isLightMode ? colorSetupScreenDraggableSheetCategoryTextLight :colorSetupScreenDraggableSheetCategoryTextDark),
                title: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isLightMode ? colorSetupScreenDraggableSheetCategoryTextLight :colorSetupScreenDraggableSheetCategoryTextDark,
                  ),
                ),
                children: category.levels.first.name != "Custom" ? [
                  ...category.levels.map((level) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

                          backgroundColor: isLightMode ? colorSetupScreenDraggableSheetLevelBackgroundLight :colorSetupScreenDraggableSheetLevelBackgroundDark,
                          leading: Icon(Icons.leaderboard, color: isLightMode ? colorSetupScreenDraggableSheetLevelTextLight :colorSetupScreenDraggableSheetLevelTextDark),
                          title: Text(
                            level.name,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isLightMode ? colorSetupScreenDraggableSheetLevelTextLight :colorSetupScreenDraggableSheetLevelTextDark
                            ),
                          ),
                          children: [
                            ...level.programs.map((program) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isLightMode ? colorSetupScreenDraggableSheetProgramBackgroundLight :colorSetupScreenDraggableSheetProgramBackgroundDark,
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  leading: Icon(Icons.fitness_center, color: isLightMode ? colorSetupScreenDraggableSheetProgramTextLight :colorSetupScreenDraggableSheetProgramTextDark),
                                  title: Text(
                                    program.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isLightMode ? colorSetupScreenDraggableSheetProgramTextLight :colorSetupScreenDraggableSheetProgramTextDark,
                                    ),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios, color:isLightMode ? colorSetupScreenDraggableSheetProgramTextLight :colorSetupScreenDraggableSheetProgramTextDark),
                                  onTap: () {
                                    // Handle program selection
                                    setupProvider.setProgram(program);
                                    Profile profile = profileProvider.getProfile()!;
                                    profile.category = category;
                                    profile.level = level;
                                    profile.program = program;
                                    profileProvider.saveProfile(profile);
                                    print('Selected Program: ${program.name}');
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            }).toList(),
                            // Add New Program Button
                            if(!checkCategoryNameInConstantCategoryNames(constCategoryNames, category.name))...[
                              Padding(
                                padding:  EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                                child: ListTile(
                                  tileColor: Colors.black.withOpacity(0.6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  leading: Icon(Icons.add, color: Colors.green),
                                  title: Text('Add New Program',style: TextStyle(color: Colors.white),),
                                  onTap: () {
                                    _showAddProgramDialog(level); // Show dialog for new program
                                  },
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  // Add New Level Button
                  // Padding(
                  //   padding:  EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                  //   child: ListTile(
                  //     tileColor: Colors.black.withOpacity(0.6),
                  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  //     leading: Icon(Icons.add, color: Colors.green),
                  //     title: Text('Add New Level',style: TextStyle(color: Colors.white)),
                  //     onTap: () {
                  //       _showAddLevelDialog(category); // Show dialog for new level
                  //     },
                  //   ),
                  // ),
                ] :  [
                  ...category.levels.first.programs.map((program) {
                    bool isParentCategorySelected=selectedCategories.contains(category.id);
                    bool isProgramSelected = selectedPrograms.contains(program);
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isLightMode ? colorSetupScreenDraggableSheetProgramBackgroundLight :colorSetupScreenDraggableSheetProgramBackgroundDark,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        leading: deleteMode
                            ? Checkbox(
                          value: isParentCategorySelected ? true : isProgramSelected,
                          onChanged: (bool? value) {
                            setState(() {

                              if (value == true) {
                                selectedPrograms.add(program);
                              } else {
                                selectedPrograms.remove(program);
                              }
                            });
                          },
                        )
                            :Icon(Icons.fitness_center, color: isLightMode ? colorSetupScreenDraggableSheetProgramTextLight :colorSetupScreenDraggableSheetProgramTextDark),
                        title: Text(
                          program.name,
                          style: TextStyle(
                            fontSize: 16,
                            color:isLightMode ? colorSetupScreenDraggableSheetProgramTextLight :colorSetupScreenDraggableSheetProgramTextDark,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: isLightMode ? colorSetupScreenDraggableSheetProgramTextLight :colorSetupScreenDraggableSheetProgramTextDark),
                        onTap: () {
                          // Handle program selection
                          setupProvider.setProgram(program);
                          Profile profile = profileProvider.getProfile()!;
                          profile.category = category;
                          profile.level = category.levels.first;
                          profile.program = program;
                          print('Selected Program: ${program.name}');
                          profileProvider.saveProfile(profile);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                  // Add New Program Button
                  if(category.name!= "Boxing" && category.name!= "Kickboxing" && category.name!= "MMA" )...[
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                      child: ListTile(
                        tileColor: isLightMode ? colorSetupScreenDraggableSheetAddButtonBackgroundLight :colorSetupScreenDraggableSheetAddButtonBackgroundDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        leading: Icon(Icons.add, color: isLightMode ? colorSetupScreenDraggableSheetAddButtonIconLight :colorSetupScreenDraggableSheetAddButtonIconDark),
                        title: Text('Add New Program',style: TextStyle(color:isLightMode ? colorSetupScreenDraggableSheetAddButtonTextLight :colorSetupScreenDraggableSheetAddButtonTextDark),),
                        onTap: () {
                          _showAddProgramDialog(category.levels.first); // Show dialog for new program
                        },
                      ),
                    ),
                  ]
                ],
              ),
            );
          }).toList(),
          // Add New Category Button
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 4,vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color:  isLightMode ? colorSetupScreenDraggableSheetAddButtonBackgroundLight :colorSetupScreenDraggableSheetAddButtonBackgroundDark,
                borderRadius: BorderRadius.circular(15)
              ),
              child: ListTile(
                tileColor: isLightMode ? colorSetupScreenDraggableSheetAddButtonBackgroundLight :colorSetupScreenDraggableSheetAddButtonBackgroundDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                leading: Icon(Icons.add, color: isLightMode ? colorSetupScreenDraggableSheetAddButtonIconLight :colorSetupScreenDraggableSheetAddButtonIconDark),
                title: Text('Add New Category',style: TextStyle(color:isLightMode ? colorSetupScreenDraggableSheetAddButtonTextLight :colorSetupScreenDraggableSheetAddButtonTextDark),),
                onTap: () {
                  _showAddCategoryDialog(); // Show dialog for new category
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog for adding a new category
  void _showAddCategoryDialog() {
    String newCategoryName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            onChanged: (value) {
              newCategoryName = value;
            },
            decoration: InputDecoration(hintText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  availableCategories.add(
                    Category(id: availableCategories.length + 1, name: newCategoryName, levels: [Level(id: 1, name: "Custom", programs: [])]),
                  );
                  databaseBox.put(database_name, Database(categories: availableCategories));
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Dialog for adding a new level to a category
  void _showAddLevelDialog(Category category) {
    String newLevelName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Level'),
          content: TextField(
            onChanged: (value) {
              newLevelName = value;
            },
            decoration: InputDecoration(hintText: 'Level Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  category.levels.add(
                    Level(id: category.levels.length + 1, name: newLevelName, programs: []),
                  );
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Dialog for adding a new program to a level
  void _showAddProgramDialog(Level level) {
    SetupProvider setupProvider=Provider.of<SetupProvider>(context,listen: false);
    String newProgramName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Program'),
          content: TextField(
            onChanged: (value) {
              newProgramName = value;
            },
            decoration: InputDecoration(hintText: 'Program Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  level.programs.add(
                    Program(id: level.programs.length + 1, name: newProgramName,rounds: setupProvider.program.rounds,workDuration: setupProvider.program.workDuration,preparationDuration: setupProvider.program.preparationDuration,restDuration: setupProvider.program.restDuration),
                  );
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmationDialog() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Selected Categories'),
          content: Text(
            'Are you sure you want to delete the selected categories? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without action
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedObjects();
                Navigator.of(context).pop(); // Close dialog after deletion
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Delete selected categories
  void _deleteSelectedObjects() {
    ProfileProvider profileProvider =Provider.of<ProfileProvider>(context,listen: false);
    Profile profile=profileProvider.getProfile()!;
    setState(() {
      if(selectedPrograms.isNotEmpty){
        print("1");
        for(int i=0;i<availableCategories.length;i++){
          print(availableCategories[i]);
          for(int j=0;j<availableCategories[i].levels.first.programs.length;j++){
            if (selectedPrograms.contains(availableCategories[i].levels.first.programs[j])) {

              if(profile.program ==availableCategories[i].levels.first.programs[j]){
                if(availableCategories[i].levels.first.programs.length > 1){
                  profile.program= (profile.program == availableCategories[i].levels.first.programs[0]) ? availableCategories[i].levels.first.programs[1] : availableCategories[i].levels.first.programs.first;
                }else{
                  profile.category=availableCategories[0];
                  profile.level=availableCategories[0].levels.first;
                  profile.program=availableCategories[0].levels.first.programs.first;
                }

                profileProvider.saveProfile(profile);
              }
              availableCategories[i].levels.first.programs.remove(availableCategories[i].levels.first.programs[j]);

            }
          }

        }

      }
      if(selectedCategories.isNotEmpty){
        for(var selectedCategory in selectedCategories){
          if(profile.category== selectedCategory){
            profile.category = availableCategories.first;
            profileProvider.saveProfile(profile);
          }
        }
        availableCategories.removeWhere((category) => selectedCategories.contains(category.id));

      }
      databaseBox.put(database_name, Database(categories: availableCategories));

      selectedPrograms.clear();
      selectedCategories.clear(); // Clear selection after deletion
      deleteMode = false; // Exit delete mode
    });
  }
}
