import 'package:boxing_timer_v1/hives/category_hive.dart';
import 'package:boxing_timer_v1/hives/database_hive.dart';
import 'package:boxing_timer_v1/hives/level_hive.dart';
import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/models/profile_model.dart';
import 'package:boxing_timer_v1/models/settings_model.dart';
import 'package:boxing_timer_v1/providers/profile_provider.dart';
import 'package:boxing_timer_v1/providers/settings_provider.dart';
import 'package:boxing_timer_v1/providers/setup_provider.dart';
import 'package:boxing_timer_v1/screens/setup_screen.dart';
import 'package:boxing_timer_v1/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ProfileMakerScreen extends StatefulWidget {
  @override
  _ProfileMakerScreenState createState() => _ProfileMakerScreenState();
}

class _ProfileMakerScreenState extends State<ProfileMakerScreen> {
  var databaseBox = Hive.box<Database>(database_box);

  // Retrieve a category by name (for example, "Boxing")

  final TextEditingController usernameController = TextEditingController();
  List<Category> availableCategories =[];
  Category? selectedCategory;
  Level? selectedLevel;
  Program? selectedProgram;
  DateTime registrationDate = DateTime.now();

  @override
  void initState(){
    super.initState();
    availableCategories=databaseBox.get(database_name)!.categories;
  }



  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    bool isPortrait = orientation == Orientation.portrait;

    return Scaffold(

      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.blueAccent,
        title: Center(
          child: Text(
            'Create Your Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<Category>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Primary Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (Category? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                    selectedLevel=null;
                    selectedProgram=null;
                  });
                },
                items: availableCategories.map<DropdownMenuItem<Category>>((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Level Dropdown
              selectedCategory != null
                  ? DropdownButtonFormField<Level>(
                value: selectedLevel,
                decoration: InputDecoration(
                  labelText: 'Select Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (Level? newValue) {
                  setState(() {
                    selectedLevel = newValue;
                    selectedProgram =null;
                  });
                },
                items: selectedCategory!.levels.map<DropdownMenuItem<Level>>((Level level) {
                  return DropdownMenuItem<Level>(
                    value: level,
                    child: Text(level.name),
                  );
                }).toList(),
              )
                  : Container(),
              SizedBox(height: 20),

              // Program Dropdown
              selectedLevel != null
                  ? DropdownButtonFormField<Program>(
                value: selectedProgram,
                decoration: InputDecoration(
                  labelText: 'Select Program',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (Program? newValue) {
                  setState(() {
                    selectedProgram = newValue;
                  });
                },
                items: selectedLevel!.programs.map<DropdownMenuItem<Program>>((Program program) {
                  return DropdownMenuItem<Program>(
                    value: program,
                    child: Text(program.name),
                  );
                }).toList(),
              )
                  : Container(),
              SizedBox(height: 40),

              // Submit Button
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                        isPortrait?
                          Size(
                              MediaQuery.of(context).size.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.3, tablets: 0.4, laptops: 0.4, desktops: 0.4, tv: 0.4),
                              MediaQuery.of(context).size.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.07, tablets: 0.08, laptops: 0.08, desktops: 0.08, tv: 0.08)
                          ) : Size(
                              MediaQuery.of(context).size.width * getResponsiveValueGeneral(context: context, mobileDevices: 0.3, tablets: 0.3, laptops: 0.3, desktops: 0.3, tv: 0.3),
                              MediaQuery.of(context).size.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.12, tablets: 0.15, laptops: 0.4, desktops: 0.4, tv: 0.4)
                          )
                    )
                  ),
                  onPressed: (usernameController.text.isEmpty ||
                      selectedCategory == null ||
                      selectedLevel == null ||
                      selectedProgram == null)
                      ? null
                      : () {
                    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);

                    final username = usernameController.text;

                    Settings settings=Settings.defaultSettings;

                    profileProvider.saveProfile(Profile(
                      id: 1,
                      username: username,
                      category: selectedCategory ?? availableCategories.first,
                      level: selectedLevel ?? selectedCategory!.levels.first,
                      program: selectedProgram ?? selectedLevel!.programs.first,
                      settings: settings,
                      registrationDate: registrationDate,
                    ));


                    // Set program in SetupProvider

                    // Show success message and navigate to SetupPage
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile Created!')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetupPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
