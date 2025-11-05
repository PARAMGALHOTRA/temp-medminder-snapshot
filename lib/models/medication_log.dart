import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationLog {
  final String? id;
  final String medicineName;
  final String dosage;
  final String status; // e.g., 'Taken', 'Skipped'
  final DateTime timestamp;

  MedicationLog({
    this.id,
    required this.medicineName,
    required this.dosage,
    required this.status,
    required this.timestamp,
  });

  factory MedicationLog.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return MedicationLog(
      id: doc.id,
      medicineName: data['medicineName'] ?? '',
      dosage: data['dosage'] ?? '',
      status: data['status'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
