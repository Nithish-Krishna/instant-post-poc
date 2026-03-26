import 'package:flutter/material.dart';

class UserSettingsProvider extends ChangeNotifier {
  String _instagramUsername = 'thecrumbco';
  String _profilePictureUrl = ''; // Empty string means use default asset

  String get instagramUsername => _instagramUsername;
  String get profilePictureUrl => _profilePictureUrl;

  void updateSettings({String? username, String? profilePic}) {
    if (username != null) _instagramUsername = username;
    if (profilePic != null) _profilePictureUrl = profilePic;
    notifyListeners();
  }
}
