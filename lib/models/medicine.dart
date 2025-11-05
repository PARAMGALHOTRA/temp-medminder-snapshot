class Medicine {
  String? id;
  final String name;
  final String dosage;
  final DateTime? nextDose;
  final bool isCompleted;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    this.nextDose,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'nextDose': nextDose?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String id) {
    return Medicine(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      nextDose: map['nextDose'] != null ? DateTime.parse(map['nextDose']) : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
