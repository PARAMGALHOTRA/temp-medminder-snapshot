import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medminder/models/medicine.dart';
import 'package:intl/intl.dart';

class MedicationTile extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleTaken;

  const MedicationTile({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleTaken,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Slidable(
      key: ValueKey(medicine.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () => onDelete()),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(medicine.name,
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          subtitle: Text(
              '${medicine.dosage} - ${DateFormat.jm().format(medicine.nextDose)}'),
          trailing: Checkbox(
            value: medicine.isCompleted,
            onChanged: (value) => onToggleTaken(),
            activeColor: theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
