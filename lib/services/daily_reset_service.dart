import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medminder/models/medicine.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:medminder/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyResetService {
  static const String _lastResetKey = 'last_reset_date';

  static Future<void> checkAndResetDailyMedications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDateStr = prefs.getString(_lastResetKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastResetDateStr != null) {
      final lastResetDate = DateTime.parse(lastResetDateStr);
      if (lastResetDate.isAtSameMomentAs(today)) {
        return; // Already reset today
      }
    }

    await _resetDailyMedications(userId);

    await prefs.setString(_lastResetKey, today.toIso8601String());
  }

  static Future<void> _resetDailyMedications(String userId) async {
    // First, log any skipped doses from the previous day.
    await FirestoreService.logSkippedDoses(userId);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .get();

    final batch = FirebaseFirestore.instance.batch();
    final notificationService = NotificationService();

    for (final doc in querySnapshot.docs) {
      final medicine = Medicine.fromMap(doc.data(), doc.id);
      final now = DateTime.now();
      DateTime nextDose = DateTime(
        now.year,
        now.month,
        now.day,
        medicine.nextDose!.hour,
        medicine.nextDose!.minute,
      );

      if (nextDose.isBefore(now)) {
        nextDose = nextDose.add(const Duration(days: 1));
      }

      batch.update(doc.reference, {
        'isCompleted': false,
        'nextDose': nextDose.toIso8601String(),
      });

      // Re-schedule notification
      await notificationService.scheduleNotification(
        medicine.hashCode, // Use a consistent ID
        'Time for your medication',
        'It\'s time to take your ${medicine.name}',
        nextDose,
      );
    }

    await batch.commit();
  }
}
