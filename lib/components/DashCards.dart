import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Dashcards extends StatefulWidget {
  final String name;
  final String number;
  final String donorEmail;
  final Timestamp? lastDonationDate;
  final String postID;

  const Dashcards({
    super.key,
    required this.name,
    required this.number,
    required this.donorEmail,
    required this.postID,
    this.lastDonationDate,
  });

  @override
  State<Dashcards> createState() => _DashcardsState();
}

class _DashcardsState extends State<Dashcards> {
  bool _isAlreadyDone = false;

  @override
  void initState() {
    super.initState();
    _checkIfDone();
  }

  // It runs whenever the parent sends new data
  @override
  void didUpdateWidget(covariant Dashcards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastDonationDate != oldWidget.lastDonationDate) {
      _checkIfDone();
    }
  }

  void _checkIfDone() {
    if (widget.lastDonationDate != null) {
      DateTime lastDate = widget.lastDonationDate!.toDate();
      DateTime now = DateTime.now();

      setState(() {
        _isAlreadyDone =
            lastDate.year == now.year &&
            lastDate.month == now.month &&
            lastDate.day == now.day;
      });
    } else {
      setState(() {
        _isAlreadyDone = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showContactDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Contact Donor'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    // Button is disabled if _isAlreadyDone is true
                    onPressed: _isAlreadyDone
                        ? null
                        : () => _showConfirmDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAlreadyDone
                          ? Colors.grey
                          : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isAlreadyDone ? 'Completed' : 'Confirm Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Matches Contact Dialog
          title: const Text(
            "Confirm Donation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donor Name',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 16, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 16),
              const Text(
                "Mark this donation as complete? This will update the donor's last donation date.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                // Using the same Red/Green logic but matching the Contact button style
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final now = Timestamp.now();

                  try {
                    //Update the Global User Record
                    await FirebaseFirestore.instance
                        .collection("Users")
                        .doc(widget.donorEmail)
                        .update({'last_donation_date': now});

                    //Update the "User Posts" document manually
                    final postRef = FirebaseFirestore.instance
                        .collection("User Posts")
                        .doc(widget.postID);

                    await FirebaseFirestore.instance.runTransaction((
                      transaction,
                    ) async {
                      DocumentSnapshot postSnapshot = await transaction.get(
                        postRef,
                      );

                      if (postSnapshot.exists) {
                        List<dynamic> interestedUsers = List.from(
                          postSnapshot.get('IntrestedUsers') ?? [],
                        );

                        int index = interestedUsers.indexWhere(
                          (u) => u['email'] == widget.donorEmail,
                        );

                        if (index != -1) {
                          interestedUsers[index]['last_donation_date'] = now;
                          transaction.update(postRef, {
                            'IntrestedUsers': interestedUsers,
                          });
                        }
                      }
                    });

                    if (mounted) {
                      setState(() => _isAlreadyDone = true);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Donation confirmed and list updated!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Contact donor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact Number',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.number,
                style: const TextStyle(fontSize: 16, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Do you want to copy this number?',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  final messenger = ScaffoldMessenger.of(context);
                  Clipboard.setData(ClipboardData(text: widget.number));
                  Navigator.of(context).pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Number copied to clipboard"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Copy',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
