import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    // brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade400,
    primary: Colors.grey.shade300,
    secondary: Colors.grey.shade200,
      brightness: Brightness.light
  )
);




ThemeData darkMode = ThemeData(
    // brightness: Brightness.dark,
    colorScheme: ColorScheme.light(
      surface: Colors.grey.shade900,
      primary: Colors.grey.shade800,
      secondary: Colors.grey.shade700,
        brightness: Brightness.dark
    )
);
