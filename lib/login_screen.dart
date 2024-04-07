import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:ecollege_admin_panel/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecollege_admin_panel/dashboard_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  bool passwordObscured = true;
  final _usernameController = TextEditingController(text: kDebugMode?"superadmin@123":"");
  final _passwordController = TextEditingController(text: kDebugMode?"superadmin":"");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/Images/logo.png'),
                    const SizedBox(height: 10),
                    ReusableTextField(
                      controller: _usernameController,
                      preIcon: Icon(FontAwesomeIcons.solidUser,
                          color: Color(0xff002233)),
                      readOnly: false,
                      title: 'Username',
                    ),
                    const SizedBox(height: 10),
                    ReusableTextField(
                      controller: _passwordController,
                      readOnly: false,
                      obSecure: passwordObscured,
                      preIcon: const Icon(
                        Icons.fingerprint,
                        color: Color(0xff002233),
                      ),
                      sufIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordObscured = !passwordObscured;
                          });
                        },
                        icon: passwordObscured
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                      ),
                      title: 'Password',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff002233),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () async {
                            _login();
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    if (_formkey.currentState!.validate()) {
      if (_usernameController.text == 'superadmin@123' &&
          _passwordController.text == 'superadmin') {
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool(SplashScreenState.KEYLOGIN, true);
        sharedPref.setString(SplashScreenState.KEYUSERNAME, _usernameController.text);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userType: 'Super Admin',
                userName: _usernameController.text,
              ),
            ));
      }
      // else if (_usernameController.text == 'admin@123' &&
      //     _passwordController.text == 'admin') {
      //   var sharedPref = await SharedPreferences.getInstance();
      //   sharedPref.setBool(SplashScreenState.KEYLOGIN, true);
      //   sharedPref.setString(SplashScreenState.KEYUSERNAME, 'admin@123');
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => DashboardScreen(
      //           userType: 'Admin',
      //           userName: _usernameController.text,
      //         ),
      //       ));
      // }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.white,
              shape: ContinuousRectangleBorder(),
              content: Text(
                'Invalid username or password please try again',
                style: TextStyle(color: Colors.black),
              )),
        );
      }
    }
  }
}
