import 'package:audioplayers/audioplayers.dart';
import 'package:boxing_timer_v1/models/sound_model.dart';
import 'package:boxing_timer_v1/screens/setup_screen.dart';
import 'package:boxing_timer_v1/themes.dart';
import 'package:boxing_timer_v1/values.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:boxing_timer_v1/providers/settings_provider.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _roundVolume = 0.5;
  double _breakVolume = 0.5;
  double _intervalVolume = 0.5;

  @override
  void initState(){
    super.initState();
    _initializeVolumeLevels();
  }

  Future<void> _initializeVolumeLevels() async {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    // Fetch the system volume levels initially
    _roundVolume = await settingsProvider.getRoundVolume();
    _breakVolume = await settingsProvider.getBreakVolume();
    _intervalVolume = await settingsProvider.getIntervalVolume();

    setState(() {});  // Update the UI with the fetched values
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);

    bool isLightMode = Theme.of(context).brightness == Brightness.light;


    return Container(
      child: Column(
        children: [
          Center(
            child: Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 40.0, tablets: 50.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                color: isLightMode ? colorProfileScreenTitleLight : colorProfileScreenTitleDark,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Card(
              color: isLightMode ? colorProfileScreenSettingsCardBackgroundLight : colorProfileScreenSettingsCardBackgroundDark,
              elevation: 10,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSoundSwitch(context,isLightMode),
                  const SizedBox(height: 20),
                  _buildRoundStartEndSoundPicker(context,isLightMode),
                  const SizedBox(height: 20),
                  _buildBreakStartEndSoundPicker(context,isLightMode),
                  const SizedBox(height: 20),
                  _buildThreeSecondWarningSwitch(context,isLightMode),
                  // const SizedBox(height: 20),
                  // _buildVoiceAnnouncementsSwitch(context),
                  // const SizedBox(height: 20),
                  // _buildVolumeControl(context),
                  const SizedBox(height: 20),
                  _buildVibrationAlertSwitch(context,isLightMode),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text('Dark Mode'),
                    value: settingsProvider.themeMode == ThemeMode.dark,
                    onChanged: (bool isDarkMode) {
                      // Toggle the theme mode
                      settingsProvider.toggleTheme();
                    },
                    secondary: Icon(
                      settingsProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSwitch(BuildContext context,bool isLightMode) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SwitchListTile(
      title:  Text(
          'Enable Sound',
        style: TextStyle(
          color: isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark,
          fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 22.0, laptops: 25.0, desktops: 25.0, tv: 25.0)
        ),
      ),
      value: settingsProvider.soundEnabled,
      onChanged: (value) {
        settingsProvider.setSoundEnabled(value);

        settingsProvider.setThreeSecondWarningEnabled(value);
      },
    );
  }

  Widget _buildRoundStartEndSoundPicker(BuildContext context,bool isLightMode) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return ListTile(
      title: Text(
        'Round Start/End Sound',
        style: TextStyle(
          color: settingsProvider.soundEnabled ? isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark : Colors.grey,  // Grayed out when sound is disabled
          fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 22.0, laptops: 25.0, desktops: 25.0, tv: 25.0)
        ),
      ),
      subtitle: Text(
        settingsProvider.selectedRoundSound.name,
        style: TextStyle(
          color: settingsProvider.soundEnabled ? isLightMode ? colorProfileScreenSettingsCardSubTextLight : colorProfileScreenSettingsCardSubTextDark : Colors.grey,  // Grayed out subtitle when sound is disabled
          fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 15.0, tablets: 16.0, laptops: 25.0, desktops: 25.0, tv: 25.0)

        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: settingsProvider.soundEnabled ? isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark : Colors.grey,  // Grayed out icon
      ),
      onTap: settingsProvider.soundEnabled
          ? () {
        _showSoundPickerDialog(context, (sound) {
          settingsProvider.setRoundStartEndSound(sound);

        },isLightMode);
      }
          : () {
        // Provide a visual cue that interaction is disabled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enable sound to select a round start/end sound.')),
        );
      },
    );
  }
  Widget _buildBreakStartEndSoundPicker(BuildContext context,bool isLightMode) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return ListTile(
      title: Text(
        'Break Start/End Sound',
        style: TextStyle(
          color: settingsProvider.soundEnabled ? isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark : Colors.grey,  // Grayed out when sound is disabled
          fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 22.0, laptops: 25.0, desktops: 25.0, tv: 25.0)

        ),
      ),
      subtitle: Text(
        settingsProvider.selectedBreakSound.name,
        style: TextStyle(
          color: settingsProvider.soundEnabled ? isLightMode ? colorProfileScreenSettingsCardSubTextLight : colorProfileScreenSettingsCardSubTextDark : Colors.grey,  // Grayed out subtitle when sound is disabled
          fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 15.0, tablets: 16.0, laptops: 25.0, desktops: 25.0, tv: 25.0)
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: settingsProvider.soundEnabled ? isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark : Colors.grey,  // Grayed out icon
      ),
      onTap: settingsProvider.soundEnabled
          ? () {
        // Only allow interaction if sound is enabled
        _showSoundPickerDialog(context, (sound) {
          setState(() {
            settingsProvider.setBreakStartEndSound(sound);
          });
        },isLightMode);
      }
          : null,  // Disable interaction when sound is disabled
    );
  }


  Widget _buildThreeSecondWarningSwitch(BuildContext context,bool isLightMode) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SwitchListTile(
      title: Text(
          'Enable 3-Second Warning',
        style: TextStyle(
            color:isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark,
            fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 22.0, laptops: 25.0, desktops: 25.0, tv: 25.0)
        ),
      ),
      value: settingsProvider.threeSecondWarningEnabled,
      onChanged: settingsProvider.soundEnabled
          ?(value) {
        settingsProvider.setThreeSecondWarningEnabled(value);
      } : null,
    );
  }

  Widget _buildVolumeControl(BuildContext context,bool isLightMode) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return ListTile(
      title:  Text(
        'Volume Control',
        style: TextStyle(
          color: settingsProvider.soundEnabled? isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark : Colors.grey,
          fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 22.0, laptops: 25.0, desktops: 25.0, tv: 25.0)
        ),
      ),
      subtitle: Slider(
        activeColor: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,
        value: settingsProvider.volumeLevel,
        min: 0,
        max: 1,
        divisions: 10,
        label: (settingsProvider.volumeLevel * 100).toStringAsFixed(0) + '%',
        onChanged:settingsProvider.soundEnabled
            ? (value) {
          settingsProvider.setVolumeLevel(value);
          settingsProvider.setIntervalVolume(value);
        } : null,
      ),
    );
  }

  Widget _buildVibrationAlertSwitch(BuildContext context,bool isLightMode) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SwitchListTile(
      title: Text(
          'Enable Vibration Alerts',
        style: TextStyle(
            color: isLightMode ? colorProfileScreenSettingsCardMainTextLight : colorProfileScreenSettingsCardMainTextDark,
            fontSize:  getResponsiveValueGeneral(context: context, mobileDevices: 16.0, tablets: 22.0, laptops: 25.0, desktops: 25.0, tv: 25.0)
        ),
      ),
      value: settingsProvider.vibrationAlertEnabled,
      onChanged: (value) {
        settingsProvider.setVibrationAlertEnabled(value);
      },
    );
  }

  Widget _buildVoiceAnnouncementsSwitch(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SwitchListTile(
      title: const Text('Enable Voice Announcements'),
      value: settingsProvider.voiceAnnouncementsEnabled,
      onChanged: settingsProvider.soundEnabled
          ?(value) {
        settingsProvider.setVoiceAnnouncementsEnabled(value);
      } : null,
    );
  }
  void _previewSound(String path) {
    if (path.isNotEmpty) {
      // Logic to play sound preview based on the selected path
      // You can use a sound player library like 'audioplayers' to play the sound
      final player = AudioPlayer();
      player.play(AssetSource("sounds/${path}"));  // Assumes path is a valid sound file
    } else {
      // Provide feedback for "None"
      print("No sound selected.");
    }
  }
  // Function to display sound picker dialog
  void _showSoundPickerDialog(BuildContext context, Function(Sound) onSoundSelected,bool isLightMode) {
    int i=0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isLightMode ? colorShowDialogBackgroundLight : colorShowDialogBackgroundDark,
          title: const Text('Select Sound'),
          content: Container(
            height: 200,  // Adjusted height for better display
            child: ListView(
              children: [
                Sound(name: 'Bell', path: "boxing_bell_sound_v1.m4a"),
                Sound(name: 'Whistle', path: "boxing_bell_sound_v2.m4a"),
                Sound(name: 'Gong', path: "boxing_bell_sound_v3.m4a"),
              ].map((sound) {
                i++;

                return GestureDetector(
                  onTap: () {
                    onSoundSelected(sound);

                    Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(2),
                    margin:  EdgeInsets.symmetric(vertical: 2),
                    color: isLightMode ? colorProfileScreenProfileCardDividerLight : colorProfileScreenProfileCardDividerDark,

                    child: Row(
                      children: [
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("$i) ${sound.name}",style: TextStyle(color: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,fontSize: 16),),
                        ),
                        Spacer(),
                        IconButton(
                         icon: Icon(Icons.play_arrow,color: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,),
                          onPressed: () {
                            _previewSound(sound.path);  // Preview sound before selection
                          },

                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }


}

