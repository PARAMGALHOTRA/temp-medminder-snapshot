import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine.dart';
import '../models/medication_log.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Medicine>> getMedicinesStream(String? userId) {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medicine.fromMap(doc.data(), doc.id)).toList());
  }

  static Stream<List<MedicationLog>> getMedicationLogStream(String? userId) {
    if (userId == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(userId)
        .collection('medication_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MedicationLog.fromFirestore(doc)).toList());
  }

  static Future<void> _logMedicationEvent(String userId, String medicineId, String status) async {
    final medDoc = await _db.collection('users').doc(userId).collection('medicines').doc(medicineId).get();
    if (medDoc.exists) {
      final medicine = Medicine.fromMap(medDoc.data()!, medDoc.id);
      final log = MedicationLog(
        medicineName: medicine.name,
        dosage: medicine.dosage,
        status: status,
        timestamp: DateTime.now(),
      );
      await _db.collection('users').doc(userId).collection('medication_logs').add(log.toFirestore());
    }
  }

  static Future<void> updateMedicineStatus(
      String userId, String medicineId, bool isCompleted) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(medicineId)
        .update({'isCompleted': isCompleted});

    if (isCompleted) {
      await _logMedicationEvent(userId, medicineId, 'Taken');
    }
  }

  static Future<void> logSkippedDoses(String userId) async {
    final querySnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .where('isCompleted', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in querySnapshot.docs) {
        final medicine = Medicine.fromMap(doc.data(), doc.id);
        if (medicine.nextDose != null && medicine.nextDose!.isBefore(DateTime.now())) {
            final log = MedicationLog(
                medicineName: medicine.name,
                dosage: medicine.dosage,
                status: 'Skipped',
                timestamp: medicine.nextDose!,
            );
            final logRef = _db.collection('users').doc(userId).collection('medication_logs').doc();
            batch.set(logRef, log.toFirestore());

            // Also update the medicine to prevent re-logging
            final medRef = _db.collection('users').doc(userId).collection('medicines').doc(doc.id);
            batch.update(medRef, {'isCompleted': true}); // Or another flag to indicate it's been processed
        }
    }
    await batch.commit();
  }


  static Future<void> addMedicine(String userId, Medicine medicine) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .add(medicine.toMap());
  }

  static Future<DocumentSnapshot> getUserData(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  static Future<void> updateUserData(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getEmergencyContact(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['emergency_contact'];
  }

  static Future<void> saveEmergencyContact(String userId, Map<String, dynamic> contact) {
    return _db.collection('users').doc(userId).set({
      'emergency_contact': contact,
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getDoctorInfo(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['my_doctor'];
  }

  static Future<void> saveDoctorInfo(String userId, Map<String, dynamic> doctor) {
    return _db.collection('users').doc(userId).set({
      'my_doctor': doctor,
    }, SetOptions(merge: true));
  }
}
