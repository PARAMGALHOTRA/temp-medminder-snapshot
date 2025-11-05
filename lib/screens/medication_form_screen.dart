import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medminder/models/medicine.dart';
import 'package:medminder/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medminder/services/notification_settings_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late String _frequencyType;
  late List<String> _specificDays;
  late TimeOfDay _time;
  late DateTime _startDate;
  late int _durationInDays;
  late int _inventory;
  late int _refillReminderThreshold;

  bool _isLoading = false;
  late NotificationSettingsService _notificationSettingsService;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notificationSettingsService = NotificationSettingsService(user.uid);
    }

    if (widget.medicine != null) {
      _name = widget.medicine!.name;
      _dosage = widget.medicine!.dosage;
      _frequencyType = widget.medicine!.frequencyType;
      _specificDays = widget.medicine!.specificDays;
      _time = widget.medicine!.time;
      _startDate = widget.medicine!.startDate;
      _durationInDays = widget.medicine!.durationInDays;
      _inventory = widget.medicine!.inventory;
      _refillReminderThreshold = widget.medicine!.refillReminderThreshold;
    } else {
      _name = '';
      _dosage = '';
      _frequencyType = 'daily';
      _specificDays = [];
      _time = const TimeOfDay(hour: 9, minute: 0);
      _startDate = DateTime.now();
      _durationInDays = 0;
      _inventory = 0;
      _refillReminderThreshold = 0;
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_specificDays.contains(day)) {
        _specificDays.remove(day);
      } else {
        _specificDays.add(day);
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final now = DateTime.now();
      final nextDose = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _time.hour,
        _time.minute,
      );

      final medicine = Medicine(
        id: widget.medicine?.id,
        name: _name,
        dosage: _dosage,
        frequencyType: _frequencyType,
        specificDays: _specificDays,
        time: _time,
        startDate: _startDate,
        durationInDays: _durationInDays,
        inventory: _inventory,
        refillReminderThreshold: _refillReminderThreshold,
        nextDose: nextDose.isBefore(now)
            ? nextDose.add(const Duration(days: 1))
            : nextDose,
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

          await NotificationService()
              .cancelNotification(widget.medicine.hashCode);
        }

        final bool notificationsEnabled =
            await _notificationSettingsService.getNotificationsEnabled();
        if (notificationsEnabled) {
          await NotificationService().scheduleNotification(
            medicine.hashCode,
            'Time for your medication',
            'It\'s time to take your $_name',
            medicine.nextDose,
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
            SnackBar(
              content: Text('Failed to save: $e'),
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
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Medicine Details', theme),
                  _buildTextField(
                    initialValue: _name,
                    label: 'Medicine Name',
                    icon: Icons.medication,
                    onSaved: (value) => _name = value!,
                  ),
                  _buildTextField(
                    initialValue: _dosage,
                    label: 'Dosage (e.g., 2 pills, 10ml)',
                    icon: Icons.science,
                    onSaved: (value) => _dosage = value!,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Frequency', theme),
                  _buildFrequencySelector(theme),
                  if (_frequencyType == 'specific_days')
                    _buildDaySelector(theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Schedule', theme),
                  _buildTimeSelector('Time', _time, _selectTime, theme),
                  _buildTimeSelector(
                      'Start Date', _startDate, _selectDate, theme),
                  _buildTextField(
                    initialValue: _durationInDays.toString(),
                    label: 'Duration in Days (0 for ongoing)',
                    icon: Icons.date_range,
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        _durationInDays = int.tryParse(value!) ?? 0,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Inventory & Refills', theme),
                  _buildTextField(
                    initialValue: _inventory.toString(),
                    label: 'Pill Count in Inventory',
                    icon: Icons.inventory,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _inventory = int.tryParse(value!) ?? 0,
                  ),
                  _buildTextField(
                    initialValue: _refillReminderThreshold.toString(),
                    label: 'Refill Reminder at (count)',
                    icon: Icons.notifications_active,
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        _refillReminderThreshold = int.tryParse(value!) ?? 0,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save Medicine',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Please enter a value' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildFrequencySelector(ThemeData theme) {
    return SegmentedButton<String>(
      style: SegmentedButton.styleFrom(
        fixedSize: const Size.fromHeight(48),
      ),
      segments: const [
        ButtonSegment(
          value: 'daily',
          label: Text('Daily'),
        ),
        ButtonSegment(value: 'specific_days', label: Text('Specific Days')),
        ButtonSegment(value: 'as_needed', label: Text('As Needed')),
      ],
      selected: {_frequencyType},
      onSelectionChanged: (newSelection) {
        setState(() {
          _frequencyType = newSelection.first;
        });
      },
    );
  }

  Widget _buildDaySelector(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: days.map((day) {
          final isSelected = _specificDays.contains(day);
          return FilterChip(
            label: Text(day),
            selected: isSelected,
            onSelected: (selected) => _toggleDay(day),
            showCheckmark: false,
            selectedColor: theme.colorScheme.primary,
            labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyLarge?.color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSelector(
      String label, dynamic value, VoidCallback onTap, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(
                label == 'Time' ? Icons.access_time : Icons.calendar_today),
          ),
          child: Text(
            value is TimeOfDay
                ? value.format(context)
                : DateFormat.yMMMd().format(value),
            style: GoogleFonts.manrope(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
