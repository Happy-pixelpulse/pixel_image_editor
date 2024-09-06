import 'package:edit_image/homepage.dart';
import 'package:edit_image/introScreen.dart';
import 'package:edit_image/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  //debugRepaintRainbowEnabled = true;
  runApp(
    ChangeNotifierProvider(
        create: (context) => ThemeProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).getThemeData,
      home:
      Homepage(),
       //Introscreen(),
    );
  }
}
