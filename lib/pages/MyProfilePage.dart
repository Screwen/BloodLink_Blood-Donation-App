import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cse_project/components/textbox.dart';
import 'package:cse_project/utills/donation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // runs at start time
  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  //user who is logged in right now
  final userEmail = FirebaseAuth.instance.currentUser!;
  //all users
  final userCollection = FirebaseFirestore.instance.collection("Users");
  //list of blood group
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

  //edit fields
  Future<void> edit(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Edit $field", style: TextStyle(color: Colors.redAccent)),

        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.black),
          inputFormatters: [
            LengthLimitingTextInputFormatter(
              field == 'username'
                  ? 10
                  : field == 'number'
                  ? 15
                  : 50,
            ),
          ],
          decoration: InputDecoration(
            hintText: "Enter new $field",
            counterText: "",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) => newValue = value,
        ),

        actions: [
          //cancel button
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),

          //save button
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(context).pop(newValue),
            child: Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    //update to firestore
    if (newValue.trim().isNotEmpty) {
      //only update if there is somtheing
      await userCollection.doc(userEmail.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFFFBA80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Edit my Details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userEmail.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("User data not found"));
                }
                //get user data
                if (snapshot.hasData) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  final lastDonation =
                      userData['last_donation_date'] as Timestamp?;
                  final days = DonationHelper.daysSince(lastDonation);
                  final progress = DonationHelper.getProgress(days);
                  final bool canDonate = days >= 120;

                  return ListView(
                    children: [
                      const SizedBox(height: 30),

                      // ADDing THE PROGRESS BAR WIDGET
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Side: Title with Icon
                                Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 18,
                                      color: const Color.fromARGB(
                                        255,
                                        191,
                                        0,
                                        0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Donation Status",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: const Color.fromARGB(
                                          255,
                                          223,
                                          1,
                                          1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Right Side: Dynamic Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: canDonate
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: canDonate
                                          ? Colors.green
                                          : Colors.redAccent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    canDonate
                                        ? "Ready to Donate"
                                        : "${DonationHelper.daysRemaining(lastDonation)} Days Left",
                                    style: TextStyle(
                                      color: canDonate
                                          ? Colors.green[700]
                                          : Colors.redAccent[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12,
                                backgroundColor: Colors.grey[300],
                                color: canDonate
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20),

                        //My Details" textboxes
                        child: Text(
                          "My Details :",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFFE53935,
                            ), //Colors.black.withOpacity(0.9),
                          ),
                        ),
                      ),

                      //username
                      MyTextBox(
                        sectionName: "Username",
                        username: userData["username"],
                        onPressed: () => edit("username"),
                      ),

                      //blood group
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          right: 20,
                          left: 20,
                        ),
                        child: DropdownButtonFormField(
                          value: userData['blood_group'],
                          decoration: InputDecoration(
                            labelText: 'Select Blood Group',
                            labelStyle: TextStyle(color: Color(0xFFE53635)),
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: Color(0xFFE53635),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFFE53635),
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: Color(0xFFE53635)),
                          items: bloodTypes.map((bloodtype) {
                            return DropdownMenuItem(
                              value: bloodtype,
                              child: Text(bloodtype),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            await userCollection.doc(userEmail.email).update({
                              'blood_group': value,
                            });
                          },
                        ),
                      ),
                      //location dropdown
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          right: 20,
                          left: 20,
                        ),
                        child: DropdownButtonFormField(
                          value: userData['location'],
                          decoration: InputDecoration(
                            labelText: 'Select Location',
                            labelStyle: TextStyle(color: Color(0xFFE53635)),
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: Color(0xFFE53635),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFFE53635),
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: Color(0xFFE53635)),
                          items: locations.map((location) {
                            return DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            await userCollection.doc(userEmail.email).update({
                              'location': value,
                            });
                          },
                        ),
                      ),

                      /*//location
                      MyTextBox(
                        sectionName: "Location",
                        username: userData["location"],
                        onPressed: () => edit("location"),
                      ),*/

                      //number
                      MyTextBox(
                        sectionName: "Number",
                        username: userData["number"],
                        onPressed: () => edit("number"),
                      ),

                      const SizedBox(height: 50),

                      //showing user email
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                          ),
                          child: Text(
                            "Logged in as: ${userEmail.email!}",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
