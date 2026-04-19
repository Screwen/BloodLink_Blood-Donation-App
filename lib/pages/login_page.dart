//login page

import 'package:cse_project/components/button.dart';
import 'package:cse_project/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTab;
  const LoginPage({super.key, required this.onTab});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  //text editing controller
  final emailTextcontroller = TextEditingController();
  final passwordTextcontroller = TextEditingController();

  //sign user in
  void signin() async {
    //loading screen
    setState(() {
      isLoading = true;
    });

    try {
      //funtion for email and paswod sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextcontroller.text,
        password: passwordTextcontroller.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        //display error message
        return displayMessage(e.code);
      }
    } finally {
      //pop loading screen
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //function for displaying a dialogue message
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFFF8A80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  Icon(
                    Icons.lock,
                    size: 100,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 50),
                  //welcome back message
                  Text(
                    'Welcome Back, Save Lives',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 25),
                  //email textfield
                  MyTextField(
                    controller: emailTextcontroller,
                    hintText: 'Email',
                    obscureText: false,
                    maxlength: 50,
                    validateText: 'Email',
                  ),
                  const SizedBox(height: 10),
                  //password textfield
                  MyTextField(
                    controller: passwordTextcontroller,
                    hintText: 'Password',
                    obscureText: true,
                    maxlength: 32,
                    validateText: 'Password',
                  ),
                  const SizedBox(height: 10),

                  //sign in button (turns to loading if isLoading is true, loading stops after signin is completed)
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : MyButton(onTab: signin, text: 'Sign in'),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Donate Blood, Share Love',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 4),
                      //go to register page button
                      GestureDetector(
                        onTap: widget.onTab,
                        child: Text(
                          "Register now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 33, 149, 243),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
