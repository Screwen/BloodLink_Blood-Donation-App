import 'package:cloud_firestore/cloud_firestore.dart';

class DonationHelper {
  // Calculateing how many days have passed since the date in Firestore
  static int daysSince(Timestamp? lastDonation) {
    // Never donated = eligible (return a high number)
    if (lastDonation == null) return 999;

    final lastDate = lastDonation.toDate();
    final now = DateTime.now();
    return now.difference(lastDate).inDays;
  }

  // Calculateing specifically how many days are remaining
  static int daysRemaining(Timestamp? lastDonation) {
    int passed = daysSince(lastDonation);
    // If they have never donated, remaining is 0
    if (lastDonation == null) return 0;

    int remaining = 120 - passed;
    return remaining.clamp(0, 120); //SO, it stays between 0 and 120
  }

  //Gettting a  boolean for eligibility
  static bool isEligible(Timestamp? lastDonation) {
    return daysSince(lastDonation) >= 120;
  }

  // Get progress value (0.0 to 1.0) for the LinearProgressIndicator
  static double getProgress(int daysPassed) {
    if (daysPassed >= 120) return 1.0; // Full bar if eligible
    if (daysPassed <= 0) return 0.0; // Empty bar if just donated
    return daysPassed / 120.0; // Fractional progress
  }
}
