import 'package:flutter/material.dart';

class AppEnvironment extends ChangeNotifier {
  bool _isDemoMode = true;

  bool get isDemoMode => _isDemoMode;

  void toggleMode(bool value) {
    _isDemoMode = value;
    notifyListeners();
  }
}
