import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationFormScreen extends StatefulWidget {
  final Medicine? medicine;

  const MedicationFormScreen({super.key, this.medicine});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _dosage;
  late String _instructions;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _name = widget.medicine?.name ?? '';
    _dosage = widget.medicine?.dosage ?? '';
    _instructions = widget.medicine?.instructions ?? '';
    _time = widget.medicine?.nextDose != null
        ? TimeOfDay.fromDateTime(widget.medicine!.nextDose!)
        : TimeOfDay.now();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final now = DateTime.now();
      final nextDose = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
      final medicine = Medicine(
        id: widget.medicine?.id,
        name: _name,
        dosage: _dosage,
        instructions: _instructions,
        nextDose: nextDose,
        isCompleted: widget.medicine?.isCompleted ?? false,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        if (widget.medicine == null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('medicines')
              .add(medicine.toMap());
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('medicines')
              .doc(medicine.id)
              .update(medicine.toMap());
        }

        await NotificationService().scheduleNotification(
          medicine.hashCode,
          'Time for your medication',
          'It\'s time to take your $_name',
          nextDose,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medication' : 'Edit Medication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _dosage,
                decoration: const InputDecoration(labelText: 'Dosage'),
                validator: (value) => value!.isEmpty ? 'Please enter a dosage' : null,
                onSaved: (value) => _dosage = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _instructions,
                decoration: const InputDecoration(labelText: 'Instructions'),
                validator: (value) => value!.isEmpty ? 'Please enter instructions' : null,
                onSaved: (value) => _instructions = value!,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Time: ${DateFormat.jm().format(DateTime(2023, 1, 1, _time.hour, _time.minute))}',
                      style: GoogleFonts.manrope(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectTime,
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.medicine == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
