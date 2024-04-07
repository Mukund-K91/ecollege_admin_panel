import 'package:ecollege_admin_panel/dashboard_screen.dart';
import 'package:ecollege_admin_panel/internet_connection_wrapper.dart';
import 'package:ecollege_admin_panel/result.dart';
import 'package:ecollege_admin_panel/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'eCollege Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff002233)),
        ),
        home://StudentResultTable(program: "BCA", programTerm: "Sem - 6", division: "C", acYear: "23-24")
        DashboardScreen()
        );
  }
}
