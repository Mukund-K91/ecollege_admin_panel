import 'package:ecollege_admin_panel/reusable_widget/reusable_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecollege_admin_panel/dashboard_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordObscured = true;

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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Images/logo.png'),
                  SizedBox(height: 10),
                  ReusableTextField(
                    validator: (str) {
                      if (str!.isEmpty) {
                        return "Register Email Id is required for login";
                      }
                      return null;
                    },
                    preIcon: const Icon(FontAwesomeIcons.solidUser,
                        color: Color(0xff002233)),
                    readOnly: false,
                    title: 'Username *',
                  ),
                  SizedBox(height: 10),
                  ReusableTextField(
                    obSecure: passwordObscured,
                    readOnly: false,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password is required for login";
                      }
                      return null;
                    },
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
                    title: 'Password *',
                  ),
                  CheckboxListTile(
                    value: true,
                    onChanged: (value) {},
                    checkColor: Color(0xff002233),
                    activeColor: Colors.grey,
                    title: Text("Remeber Me"),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff002233),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(),
                              ));
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
        ],
      ),
    );
  }
}
