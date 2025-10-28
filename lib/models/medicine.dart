class Medicine {
  String? id;
  final String name;
  final String dosage;
  final String instructions;
  final DateTime? nextDose;
  final bool isCompleted;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    this.nextDose,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'nextDose': nextDose?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String id) {
    return Medicine(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      instructions: map['instructions'] ?? '',
      nextDose: map['nextDose'] != null ? DateTime.parse(map['nextDose']) : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}