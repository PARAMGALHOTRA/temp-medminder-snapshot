import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  String? id;
  final String name;
  final String dosage;
  final String frequencyType; // 'daily', 'specific_days', 'as_needed'
  final List<String> specificDays; // e.g., ['Mon', 'Wed', 'Fri']
  final TimeOfDay time;
  final DateTime startDate;
  final int durationInDays; // 0 for ongoing
  final int inventory; // 0 for not tracked
  final int refillReminderThreshold; // 0 for no reminder
  final DateTime nextDose;
  final bool isCompleted;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequencyType,
    this.specificDays = const [],
    required this.time,
    required this.startDate,
    this.durationInDays = 0,
    this.inventory = 0,
    this.refillReminderThreshold = 0,
    required this.nextDose,
    this.isCompleted = false,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequencyType,
    List<String>? specificDays,
    TimeOfDay? time,
    DateTime? startDate,
    int? durationInDays,
    int? inventory,
    int? refillReminderThreshold,
    DateTime? nextDose,
    bool? isCompleted,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequencyType: frequencyType ?? this.frequencyType,
      specificDays: specificDays ?? this.specificDays,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      durationInDays: durationInDays ?? this.durationInDays,
      inventory: inventory ?? this.inventory,
      refillReminderThreshold: refillReminderThreshold ?? this.refillReminderThreshold,
      nextDose: nextDose ?? this.nextDose,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequencyType': frequencyType,
      'specificDays': specificDays,
      'time_hour': time.hour,
      'time_minute': time.minute,
      'startDate': Timestamp.fromDate(startDate),
      'durationInDays': durationInDays,
      'inventory': inventory,
      'refillReminderThreshold': refillReminderThreshold,
      'nextDose': Timestamp.fromDate(nextDose),
      'isCompleted': isCompleted,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String id) {
    return Medicine(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequencyType: map['frequencyType'] ?? 'daily',
      specificDays: List<String>.from(map['specificDays'] ?? []),
      time: TimeOfDay(
          hour: map['time_hour'] ?? 0, minute: map['time_minute'] ?? 0),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationInDays: map['durationInDays'] ?? 0,
      inventory: map['inventory'] ?? 0,
      refillReminderThreshold: map['refillReminderThreshold'] ?? 0,
      nextDose: (map['nextDose'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
