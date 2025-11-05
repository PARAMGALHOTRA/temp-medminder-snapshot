import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medminder/models/medicine.dart';
import 'package:medminder/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medminder/services/notification_settings_service.dart';

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
  late TimeOfDay _time;
  bool _isLoading = false;
  late NotificationSettingsService _notificationSettingsService;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notificationSettingsService = NotificationSettingsService(user.uid);
    }
    _name = widget.medicine?.name ?? '';
    _dosage = widget.medicine?.dosage ?? '';
    _time = widget.medicine?.nextDose != null
        ? TimeOfDay.fromDateTime(widget.medicine!.nextDose!)
        : const TimeOfDay(hour: 9, minute: 0);
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
      setState(() {
        _isLoading = true;
      });

      final now = DateTime.now();
      var nextDose =
          DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
      if (nextDose.isBefore(now)) {
        nextDose = nextDose.add(const Duration(days: 1));
      }

      final medicine = Medicine(
        id: widget.medicine?.id,
        name: _name,
        dosage: _dosage,
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

          // Cancel the old notification
          await NotificationService().cancelNotification(widget.medicine.hashCode);
        }

        final bool notificationsEnabled = await _notificationSettingsService.getNotificationsEnabled();
        if (notificationsEnabled) {
          await NotificationService().scheduleNotification(
            medicine.hashCode,
            'Time for your medication',
            'It\'s time to take your $_name',
            nextDose,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          label: 'Medicine Name',
                          icon: Icons.medical_services,
                          placeholder: 'e.g., Paracetamol',
                          initialValue: _name,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a name' : null,
                          onSaved: (value) => _name = value!,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'Dosage',
                          icon: Icons.scale,
                          placeholder: 'e.g., 500mg or 1 tablet',
                          initialValue: _dosage,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a dosage' : null,
                          onSaved: (value) => _dosage = value!,
                        ),
                        const SizedBox(height: 24),
                        _buildTimePicker(theme),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 120,
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            const Color(0xFF357ABD), // primary-darker
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          Text(
            'Add Medicine',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 48), // For spacing
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String placeholder,
    required String initialValue,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          validator: validator,
          onSaved: onSaved,
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Reminder Time',
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.schedule, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      DateFormat.jm().format(DateTime(2023, 1, 1, _time.hour, _time.minute)),
                      style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Icon(Icons.edit, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            shadowColor: Theme.of(context).colorScheme.primary.withAlpha(77),
          ),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          label: Text(
            'Save Medicine',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (widget.medicine != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
