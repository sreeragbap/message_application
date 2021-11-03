import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, 'loginscreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Card(
            color: Colors.transparent,
            elevation: 30,
            child: Text(
              "Message App",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          CircularProgressIndicator(
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topRight,
              colors: [Color(0xff2E86C1), Color(0xffFDFEFE)])),
    ));
  }
}
