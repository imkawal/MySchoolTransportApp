import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'resetpassword.dart';
import 'profile.dart';
import 'attendance.dart';
import 'firstscreen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Set the status bar color here
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My App",
      home: FirstScreen(),
      routes: {
        '/restpass': (context) => ResetPass(),
        '/profile' : (context) => Profile(),
        '/Attendance' : (context) => Attendance(),
        '/login' : (context) => Login(),
      },
    );
  }
}
