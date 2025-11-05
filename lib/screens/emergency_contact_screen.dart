import 'package:flutter/material.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContact();
  }

  Future<void> _loadEmergencyContact() async {
    if (user != null) {
      final contact = await FirestoreService.getEmergencyContact(user!.uid);
      if (contact != null) {
        _nameController.text = contact['name'];
        _phoneController.text = contact['phone'];
        _relationController.text = contact['relation'];
      }
    }
  }

  Future<void> _saveEmergencyContact() async {
    if (_formKey.currentState!.validate() && user != null) {
      final contact = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'relation': _relationController.text,
      };
      await FirestoreService.saveEmergencyContact(user!.uid, contact);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Contact Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(labelText: 'Relation'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the relation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEmergencyContact,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
