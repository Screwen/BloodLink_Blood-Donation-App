import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<QuerySnapshot>? _requestSub;

  // 1. Initialize the system
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
        // This runs when a user taps the notification
        print("Notification tapped: ${response.payload}");
      },
    );
  }

  // 2. Request Popup Permission (Required for Android 13+)
  Future<void> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();
  }

  // 3. The Listener (Wires up to your "User Posts" database)
  void startListening(String currentUserEmail) {
    _requestSub?.cancel(); // Clear existing listener if any

    // We only notify for posts created AFTER the app was opened
    final DateTime sessionStart = DateTime.now();

    _requestSub = FirebaseFirestore.instance
        .collection('User Posts')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            // Trigger only for NEW documents added to Firestore
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;

              final String requesterEmail = data['UserEmail'] ?? '';
              final String bloodGroup = data['BloodGroup'] ?? 'Unknown';
              final Timestamp? time = data['TimeStamp'] as Timestamp?;

              // Logic: Don't notify me about my own posts
              if (requesterEmail != currentUserEmail &&
                  time != null &&
                  time.toDate().isAfter(sessionStart)) {
                _showPopup(
                  '🩸 Blood Required: $bloodGroup',
                  'New request at ${data['Location'] ?? 'a nearby hospital'}.',
                );
              }
            }
          }
        });
  }

  // 4. The actual Popup logic
  Future<void> _showPopup(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'blood_link_channel',
      'Blood Requests',
      channelDescription: 'Notifications for new blood donation requests',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  // Stop listening (use when logging out)
  void stopListening() {
    _requestSub?.cancel();
  }
}
