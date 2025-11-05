import 'package:flutter/material.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyDoctorScreen extends StatefulWidget {
  const MyDoctorScreen({super.key});

  @override
  State<MyDoctorScreen> createState() => _MyDoctorScreenState();
}

class _MyDoctorScreenState extends State<MyDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  Future<void> _loadDoctorInfo() async {
    if (user != null) {
      final doctorInfo = await FirestoreService.getDoctorInfo(user!.uid);
      if (doctorInfo != null) {
        _nameController.text = doctorInfo['name'];
        _specialtyController.text = doctorInfo['specialty'];
        _phoneController.text = doctorInfo['phone'];
      }
    }
  }

  Future<void> _saveDoctorInfo() async {
    if (_formKey.currentState!.validate() && user != null) {
      final doctorInfo = {
        'name': _nameController.text,
        'specialty': _specialtyController.text,
        'phone': _phoneController.text,
      };
      await FirestoreService.saveDoctorInfo(user!.uid, doctorInfo);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Doctor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Doctor\'s Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a specialty';
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDoctorInfo,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
