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
  final _formkey = GlobalKey<FormState>();
  bool passwordObscured = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
                      obSecure: passwordObscured,
                      readOnly: false,
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
                    CheckboxListTile(
                      value: true,
                      onChanged: (value) {},
                      checkColor: const Color(0xff002233),
                      activeColor: Colors.grey,
                      title: const Text("Remeber Me"),
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

  void _login() {
    if (_formkey.currentState!.validate()) {
      if(_usernameController.text=='superAdmin@123' && _passwordController.text=='superadmin'){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(userType: 'SuperAdmin',),));
      }
      else{
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
