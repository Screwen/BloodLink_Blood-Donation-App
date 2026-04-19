import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cse_project/auth/auth.dart';
import 'package:cse_project/utills/northification_service.dart';
import 'package:cse_project/pages/MyProfilePage.dart';
import 'package:cse_project/pages/chats.dart';
import 'package:cse_project/pages/find_donor_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track when the user last cleared notifications
  Timestamp lastCheckedTime = Timestamp.now();

  //current user logged in
  final currentuser = FirebaseAuth.instance.currentUser!;

  //user name
  String username = '';

  //loads first at intialization
  @override
  void initState() {
    super.initState();

    NotificationService().requestPermissions();

    // Listen to User Data
    FirebaseFirestore.instance
        .collection("Users")
        .doc(
          currentuser.email,
        ) // Make sure this is email or uid based on your DB
        .snapshots()
        // Inside HomeScreen's initState listener:
        .listen((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            final String myBloodGroup = data["blood_group"] ?? '';
            final String fetchedUsername = data["username"] ?? '';

            // FETCH THE DATE HERE
            final Timestamp? lastDonation = data["last_donation_date"];

            setState(() {
              username = fetchedUsername;
            });

            if (myBloodGroup.isNotEmpty) {
              NotificationService().startListening(
                currentuser.email!,
                myBloodGroup,
                lastDonation, // NEW PARAMETER
              );
            }
          }
        });
  }

  //sign user out
  void signOut() async {
    // Stop the listener first
    NotificationService().stopListening();

    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            leading: SizedBox(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xfffff8a80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Welcome + username
                            Text(
                              'Welcome, $username',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: StreamBuilder<QuerySnapshot>(
                                // Listen for posts newer than lastCheckedTime and NOT from the current user
                                stream: FirebaseFirestore.instance
                                    .collection('User Posts')
                                    .where(
                                      'TimeStamp',
                                      isGreaterThan: lastCheckedTime,
                                    )
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  // Count the docs (excluding our own)
                                  int unreadCount = 0;
                                  if (snapshot.hasData) {
                                    unreadCount = snapshot.data!.docs
                                        .where(
                                          (doc) =>
                                              doc['UserEmail'] !=
                                              currentuser.email,
                                        )
                                        .length;
                                  }

                                  // Wrap IconButton with Badge
                                  return Badge(
                                    isLabelVisible: unreadCount > 0,
                                    label: Text(unreadCount.toString()),
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // When clicked, reset the count to 0
                                        setState(() {
                                          lastCheckedTime = Timestamp.now();
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Let\'s make a difference together!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your Blood Saves Lives!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            pinned: true,
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),

                    //options start
                    GridView.count(
                      padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                      children: [
                        //go to chats
                        _buildQuickActionCard(
                          context,
                          icon: Icons.local_hospital,
                          label: 'Find Requests',
                          color: Colors.blue,
                          onTab: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatsPage(),
                              ),
                            );
                          },
                        ),

                        //go to  profile page
                        _buildQuickActionCard(
                          context,
                          icon: Icons.man,
                          label: 'Profile',
                          color: Colors.redAccent,
                          onTab: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ),
                            );
                          },
                        ),

                        //go to search / all user
                        _buildQuickActionCard(
                          context,
                          icon: Icons.warning,
                          label: 'Find Donors',
                          color: Colors.pink,
                          onTab: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Find_Donor(),
                              ),
                            );
                          },
                        ),

                        //sign out
                        _buildQuickActionCard(
                          context,
                          icon: Icons.location_on,
                          label: 'SignOut',
                          color: Colors.purple,
                          onTab: () {
                            signOut();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // TOTAL COUNTERS SECTION
                    const Text(
                      'Our Community Impact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. Total Users (Counts documents in "Users" collection)
                        _buildStatCounter(
                          label: "Total Users",
                          collectionName: "Users",
                          icon: Icons.people_alt_rounded,
                          color: Colors.blue,
                          isLifetime: false,
                        ),

                        // 2. Total Requests (Reads the permanent number from "GlobalStats")
                        _buildStatCounter(
                          label: "Lives Impacted",
                          collectionName: "GlobalStats",
                          icon: Icons.volunteer_activism,
                          color: Colors.red,
                          isLifetime: true,
                        ), // This tells the widget to look at the document
                      ],
                    ),

                    const SizedBox(height: 25),

                    //showing user email
                    Center(
                      child: Text(
                        "Logged in as: ${currentuser.email!}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    //SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTab,
  }) {
    return GestureDetector(
      onTap: onTab,
      child: Stack(
        children: [
          Container(
            width: 200,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 15,
                  offset: Offset(5, 5),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: Offset(-5, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              height: 6,
              width: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCounter({
    required String label,
    required String collectionName,
    required IconData icon,
    required Color color,
    bool isLifetime = false, // Add this flag
  }) {
    // If isLifetime is true, we point to the single document.
    // Otherwise, we point to the whole collection.
    dynamic stream = isLifetime
        ? FirebaseFirestore.instance
              .collection(collectionName)
              .doc('counters')
              .snapshots()
        : FirebaseFirestore.instance.collection(collectionName).snapshots();

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        String count = "0";

        if (snapshot.hasData) {
          if (isLifetime) {
            // Logic for reading the single "Int64" field
            var doc = snapshot.data as DocumentSnapshot;
            if (doc.exists) {
              count = (doc.get('total_requests') ?? 0).toString();
            }
          } else {
            // Logic for counting collection length (Users)
            var snap = snapshot.data as QuerySnapshot;
            count = snap.docs.length.toString();
          }
        }

        return Container(
          width: MediaQuery.of(context).size.width * 0.42,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
