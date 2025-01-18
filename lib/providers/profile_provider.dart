import 'package:boxing_timer_v1/values.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:boxing_timer_v1/models/profile_model.dart';

class ProfileProvider with ChangeNotifier {
  Box<Profile> _profileBox=Hive.box<Profile>(profile_box);




  Future<void> saveProfile(Profile profile) async {
    await _profileBox.put(profile_name, profile);
    print('Profile saved: ${profile.username}'); // Debug log
    notifyListeners();
  }

  Profile? getProfile() {
    Profile? profile = _profileBox.get(profile_name);
    print('Profile retrieved: ${profile?.username}'); // Debug log
    return profile;
  }

  // Check if the profile exists
  bool get isProfileAvailable {
    return _profileBox.containsKey(profile_name);
  }

  // Update profile username
  Future<void> updateUsername(String username) async {
    final profile = getProfile();
    if (profile != null) {
      profile.username = username;
      await saveProfile(profile);
    }
  }

  // Delete profile
  Future<void> deleteProfile() async {
    await _profileBox.delete(profile_name);
    notifyListeners();
  }
}
