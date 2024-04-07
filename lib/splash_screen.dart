import 'dart:async';

import 'package:ecollege_admin_panel/dashboard_screen.dart';
import 'package:ecollege_admin_panel/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static const String KEYLOGIN = "login";
  static const String KEYUSERNAME = 'username';

  @override
  void initState() {
    super.initState();
    whereToGo();
    // Add any initialization code here, such as loading data or performing checks
    // For example, you can use Future.delayed to simulate loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Set the background color of the splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Lottie.network(
                  'https://lottie.host/7f53280c-f962-4b21-b587-dd9636143de3/WR4W5183Ll.json'),
            ),
            CircularProgressIndicator(
              semanticsLabel: "Loading...",
            ),
            // Optional: Add a loading indicator
          ],
        ),
      ),
    );
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(KEYLOGIN);
    String userType;
    Timer(
      Duration(seconds: 1),
      () {
        if (isLoggedIn != null) {
          if (isLoggedIn) {
            var username=sharedPref.getString(KEYUSERNAME);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(userType: 'Super Admin',userName: username,),
                ));
            print('${username}');
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          }
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      },
    );
  }
}
