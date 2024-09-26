import 'package:flutter/material.dart';

import 'homepage.dart';

class Introscreen extends StatefulWidget {
  const Introscreen({super.key});

  @override
  State<Introscreen> createState() => IntroscreenState();
}

class IntroscreenState extends State<Introscreen> {
  @override
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
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height:double.infinity,
          child: Image.asset(
            'assets/logo 2.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      bottomNavigationBar: const Text(
        'Powered By Pixel Pulse Consultancy',
        textAlign: TextAlign.center,
      ),
    );
  }
}
