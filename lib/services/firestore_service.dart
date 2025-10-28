import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine.dart';

class FirestoreService {
  static Stream<List<Medicine>> getMedicinesStream(String? userId) {
    if (userId == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medicine.fromMap(doc.data(), doc.id)).toList());
  }

  static Future<void> updateMedicineStatus(
      String userId, String medicineId, bool isCompleted) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(medicineId)
        .update({'isCompleted': isCompleted});
  }

  static Future<void> addMedicine(String userId, Medicine medicine) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .add(medicine.toMap());
  }

  static Future<DocumentSnapshot> getUserData(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  static Future<void> updateUserData(String userId, Map<String, dynamic> data) {
    return FirebaseFirestore.instance.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }


}
