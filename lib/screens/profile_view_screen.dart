import 'package:boxing_timer_v1/providers/settings_provider.dart';
import 'package:boxing_timer_v1/screens/settings_screen.dart';
import 'package:boxing_timer_v1/screens/setup_screen.dart';
import 'package:boxing_timer_v1/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:boxing_timer_v1/models/profile_model.dart';
import 'package:boxing_timer_v1/providers/profile_provider.dart';

class ProfileViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    Profile? profile = profileProvider.getProfile();

    var orientation = MediaQuery.of(context).orientation;
    bool isPortrait = orientation == Orientation.portrait;
    isPortrait ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]) : SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

    bool isLightMode = Theme.of(context).brightness == Brightness.light;


    if(profile == null){
      Navigator.popAndPushNamed(context, '/');
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLightMode ? colorProfileScreenBackgroundLight : colorProfileScreenBackgroundDark,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero, // Remove any default padding
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * getResponsiveValueGeneral(context: context, mobileDevices: 0.07, tablets: 0.04, laptops: 0.7, desktops: 0.7, tv: 0.7)),

            // Top navigation with back button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  IconButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(isLightMode ? colorProfileScreenBackButtonBackgroundLight : colorProfileScreenBackButtonBackgroundDark),
                    ),
                    padding: EdgeInsets.all(2),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.keyboard_arrow_left, size: getResponsiveValueGeneral(context: context, mobileDevices: 50.0, tablets: 60.0, laptops: 25.0, desktops: 25.0, tv: 25.0), color: isLightMode ? colorProfileScreenBackButtonIconLight : colorProfileScreenBackButtonIconDark),
                  ),
                  Spacer(),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.005),

            // Profile check and content
            profile == null
                ? Container()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 40.0, tablets: 50.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                      color: isLightMode ? colorProfileScreenTitleLight : colorProfileScreenTitleDark,
                    ),
                  ),
                ),
                _buildProfileCard(profile,context,isLightMode), // Profile card UI
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    color: isLightMode ? colorProfileScreenDividerLight : colorProfileScreenDividerDark,
                    thickness: 1.5,
                  ),
                ),
                SizedBox(height: 20),

                // Placeholder for the Settings page UI
                SettingsPage(),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    color: isLightMode ? colorProfileScreenDividerLight : colorProfileScreenDividerDark,
                    thickness: 1.5,
                  ),
                ),
                SizedBox(height: 20),

                _buildEditButton(context,isLightMode),
                SizedBox(height: 15),
                _buildDeleteButton(context, profileProvider,isLightMode),

                SizedBox(height: 20),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                //   child: Divider(
                //     color: isLightMode ? colorProfileScreenDividerLight : colorProfileScreenDividerDark,
                //     thickness: 1.5,
                //   ),
                // ),
                // SizedBox(height: 20),
                // //
                // // _buildInfoButton(context,isLightMode),
                // // // Edit and Delete buttons
                // // SizedBox(height: 20),
                Center(
                  child: Text(
                    '© 2024 Publisher RRAS. All Rights Reserved.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSoundSwitch(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return SwitchListTile(
      title: const Text('Enable Sound'),
      value: settingsProvider.soundEnabled,
      onChanged: (value) {
        settingsProvider.setSoundEnabled(value);
      },
    );
  }

  // Profile details within a premium-looking card (with gold border)
  Widget _buildProfileCard(Profile profile,BuildContext context,bool isLightMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child:Card(
        color: isLightMode ? colorProfileScreenProfileCardBackgroundLight : colorProfileScreenProfileCardBackgroundDark, // Dark background for contrast
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueGrey.shade700, width: 2), // Modern boxing style
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(
            vertical: getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
            horizontal: getResponsiveValueGeneral(context: context, mobileDevices: 15.0, tablets: 20.0, laptops: 25.0, desktops: 25.0, tv: 25.0)
          ), // More padding for premium feel
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Profile Avatar or Icon
              CircleAvatar(

                radius: getResponsiveValueGeneral(context: context, mobileDevices: 40.0, tablets: 50.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                backgroundColor: isLightMode ? colorProfileScreenProfileCardCircleAvatarBackgroundLight : colorProfileScreenProfileCardCircleAvatarBackgroundDark,
                child: Icon(
                  Icons.person,
                  size: getResponsiveValueGeneral(context: context, mobileDevices: 52.0, tablets: 62.0, laptops: 55.0, desktops: 55.0, tv: 55.0),
                  color: isLightMode ? colorProfileScreenProfileCardCircleAvatarIconLight : colorProfileScreenProfileCardCircleAvatarIconDark,
                ),
              ),
              SizedBox(height: 20), // Space after avatar
              Text(
                profile.username,
                style: TextStyle(
                  color: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,
                  fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 20.0, tablets: 25.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10),
              Divider(
                color: isLightMode ? colorProfileScreenProfileCardDividerLight : colorProfileScreenProfileCardDividerDark,
                thickness: 1.5,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 20),
              _buildProfileItem(
                icon: Icons.category,
                label: 'Category',
                value: profile.category.name,
                color:isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,
                iconBackground: Colors.greenAccent.withOpacity(0.2), // Subtle color change
                context: context,
                isLightMode: isLightMode
              ),
              SizedBox(height: 20),
              _buildProfileItem(
                icon: Icons.bar_chart,
                label: 'Level',
                value: profile.level.name,
                color: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,
                iconBackground: Colors.purpleAccent.withOpacity(0.2), // Different background
                context: context,
                isLightMode: isLightMode
              ),
              SizedBox(height: 20),
              _buildProfileItem(
                icon: Icons.fitness_center,
                label: 'Program',
                value: profile.program.name,
                color: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,
                iconBackground: Colors.orangeAccent.withOpacity(0.2), // Keep it consistent
                context: context,
                isLightMode: isLightMode
              ),
            ],
          ),
        ),
      ),

    );
  }

  // Profile Item Row
  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconBackground,
    required BuildContext context,
    required bool isLightMode
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: getResponsiveValueGeneral(context: context, mobileDevices: 30.0, tablets: 35.0, laptops: 25.0, desktops: 25.0, tv: 25.0)),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(), // Boxing style with uppercase text
              style: TextStyle(
                fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 14.0, tablets: 20.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                color: isLightMode ? colorProfileScreenProfileCardSubTextLight : colorProfileScreenProfileCardSubTextDark,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4),
            Container(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: getResponsiveValueGeneral(context: context, mobileDevices: 18.0, tablets: 22.0, laptops: 25.0, desktops: 25.0, tv: 25.0),
                  fontWeight: FontWeight.w900,
                  color: isLightMode ? colorProfileScreenProfileCardMainTextLight : colorProfileScreenProfileCardMainTextDark,
                  letterSpacing: 1.0,
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context,bool isLightMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/edit_profile');
          },
          icon: Icon(
            Icons.edit,
            color: isLightMode ? colorProfileScreenDeleteButtonTextLight : colorProfileScreenDeleteButtonTextDark,
            size: getResponsiveValueGeneral(
              context: context,
              mobileDevices: 30.0,
              tablets: 35.0,
              laptops: 30.0,
              desktops: 30.0,
              tv: 30.0,
            ),
          ),
          label: Text(
            'Edit Profile',
            style: TextStyle(
              color: isLightMode ? colorProfileScreenDeleteButtonTextLight : colorProfileScreenDeleteButtonTextDark,
              fontWeight: FontWeight.w600,
              fontSize: getResponsiveValueGeneral(
                context: context,
                mobileDevices: 18.0,
                tablets: 22.0,
                laptops: 20.0,
                desktops: 20.0,
                tv: 20.0,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: getResponsiveValueGeneral(
                context: context,
                mobileDevices: 18.0,
                tablets: 25.0,
                laptops: 22.0,
                desktops: 22.0,
                tv: 22.0,
              ),
            ),
            backgroundColor: isLightMode ? colorProfileScreenEditButtonBackgroundLight : colorProfileScreenEditButtonBackgroundDark ,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context,bool isLightMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/info_page');
          },
          icon: Icon(
            Icons.info_outline,
            color: isLightMode ? colorProfileScreenInfoButtonTextLight : colorProfileScreenInfoButtonTextDark,
            size: getResponsiveValueGeneral(
              context: context,
              mobileDevices: 26.0,
              tablets: 35.0,
              laptops: 30.0,
              desktops: 30.0,
              tv: 30.0,
            ),
          ),
          label: Text(
            'About Designer',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLightMode ? colorProfileScreenInfoButtonTextLight : colorProfileScreenInfoButtonTextDark,
              fontSize: getResponsiveValueGeneral(
                context: context,
                mobileDevices: 18.0,
                tablets: 22.0,
                laptops: 20.0,
                desktops: 20.0,
                tv: 20.0,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLightMode ? colorProfileScreenInfoButtonBackgroundLight : colorProfileScreenInfoButtonBackgroundDark,
            padding: EdgeInsets.symmetric(
              vertical: getResponsiveValueGeneral(
                context: context,
                mobileDevices: 14.0,
                tablets: 25.0,
                laptops: 22.0,
                desktops: 22.0,
                tv: 22.0,
              ),
            ),
            
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }


  Widget _buildDeleteButton(
      BuildContext context, ProfileProvider profileProvider,bool isLightMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: isLightMode ? colorShowDialogBackgroundLight : colorShowDialogBackgroundDark,
                title: Text(
                  'Delete Profile',
                  style: TextStyle(
                    color: isLightMode ? colorShowDialogTextLight : colorShowDialogTextDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete your profile? This action cannot be undone.',
                  style: TextStyle(
                    color: isLightMode ? colorShowDialogTextLight : colorShowDialogTextDark,
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      profileProvider.deleteProfile();
                      Navigator.of(context).pushReplacementNamed('/');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile deleted successfully.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: isLightMode ? colorShowDialogTextLight : colorShowDialogTextDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          icon: Icon(
            Icons.delete_forever,
            size: getResponsiveValueGeneral(
              context: context,
              mobileDevices: 30.0,
              tablets: 35.0,
              laptops: 30.0,
              desktops: 30.0,
              tv: 30.0,
            ),
            color: isLightMode ? colorProfileScreenDeleteButtonTextLight : colorProfileScreenDeleteButtonTextDark,
          ),
          label: Text(
            'Delete Profile',
            style: TextStyle(
              color:isLightMode ? colorProfileScreenDeleteButtonTextLight : colorProfileScreenDeleteButtonTextDark,
              fontWeight: FontWeight.w600,
              fontSize: getResponsiveValueGeneral(
                context: context,
                mobileDevices: 18.0,
                tablets: 22.0,
                laptops: 20.0,
                desktops: 20.0,
                tv: 20.0,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: getResponsiveValueGeneral(
                context: context,
                mobileDevices: 18.0,
                tablets: 25.0,
                laptops: 22.0,
                desktops: 22.0,
                tv: 22.0,
              ),
            ),
            backgroundColor: isLightMode ? colorProfileScreenDeleteButtonBackgroundLight : colorProfileScreenDeleteButtonBackgroundDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }

}
