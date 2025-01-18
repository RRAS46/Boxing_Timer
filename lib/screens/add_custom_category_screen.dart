import 'package:boxing_timer_v1/hives/category_hive.dart';
import 'package:boxing_timer_v1/hives/level_hive.dart';
import 'package:boxing_timer_v1/hives/program_hive.dart';
import 'package:boxing_timer_v1/providers/setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:boxing_timer_v1/providers/settings_provider.dart';

class AddCategoryLevelProgramPage extends StatefulWidget {
  @override
  _AddCategoryLevelProgramPageState createState() => _AddCategoryLevelProgramPageState();
}

class _AddCategoryLevelProgramPageState extends State<AddCategoryLevelProgramPage> {
  final _categoryController = TextEditingController();
  final _levelController = TextEditingController();
  List<TextEditingController> _programControllers = [TextEditingController()];

  @override
  void dispose() {
    _categoryController.dispose();
    _levelController.dispose();
    for (var controller in _programControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Adds a new program input field
  void _addProgramField() {
    setState(() {
      _programControllers.add(TextEditingController());
    });
  }

  // Removes a specific program input field
  void _removeProgramField(int index) {
    setState(() {
      _programControllers.removeAt(index);
    });
  }




  // Collect data and add the category, level, and programs
  void _submitForm(SettingsProvider settingsProvider,BuildContext context) {
    String category = _categoryController.text;
    String level = _levelController.text;
    List<String> programs = _programControllers.map((controller) => controller.text).toList();

    if (category.isNotEmpty && level.isNotEmpty && programs.every((program) => program.isNotEmpty)) {
      settingsProvider.addCategoryLevelProgram(
        categoryName: category,
        levelName: level,
        programNames: programs,
        context: context
      );

      // Clear the form after submission
      _categoryController.clear();
      _levelController.clear();
      for (var controller in _programControllers) {
        controller.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Category, Level, and Programs Added Successfully!'),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category, Level, Programs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field for category
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Input field for level
            TextFormField(
              controller: _levelController,
              decoration: InputDecoration(
                labelText: 'Level Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // List of program input fields
            Expanded(
              child: ListView.builder(
                itemCount: _programControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _programControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Program ${index + 1}',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: _programControllers.length > 1
                            ? () => _removeProgramField(index)
                            : null, // Disable if only one field
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // Add Program Button
            ElevatedButton.icon(
              onPressed: _addProgramField,
              icon: Icon(Icons.add),
              label: Text('Add Another Program'),
            ),

            SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: () => _submitForm(settingsProvider,context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
