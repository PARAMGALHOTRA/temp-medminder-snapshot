import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medminder/models/medicine.dart';
import 'package:medminder/screens/medication_form_screen.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Order Medicines',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          color: theme.colorScheme.onSurface,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Medicine>>(
            stream: FirestoreService.getMedicinesStream(user?.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(theme);
              }

              final medicines = snapshot.data!;
              final medicationNames =
                  medicines.map((m) => '${m.name} ${m.dosage}').join(', ');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCurrentMedicationsCard(
                      theme, medicationNames),
                  const SizedBox(height: 24),
                  _buildRefillReminderCard(theme),
                  const SizedBox(height: 24),
                  _buildPharmacyList(theme),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.medication_liquid,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            'Your Medicine Cabinet is Empty',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your medicines to easily track and reorder them.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MedicationFormScreen()),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Your First Medicine',
              style: GoogleFonts.manrope(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationsCard(
      ThemeData theme, String medications) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Current Medications',
              style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              medications,
              style: GoogleFonts.manrope(
                  fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(153)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text('Share List',
                  style: GoogleFonts.manrope(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefillReminderCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active, color: theme.colorScheme.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Never Miss a Refill',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set custom reminders to get notified before you run out of any medicine.',
                      style: GoogleFonts.manrope(
                          color: theme.colorScheme.onSurface.withAlpha(153), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_calendar, color: Colors.white, size: 20),
            label: Text('Set Custom Reminders',
                style: GoogleFonts.manrope(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyList(ThemeData theme) {
    final pharmacies = [
      {
        'name': 'Apollo Pharmacy',
        'phone': '+91 12345 67890',
        'logo':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCgzX3vPt8haLA-lQtwbqLQJE81Lbk_82Fn0YlsqD85fFG_NNiL3f0sBkkQ2wrJLaBTv_AydMxkf89jtiB3AC0R4EPL1QInWtTbD58Xkcmim7B7fRqsvdZg-NwlBspkBJqdweyV6sofx50C4KfNcK7wiqFqgW8xPK31L3W6be8MUFYAIEuYzS5xhCTtJKX-srBwqWtbPbqwJx0MR2e7ZPssnL3exO7VomAZRl1s2fUhwKFABUWprM_Uz14wn-Qp_SviLwzTe779SuLl'
      },
      {
        'name': 'MedPlus',
        'phone': '+91 98765 43210',
        'logo':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB81jHO56EkLybDtzAO7h0KhFTIuILE9Q_p77Q8Xz5heX4QzgdpXaVxUg7Q3hW952uCuEWezfivjYVhpAvEmKZVCOQJMQ1L2IbNc2MKdP__sr4sPSCbVTMtcXexw9JMnWnieSa8ai7e6KhxWKAnTgObcpBKw6FUr4kTmQnjL3HQJYLBF-T2Sbzm5xpXkEIkfLmAxuEtGswndK61PmGjLghq9B2zRtHLoOe287UW1wu-zsEnvsK48-hYTV6Bi2ufmN7gnIYZX_IyUXmR'
      },
      {
        'name': 'Netmeds',
        'phone': '+91 87654 32109',
        'logo':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBPEdpII8ekV_pjV8bej957AqY_8TjSWAOLsk1qxepv0EGEFfSsoQAgc9ug7eixKSAMe2YyDJUkIoDU4E0vvoPoXsZbqVmIRFFBIQ2LROoZmp6i-Kw9aTCChvnOhdG-QlI0kF2BzbHUpYwJB-glpW_A7hopwJFFEO2GoPVTKrsFm6whBbPjyYw117d9giWU-1o8T_O8-58PYchxM3VRBlvfw6tGtX2iOlJKIzgmJ5Q4xjBKl7j5WkXqPCVlXx7WSKwkU68dw3OKMR6f-'
      },
      {
        'name': '1mg',
        'phone': '+91 76543 21098',
        'logo':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAd3pCX7yOP_qMtEyctl6L_iT86_zipvmOO8XWj73aG8u64FXUWAn9rSgQ-1K-y-V5FMCFRHYsfl08jjAovFcf8LJUU8zfB2A6nbfHYWKov8DnbZsO089y3fmDCW8L3Hq94-NCWKRDUwbzn78V2gKiVXu05ygVtCpYuMpdBLlDxdIBQVnDO6YI1wzWC5NHj0XrhkdmsCktu-lbORl7cqtz29NLCaB_PY8fqNVECtw3rCupqFX_Kz9nj-KZG3jJVNi2P0SEVHLvjzJGr'
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
          child: Text(
            'Contact a Pharmacy',
            style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface),
          ),
        ),
        ...pharmacies.map((pharmacy) =>
            _buildPharmacyItem(pharmacy, theme)),
      ],
    );
  }

  Widget _buildPharmacyItem(
      Map<String, String> pharmacy, ThemeData theme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(pharmacy['logo']!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy['name']!,
                    style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pharmacy['phone']!,
                    style: GoogleFonts.manrope(
                        fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(153)),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _launchURL('tel:${pharmacy['phone']}'),
              icon: Icon(Icons.call, color: theme.colorScheme.primary),
            ),
            IconButton(
              onPressed: () => _launchURL(
                  'https://www.google.com/search?q=${pharmacy['name']}'),
              icon: Icon(Icons.language, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
