import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonationRequestScreen extends StatefulWidget {
  const DonationRequestScreen({super.key});

  @override
  State<DonationRequestScreen> createState() => _DonationRequestScreenState();
}

class _DonationRequestScreenState extends State<DonationRequestScreen> {
  //current user thats logged in
  final currentUser = FirebaseAuth.instance.currentUser!;
  //for amount
  final amount_controller = TextEditingController();
  //for location
  final Location_controller = TextEditingController();
  //for number
  final Number_controller = TextEditingController();

  //post message
  void postMessage() async {
    if (_formKey.currentState!.validate() && selectedBloodGroup != null) {
      //store in firebase
      try {
        await FirebaseFirestore.instance.collection("User Posts").add({
          'UserEmail': currentUser.email,
          'BloodGroup': selectedBloodGroup,
          'BloodAmount': amount_controller.text.isEmpty
              ? null
              : amount_controller.text,
          'Location': Location_controller.text,
          'PhoneNumber': Number_controller.text,
          'Message': buildDonationMessage(),
          'IntrestedUsers': [],
          'TimeStamp': Timestamp.now(),
        });

        // Increment the lifetime counter in 'GlobalStats'
        // This ensures the counter ONLY increases, even if you delete posts later.
        await FirebaseFirestore.instance
            .collection('GlobalStats')
            .doc('counters')
            .update({'total_requests': FieldValue.increment(1)});

        //clear the textfield
        amount_controller.clear();
        Location_controller.clear();
        Number_controller.clear();
        _notesController.clear();

        Navigator.pop(context); // go back after submit
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else if (selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a blood group")),
      );
    }
  }

  //custom donation message
  String buildDonationMessage() {
    String message = """Blood Group: $selectedBloodGroup\n""";

    if (amount_controller.text.isNotEmpty) {
      message += "Amount: ${amount_controller.text}\n";
    }
    message +=
        """Location: ${Location_controller.text}\nPhone number: ${Number_controller.text}\n""";

    if (_notesController.text.isNotEmpty) {
      message += _notesController.text;
    }
    return message;
  }

  //for blood group
  String? selectedBloodGroup;
  final _formKey = GlobalKey<FormState>();

  //additinal notes
  final TextEditingController _notesController = TextEditingController();
  //list of bloodtypes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
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
                    colors: [Color(0xFFE53935), Color(0xFFFF8A80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create Donation Request',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Help someone in need',
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
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Blood Type Needed",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),

                    //bloodtype selector in grids
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: bloodTypes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedBloodGroup = bloodTypes[index];
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: selectedBloodGroup == bloodTypes[index]
                                  ? Color(0xFFE53935)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedBloodGroup == bloodTypes[index]
                                    ? Color(0xFFE53935)
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                bloodTypes[index],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: selectedBloodGroup == bloodTypes[index]
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),

                //needed info
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      //contact number
                      _buildTextFormField(
                        controller: Number_controller,
                        label: "Contact Number ",
                        icon: Icons.local_hospital,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the contact number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      //location
                      _buildTextFormField(
                        controller: Location_controller,
                        label: "Location ",
                        icon: Icons.location_on,
                        suffixIcon: Icons.my_location,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      //blood amount
                      _buildTextFormField(
                        controller: amount_controller,
                        label: "Blood Amount (bags) Optional",
                        icon: Icons.bloodtype,
                      ),
                      SizedBox(height: 16),

                      //aditional notes
                      _buildTextFormField(
                        controller: _notesController,
                        label: "Additional Notes",
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),

      //sumbit button
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: postMessage,
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: Color(0xFF5E3935),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            "Submit Donation Request",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    IconData? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: Theme.of(context).primaryColor),
                //does not do anything for now
                onPressed: () {},
              )
            : null,
      ),
      validator: validator,
    );
  }
}
