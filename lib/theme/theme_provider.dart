import 'package:edit_image/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _mThemeData = ThemeData.light();

  ThemeData get getThemeData => _mThemeData;

  set setThemeData(ThemeData themeData) {
    _mThemeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (getThemeData == darkMode) {
      setThemeData= lightMode;
    } else {
      setThemeData=darkMode;
    }
  }
}
