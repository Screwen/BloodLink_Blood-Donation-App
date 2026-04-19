import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cse_project/components/DashCards.dart';
import 'package:cse_project/pages/chats.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final String postID;

  const Dashboard({super.key, required this.postID});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //go to home page
  void goToHomePAge() {
    //go to profile
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChatsPage()),
    );
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
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'People who wanted to donate',
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

          //dashcards/user info
          SliverFillRemaining(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // No data or document doesn't exist
                else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("No data found"));
                } else {
                  final doc = snapshot.data!;
                  final users = List<Map<String, dynamic>>.from(
                    doc['IntrestedUsers'] ?? [],
                  );

                  return ListView.builder(
                    itemCount: users.length,

                    itemBuilder: (context, index) {
                      final user = users[index];
                      final email = user["email"];
                      final number = user["number"];

                      final dynamic rawDate = user["last_donation_date"];
                      final Timestamp? lastDonationDate = rawDate is Timestamp
                          ? rawDate
                          : null;

                      // Inside Dashboard.dart -> ListView.builder
                      return Padding(
                        padding: const EdgeInsets.all(8.0),

                        child: Dashcards(
                          name: email,
                          number: number,
                          donorEmail: email,
                          lastDonationDate: lastDonationDate,
                          postID: widget.postID,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
