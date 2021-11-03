import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messageapp/mqtt_connection.dart';
import 'package:messageapp/screens/chat_screen.dart';
import 'package:messageapp/screens/login_screen.dart';
import 'package:messageapp/screens/newgroup_screen.dart';
import 'package:messageapp/screens/newgroupname_screen.dart';
import 'package:messageapp/screens/otp_screen.dart';
import 'package:messageapp/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MQTTClientWrapper()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Send Message",
      home: const SplashScreen(),
      routes: {
        'loginscreen': (context) => const LoginScreen(),
        'chatscreen': (context) => const ChatScreen(),
        'newgroupscreen': (context) => const NewGroupScreen(),
        'newgroupnamescreen': (context) => const NewGroupNameScreen(),
        'homepage': (context) => const MyHomePage(),
        'otpscreen': (context) => const otpscreen()
      },
    );
  }
}
