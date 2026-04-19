import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cse_project/utills/donation_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<QuerySnapshot>? _requestSub;

  //  Initialize the system
  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped: ${response.payload}");
      },
    );
  }

  // COMPATIBILITY LOGIC
  bool _isCompatible(String donor, String requester) {
    if (donor == requester) return true;
    if (donor == 'O-') return true;
    const map = {
      'O+': ['O+', 'A+', 'B+', 'AB+'],
      'A+': ['A+', 'AB+'],
      'A-': ['A+', 'A-', 'AB+', 'AB-'],
      'B+': ['B+', 'AB+'],
      'B-': ['B+', 'B-', 'AB+', 'AB-'],
      'AB-': ['AB+', 'AB-'],
      'AB+': ['AB+'],
    };
    return map[donor]?.contains(requester) ?? false;
  }

  // 2. Request Popup Permission
  Future<void> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();
  }

  //  Listener
  // 1. Updated Listener to include eligibility check
  void startListening(
    String currentUserEmail,
    String userBloodGroup,
    Timestamp? lastDonationDate,
  ) {
    _requestSub?.cancel();

    final DateTime sessionStart = DateTime.now();

    _requestSub = FirebaseFirestore.instance
        .collection('User Posts')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;

              final String requesterEmail = data['UserEmail'] ?? '';
              final String neededGroup = data['BloodGroup'] ?? 'Unknown';
              final Timestamp? postTime = data['TimeStamp'] as Timestamp?;

              // logic check
              bool isNewPost =
                  postTime != null && postTime.toDate().isAfter(sessionStart);
              bool isNotMe = requesterEmail != currentUserEmail;

              if (isNewPost && isNotMe) {
                // CHECK 1: Blood Compatibility
                bool bloodMatches = _isCompatible(userBloodGroup, neededGroup);

                // CHECK 2: Donation Eligibility (120 days rule)
                bool userIsEligible = DonationHelper.isEligible(
                  lastDonationDate,
                );

                if (bloodMatches && userIsEligible) {
                  _showPopup(
                    '🩸 Urgent Match Found!',
                    'A $neededGroup request was posted. You are eligible to donate!',
                  );
                }
              }
            }
          }
        });
  }

  //  Popup logic

  Future<void> _showPopup(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'blood_link_channel',
      'Blood Requests',
      channelDescription: 'Notifications for compatible blood requests',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE53935),
    );

    await _plugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  // stop listening
  void stopListening() {
    _requestSub?.cancel();
    _requestSub = null; // Clean up the reference
    debugPrint("Notification listener stopped.");
  }
}
