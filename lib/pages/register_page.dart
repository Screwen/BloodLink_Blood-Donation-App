//register page

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTab;
  const RegisterPage({super.key, required this.onTab});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //this function runs at the start of application
  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  //for loading
  bool isLoading = false;

  //for validation of conroleers so they are not empty
  final _formkey = GlobalKey<FormState>();

  //for location
  String? selectedLocation;

  //for bloodtype
  String? selectedbloodtype;

  //list of available location
  List<String> locations = [];

  //get location from firebase
  void fetchLocation() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('AppData')
          .doc('Locations')
          .get();
      if (snapshot.exists && snapshot['List'] != null) {
        List<dynamic> loca_sion = snapshot['List'];
        setState(() {
          locations = loca_sion.map((e) => e.toString()).toList();
          locations.sort();
        });
      }
    } catch (e) {
      print('Error fetching location : $e');
    }
  }

  //blood group list
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  //text editing controller
  final emailTextcontroller = TextEditingController();
  final passwordTextcontroller = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameTextcontroller = TextEditingController();
  final bloodgroupTextcontroller = TextEditingController();
  final contact_numberTextcontroller = TextEditingController();
  final locationTextcontroller = TextEditingController();

  //signup method
  void signup() async {
    //for validation of controlers, so they are not empty
    if (!_formkey.currentState!.validate()) {
      return;
    }

    //make sure password match
    if (passwordTextcontroller.text != confirmPasswordController.text) {
      Navigator.pop(context);
      //show error to the user
      displayMessage("Passwords don't match!!");
      return;
    }

    //loading start
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      //create new users
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailTextcontroller.text,
            password: passwordTextcontroller.text,
          );

      //this makes a new collection('Users') doc for each user
      FirebaseFirestore.instance
          .collection("Users")
          .doc(
            userCredential.user!.email,
          ) //all docs in Users collection are created with their email as id
          .set({
            'username': usernameTextcontroller.text,
            'blood_group': selectedbloodtype,
            'location': selectedLocation,
            'number': contact_numberTextcontroller.text,
            'last_donation_date': Timestamp.fromDate(DateTime(2000)),
          });

      //pop loading screen
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) displayMessage(e.code);
    } finally {
      //loading stop
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //function for diasplaying a message
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
      backgroundColor: Colors.grey[300],
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  // This ensures the content stays centered if there's room,
                  // but allows scrolling if the keyboard is open.
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30), // Smaller top gap
                            // Logo
                            Icon(
                              Icons.lock,
                              size: 80, // Smaller logo to save space
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(height: 20),
                            //welcome back message
                            const Text(
                              "Let's Create An Account For You",
                              style: TextStyle(
                                fontSize: 16,
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

                            //confirm password textfield
                            MyTextField(
                              controller: confirmPasswordController,
                              hintText: 'Confirm Password',
                              obscureText: true,
                              maxlength: 32,
                              validateText: 'Confirm Password',
                            ),
                            const SizedBox(height: 10),

                            //username
                            MyTextField(
                              controller: usernameTextcontroller,
                              hintText: 'Username',
                              obscureText: false,
                              maxlength: 10,
                              validateText: 'Username',
                            ),
                            const SizedBox(height: 10),

                            //bloodtype dropdown
                            DropdownButtonFormField(
                              value: selectedbloodtype,
                              decoration: InputDecoration(
                                labelText: 'Select Bloodtype',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              dropdownColor: Color(0xFFFF8A80),

                              style: TextStyle(color: Colors.white),
                              items: bloodTypes.map((bloodtype) {
                                return DropdownMenuItem(
                                  value: bloodtype,
                                  child: Text(bloodtype),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedbloodtype = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),

                            //location dropdown
                            DropdownButtonFormField(
                              value: selectedLocation,
                              decoration: InputDecoration(
                                labelText: 'Select Location',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              dropdownColor: Color(0xFFFF8A80),
                              style: TextStyle(color: Colors.white),
                              items: locations.map((location) {
                                return DropdownMenuItem(
                                  value: location,
                                  child: Text(location),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedLocation = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),

                            //for contact number
                            MyTextField(
                              controller: contact_numberTextcontroller,
                              hintText: 'Contact Number',
                              obscureText: false,
                              maxlength: 15,
                              validateText: 'Contact Number',
                            ),
                            const SizedBox(height: 10),

                            //sign in button
                            isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : MyButton(onTab: signup, text: 'Sign up'),
                            const SizedBox(height: 25),

                            //go to register page
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: widget.onTab,
                                  child: Text(
                                    "Login now",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        255,
                                        33,
                                        149,
                                        243,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
