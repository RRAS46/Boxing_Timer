import 'package:boxing_timer_v1/hives/category_hive.dart';
import 'package:boxing_timer_v1/hives/database_hive.dart';
import 'package:boxing_timer_v1/hives/level_hive.dart';
import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/providers/setup_provider.dart';
import 'package:boxing_timer_v1/values.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:boxing_timer_v1/providers/profile_provider.dart';
import 'package:boxing_timer_v1/models/profile_model.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  Box<Database> databaseBox = Hive.box<Database>(database_box);
  List<Category> availableCategories = [];

  bool _isEditingUsername = false;
  Category? _selectedCategory;
  Level? _selectedLevel;
  Program? _selectedProgram;

  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    availableCategories = databaseBox.get(database_name)!.categories;
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    Profile? profile = profileProvider.getProfile();

    var orientation = MediaQuery.of(context).orientation;
    bool isPortrait = orientation == Orientation.portrait;

    if (profile != null) {
      _usernameController.text = profile.username;
      _selectedCategory = profile.category;
      _selectedLevel = profile.level;
      _selectedProgram = profile.program;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: profile == null
            ? Center(
          child: Text(
            'No profile found.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        )
            : ListView(
          children: [
            SizedBox(height: 20),

            // Editable Username
            _buildSectionTitle('Username'),
            _buildEditableUsername(profileProvider),
            SizedBox(height: 30),

            // Category Dropdown
            _buildSectionTitle('Category'),
            _buildCategoryDropdownField(profile),
            SizedBox(height: 30),

            // Level Dropdown
            _buildSectionTitle('Level'),
            _buildLevelDropdownField(profile),
            SizedBox(height: 30),

            // Program Dropdown
            _buildSectionTitle('Program'),
            _buildProgramDropdownField(profile),
            SizedBox(height: 50),

            // Save and Cancel Buttons
            _buildSaveButton(profileProvider),
            SizedBox(height: 15),
            _buildCancelButton(context, profileProvider),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section Title for consistency
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  // Editable username with clear tap-to-edit functionality
  Widget _buildEditableUsername(ProfileProvider profileProvider) {
    return TextField(
      controller: _usernameController,
      autofocus: false,
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          profileProvider.updateUsername(value);
          setState(() {
            _isEditingUsername = false;
          });
        }
      },
      decoration: InputDecoration(
        hintText: 'Enter your username',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  Widget _buildCategoryDropdownField(Profile profile) {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      onChanged: (Category? newValue) {
        int tempLevelId = profile.level.id;
        int tempProgramId = profile.program.id;
        setState(() {
          profile.category = newValue!;
          profile.level = profile.category.levels[tempLevelId];
          profile.program = profile.level.programs[tempProgramId];
        });
      },
      items: availableCategories
          .map<DropdownMenuItem<Category>>((Category category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
    );
  }

  Widget _buildLevelDropdownField(Profile profile) {
    return DropdownButtonFormField<Level>(
      value: _selectedLevel,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      onChanged: (Level? newValue) {
        int tempProgramId = profile.program.id;
        setState(() {
          profile.level = newValue!;
          profile.program = profile.level.programs[tempProgramId];
        });
      },
      items: _selectedCategory!.levels.map<DropdownMenuItem<Level>>((Level level) {
        return DropdownMenuItem<Level>(
          value: level,
          child: Text(level.name),
        );
      }).toList(),
    );
  }

  Widget _buildProgramDropdownField(Profile profile) {
    return DropdownButtonFormField<Program>(
      value: _selectedProgram,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      onChanged: (Program? newValue) {
        setState(() {
          profile.program = newValue!;
        });
      },
      items: _selectedLevel!.programs.map<DropdownMenuItem<Program>>((Program program) {
        return DropdownMenuItem<Program>(
          value: program,
          child: Text(program.name),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(ProfileProvider profileProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          SetupProvider setupProvider =
          Provider.of<SetupProvider>(context, listen: false);

          if (_usernameController.text.isNotEmpty &&
              _selectedCategory != null &&
              _selectedLevel != null &&
              _selectedProgram != null) {
            profileProvider.saveProfile(
              Profile(
                id: 1,
                username: _usernameController.text,
                category: _selectedCategory!,
                level: _selectedLevel!,
                program: _selectedProgram!,
                settings: profileProvider.getProfile()!.settings,
                registrationDate: DateTime.now(),
              ),
            );
            setupProvider.setProgram(_selectedProgram!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.save),
        label: Text('Save Profile'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, ProfileProvider profileProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
            Icons.cancel,
          color: Colors.red.shade700,
        ),
        label: Text(
            'Cancel',
          style: TextStyle(
            color: Colors.red.shade700,

          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
