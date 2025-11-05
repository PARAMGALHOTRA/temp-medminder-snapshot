import 'package:flutter/material.dart';
import 'package:medminder/models/medicine.dart';
import 'package:medminder/screens/medication_form_screen.dart';
import 'package:medminder/widgets/medication_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medminder/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Stream<List<Medicine>> _getMedicines() {
    if (user == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .orderBy('nextDose')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medicine.fromMap(doc.data(), doc.id))
            .toList());
  }

  void _addMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MedicationFormScreen()),
    );
  }

  void _editMedicine(Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationFormScreen(medicine: medicine),
      ),
    );
  }

  void _deleteMedicine(String medicineId) {
    if (user == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .doc(medicineId)
        .delete();
  }

  void _toggleTaken(Medicine medicine) async {
    if (user == null) return;

    final updatedMedicine = medicine.copyWith(
      isCompleted: !medicine.isCompleted,
      // You might want to update nextDose here based on your logic
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .doc(medicine.id)
        .update(updatedMedicine.toMap());

    if (updatedMedicine.isCompleted) {
      await NotificationService().cancelNotification(medicine.hashCode);
    } else {
      await NotificationService().scheduleNotification(
        medicine.hashCode,
        'Medication Reminder',
        'Time to take your ${medicine.name}',
        updatedMedicine.nextDose,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MedMinder',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, size: 28),
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildHeader(theme, formattedDate),
          ),
          Expanded(
            child: StreamBuilder<List<Medicine>>(
              stream: _getMedicines(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final medicines = snapshot.data!;
                return ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return MedicationTile(
                      medicine: medicine,
                      onEdit: () => _editMedicine(medicine),
                      onDelete: () => _deleteMedicine(medicine.id!),
                      onToggleTaken: () => _toggleTaken(medicine),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMedicine,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String formattedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withAlpha(50),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Meds Schedule',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: GoogleFonts.manrope(
                      color: Colors.white.withAlpha(200),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.calendar_today, color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return StreamBuilder<List<Medicine>>(
        stream: _getMedicines(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final medicines = snapshot.data!;
          final takenCount = medicines.where((m) => m.isCompleted).length;
          final totalCount = medicines.length;
          final double progress = totalCount > 0 ? takenCount / totalCount : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$takenCount of $totalCount Taken',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withAlpha(70),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://img.freepik.com/free-vector/no-data-concept-illustration_114360-616.jpg?t=st=1716924558~exp=1716928158~hmac=ba15486574f8812c3f8a42718e27a7407b328a3819543e5e408543c7b3e944b2&w=740',
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            'No medications added yet.',
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "Add Medicine" button to get started.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
