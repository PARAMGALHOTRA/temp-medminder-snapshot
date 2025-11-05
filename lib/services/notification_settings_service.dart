import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationSettingsService {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _refillRemindersKey = 'refill_reminders_enabled';
  final FirebaseFirestore _firestore;
  final String userId;

  NotificationSettingsService(this.userId)
      : _firestore = FirebaseFirestore.instance;

  Future<bool> getNotificationsEnabled() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?[_notificationsKey] ?? true;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'NotificationSettingsService.getNotificationsEnabled Firebase error: ${e.code} ${e.message}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'NotificationSettingsService.getNotificationsEnabled unexpected error: $e');
      }
      return true;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _firestore.collection('users').doc(userId).set({
      _notificationsKey: enabled,
    }, SetOptions(merge: true));
  }

  Future<bool> getRefillRemindersEnabled() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?[_refillRemindersKey] ?? true;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'NotificationSettingsService.getRefillRemindersEnabled Firebase error: ${e.code} ${e.message}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'NotificationSettingsService.getRefillRemindersEnabled unexpected error: $e');
      }
      return true;
    }
  }

  Future<void> setRefillRemindersEnabled(bool enabled) async {
    await _firestore.collection('users').doc(userId).set({
      _refillRemindersKey: enabled,
    }, SetOptions(merge: true));
  }
}
