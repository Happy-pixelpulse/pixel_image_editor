import 'package:flutter/material.dart';

import 'homepage.dart';

class Introscreen extends StatefulWidget {
  const Introscreen({super.key});

  @override
  State<Introscreen> createState() => IntroscreenState();
}

class IntroscreenState extends State<Introscreen> {
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(seconds: 5), () {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Homepage()));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const FlutterLogo(),
    );
  }
}
