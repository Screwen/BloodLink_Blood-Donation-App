import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Find_Donor extends StatefulWidget {
  const Find_Donor({super.key});

  @override
  State<Find_Donor> createState() => _Find_DonorState();
}

class _Find_DonorState extends State<Find_Donor> {
  @override
  // get locations from firebase at first
  void initState() {
    super.initState();
    fetchLocation();
  }

  //for eligible filter
  bool showOnlyEligible = true;

  //for boodtype
  String? selectedBloodGroup;
  //for locaion
  String? selectedLocation;

  //list of blood types
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
          //add 'All' at first
          locations = ['All', ...loca_sion.map((e) => e.toString())];
          locations.sort();
        });
      }
    } catch (e) {
      print('Error fetching location : $e');
    }
  }

  //query for filtering the users based n bloodtype and location
  Stream<QuerySnapshot> getfilteredquery() {
    Query query = FirebaseFirestore.instance.collection("Users");

    // 1. Eligibility Filter (Conditional)
    if (showOnlyEligible) {
      DateTime deadline = DateTime.now().subtract(const Duration(days: 120));
      Timestamp cutOffTimestamp = Timestamp.fromDate(deadline);
      query = query.where(
        "last_donation_date",
        isLessThanOrEqualTo: cutOffTimestamp,
      );
    }

    // 2. Blood Group Filter
    if (selectedBloodGroup != null) {
      query = query.where("blood_group", isEqualTo: selectedBloodGroup);
    }

    // 3. Location Filter
    if (selectedLocation != null && selectedLocation != 'All') {
      query = query.where('location', isEqualTo: selectedLocation);
    }

    return query.snapshots();
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
                          'Find Donar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Search for blood donors in your area',
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
                // Inside SliverChildListDelegate, before the Blood Group text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showOnlyEligible
                          ? 'Showing Eligible Donors'
                          : 'Showing All Users',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: showOnlyEligible
                            ? Colors.green
                            : Colors.blueGrey,
                      ),
                    ),
                    Switch(
                      value: showOnlyEligible,
                      activeColor: Color(0xFFE53935),
                      onChanged: (value) {
                        setState(() {
                          showOnlyEligible = value;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by Blood Group',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: bloodTypes.map((bloodType) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              checkmarkColor: selectedBloodGroup == bloodType
                                  ? Colors.white
                                  : Colors.black,
                              label: Text(bloodType),
                              selected: selectedBloodGroup == bloodType,
                              onSelected: (selected) {
                                setState(() {
                                  selectedBloodGroup = selected
                                      ? bloodType
                                      : null;
                                });
                              },
                              selectedColor: Color(0xFFE53935),
                              labelStyle: TextStyle(
                                color: selectedBloodGroup == bloodType
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),

                    //locatin dropdown
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      decoration: InputDecoration(
                        labelText: 'Select Location',
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Color(0xFFE53635),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                    ),

                    //user info
                    StreamBuilder(
                      stream: getfilteredquery(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final users = snapshot.data!.docs;

                          if (users.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No Donars Found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Try adjusting your filter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: users.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final data = user.data() as Map<String, dynamic>;
                              return _buildDonorCard(data);
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  //display of user info
  Widget _buildDonorCard(Map<String, dynamic> donor) {
    return Card(
      elevation: 4,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  donor['username'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.bloodtype,
                  text: donor['blood_group'],
                ),
                SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.location_on,
                  text: donor['location'],
                ),
              ],
            ),

            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text(
                              'Contact donor',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Number',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  donor['number'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Do you want to copy this number?',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFE53935),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextButton(
                                  //funtiom for copying numbers
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: donor["number"]),
                                    );
                                    Navigator.of(context).pop(); // close dialog

                                    //show dialog, that number us copied
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Number copied to clipboard",
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Copy',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },

                    //call donar
                    child: Text('Contact Donor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFE53935)),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
