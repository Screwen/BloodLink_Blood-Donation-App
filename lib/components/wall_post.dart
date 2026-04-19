//wall_post.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cse_project/components/Intrested_button.dart';
import 'package:cse_project/components/dashboard_button.dart';
import 'package:cse_project/components/delete_button.dart';
import 'package:cse_project/pages/dashboard.dart';
import 'package:cse_project/utills/donation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user; //post maker's email
  final String postID;
  final Timestamp timeStamp;
  final List<Map<String, dynamic>> intrestedUsers; //the postID of a single post
  //list that contains intrested donors
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postID,
    required this.intrestedUsers,
    required this.timeStamp,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  @override
  void initState() {
    super.initState();
    isIntrested = widget.intrestedUsers.any(
      (user) => user['email'] == currentUser.email,
    );
  }

  //timestamp format

  String format_timeStamp(Timestamp timeStamp) {
    DateTime postDate = timeStamp.toDate();
    String formattedtime = DateFormat('hh:mm a').format(postDate);
    return "${postDate.day}/${postDate.month}/${postDate.year} $formattedtime";
  }

  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isIntrested = false;

  void goToDashboardfile() {
    //go to dashboard page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Dashboard(postID: widget.postID)),
    );
  }

  //function to delete posts
  void DeletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: Text("Are you sure you want to delete this post"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              //delete post
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postID)
                  .delete()
                  .then((value) => print("Post Deleted"))
                  .catchError(
                    (error) => print("Failed to delete post: $error"),
                  );
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  //toggle intrested
  void toggleIntrested() async {
    // 1. Fetch user data to check donation date
    final userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .get();

    Timestamp? lastDonation = userDoc.data()?['last_donation_date'];
    int days = DonationHelper.daysSince(lastDonation);

    // 2. Block action if not eligible
    if (days < 120 && !isIntrested) {
      // !isIntrested means they are trying to click it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You must wait 120 days to donate again. ($days days passed)",
          ),
        ),
      );
      return; // STOP the function here
    }

    setState(() {
      isIntrested = !isIntrested;
    });

    //Accessing the document in Firebase
    DocumentReference postRef = await FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postID);

    final userData = {
      "email": currentUser.email,
      "number": userDoc.data()?["number"] ?? "",
    };
    if (isIntrested) {
      //if it is liked, add the users info to the 'intrestes' field of the post
      postRef.update({
        "IntrestedUsers": FieldValue.arrayUnion([userData]),
      });
    } else {
      //otherwise, delete the users info to the 'intrestes' field of the post
      postRef.update({
        "IntrestedUsers": FieldValue.arrayRemove([userData]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //message and user
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Emergency Blood Requests",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.warning_rounded,
                      color: Color(0xFFF53935).withOpacity(0.8),
                      size: 25,
                    ),
                  ],
                ),

                //user
                Text(
                  widget.user,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                //user message
                Text(widget.message),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        //Intrested button/Donate/Respond to request
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: (!(widget.user == currentUser.email))
                              ? IntrestedButton(
                                  ontab: toggleIntrested,
                                  isIntrested: isIntrested,
                                )
                              : SizedBox.shrink(),
                        ),
                        //only show button to (the person who posted == the person whois logged in )
                        if (widget.user == currentUser.email)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: DashboardButton(ontab: goToDashboardfile),
                          ),
                      ],
                    ),

                    //timestamp
                    Text(
                      format_timeStamp(widget.timeStamp),
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //delete button
          if (widget.user == currentUser.email)
            SizedBox(width: 30, child: DeleteButton(ontab: DeletePost)),
        ],
      ),
    );
  }
}
