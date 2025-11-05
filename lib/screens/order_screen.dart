import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final isDarkMode = theme.brightness == Brightness.dark;

    final Color backgroundColor = isDarkMode ? const Color(0xFF161022) : const Color(0xFFF6F6F8);
    final Color cardColor = isDarkMode ? const Color(0xFF1F1A2D) : Colors.white;
    final Color primaryTextColor = isDarkMode ? const Color(0xFFF0F0F0) : const Color(0xFF333333);
    final Color secondaryTextColor = isDarkMode ? const Color(0xFFA0A0A0) : const Color(0xFF8E8E93);
    const Color primaryColor = Color(0xFF4A90E2);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Order Medicines',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: primaryTextColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          color: primaryTextColor,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentMedicationsCard(primaryTextColor, secondaryTextColor, cardColor, primaryColor),
            const SizedBox(height: 24),
            _buildRefillReminderCard(primaryTextColor, secondaryTextColor, primaryColor),
            const SizedBox(height: 24),
            _buildPharmacyList(primaryTextColor, secondaryTextColor, cardColor, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMedicationsCard(Color primaryTextColor, Color secondaryTextColor, Color cardColor, Color primaryColor) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Current Medications',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Paracetamol 500mg, Aspirin 75mg, Metformin 1000mg, Atorvastatin 20mg',
              style: GoogleFonts.manrope(fontSize: 16, color: secondaryTextColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text('Share List', style: GoogleFonts.manrope(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefillReminderCard(Color primaryTextColor, Color secondaryTextColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active, color: primaryColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Never Miss a Refill',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: primaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set custom reminders to get notified before you run out of any medicine.',
                      style: GoogleFonts.manrope(color: secondaryTextColor, fontSize: 14),
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
            label: Text('Set Custom Reminders', style: GoogleFonts.manrope(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyList(Color primaryTextColor, Color secondaryTextColor, Color cardColor, Color primaryColor) {
    final pharmacies = [
      {
        'name': 'Apollo Pharmacy',
        'phone': '+91 12345 67890',
        'logo': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCgzX3vPt8haLA-lQtwbqLQJE81Lbk_82Fn0YlsqD85fFG_NNiL3f0sBkkQ2wrJLaBTv_AydMxkf89jtiB3AC0R4EPL1QInWtTbD58Xkcmim7B7fRqsvdZg-NwlBspkBJqdweyV6sofx50C4KfNcK7wiqFqgW8xPK31L3W6be8MUFYAIEuYzS5xhCTtJKX-srBwqWtbPbqwJx0MR2e7ZPssnL3exO7VomAZRl1s2fUhwKFABUWprM_Uz14wn-Qp_SviLwzTe779SuLl'
      },
      {
        'name': 'MedPlus',
        'phone': '+91 98765 43210',
        'logo': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB81jHO56EkLybDtzAO7h0KhFTIuILE9Q_p77Q8Xz5heX4QzgdpXaVxUg7Q3hW952uCuEWezfivjYVhpAvEmKZVCOQJMQ1L2IbNc2MKdP__sr4sPSCbVTMtcXexw9JMnWnieSa8ai7e6KhxWKAnTgObcpBKw6FUr4kTmQnjL3HQJYLBF-T2Sbzm5xpXkEIkfLmAxuEtGswndK61PmGjLghq9B2zRtHLoOe287UW1wu-zsEnvsK48-hYTV6Bi2ufmN7gnIYZX_IyUXmR'
      },
      {
        'name': 'Netmeds',
        'phone': '+91 87654 32109',
        'logo': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBPEdpII8ekV_pjV8bej957AqY_8TjSWAOLsk1qxepv0EGEFfSsoQAgc9ug7eixKSAMe2YyDJUkIoDU4E0vvoPoXsZbqVmIRFFBIQ2LROoZmp6i-Kw9aTCChvnOhdG-QlI0kF2BzbHUpYwJB-glpW_A7hopwJFFEO2GoPVTKrsFm6whBbPjyYw17d9giWU-1o8T_O8-58PYchxM3VRBlvfw6tGtX2iOlJKIzgmJ5Q4xjBKl7j5WkXqPCVlXx7WSKwkU68dw3OKMR6f-'
      },
      {
        'name': '1mg',
        'phone': '+91 76543 21098',
        'logo': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAd3pCX7yOP_qMtEyctl6L_iT86_zipvmOO8XWj73aG8u64FXUWAn9rSgQ-1K-y-V5FMCFRHYsfl08jjAovFcf8LJUU8zfB2A6nbfHYWKov8DnbZsO089y3fmDCW8L3Hq94-NCWKRDUwbzn78V2gKiVXu05ygVtCpYuMpdBLlDxdIBQVnDO6YI1wzWC5NHj0XrhkdmsCktu-lbORl7cqtz29NLCaB_PY8fqNVECtw3rCupqFX_Kz9nj-KZG3jJVNi2P0SEVHLvjzJGr'
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
          child: Text(
            'Contact a Pharmacy',
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
          ),
        ),
        ...pharmacies.map((pharmacy) => _buildPharmacyItem(pharmacy, primaryTextColor, secondaryTextColor, cardColor, primaryColor)),
      ],
    );
  }

  Widget _buildPharmacyItem(Map<String, String> pharmacy, Color primaryTextColor, Color secondaryTextColor, Color cardColor, Color primaryColor) {
    return Card(
      color: cardColor,
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
                    style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500, color: primaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pharmacy['phone']!,
                    style: GoogleFonts.manrope(fontSize: 14, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _launchURL('tel:${pharmacy['phone']}'),
              icon: Icon(Icons.call, color: primaryColor),
            ),
            IconButton(
              onPressed: () => _launchURL('https://www.google.com/search?q=${pharmacy['name']}'),
              icon: Icon(Icons.language, color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
