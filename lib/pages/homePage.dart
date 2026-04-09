import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cse_project/auth/auth.dart';
import 'package:cse_project/northifiacation/northification_service.dart';
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

    // 1. Ask for permission
    NotificationService().requestPermissions();

    // 2. Start the blood request listener
    NotificationService().startListening(currentuser.email!);

    //fetch username from firebase
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentuser.email)
        .snapshots()
        .listen((doc) {
          if (doc.exists) {
            setState(() {
              username = doc["username"] ?? '';
            });
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
                                // 1. Listen for posts newer than lastCheckedTime and NOT from the current user
                                stream: FirebaseFirestore.instance
                                    .collection('User Posts')
                                    .where(
                                      'TimeStamp',
                                      isGreaterThan: lastCheckedTime,
                                    )
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  // 2. Count the docs (excluding our own)
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

                                  // 3. Wrap IconButton with Badge
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
                                        // 4. When clicked, reset the count to 0
                                        setState(() {
                                          lastCheckedTime = Timestamp.now();
                                        });

                                        // Optional: Navigate to your requests/notifications page here
                                        // Navigator.push(...);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            /*CircleAvatar(
                              backgroundColor: Colors.white24,
                              //icon buttton(does nothing for now)
                              child: IconButton(
                                icon: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),*/
                            // IconButton
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
                    SizedBox(height: 50),

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
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          
        },
        backgroundColor: Color(0xFFE53935),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Donate Now',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),*/
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
}
