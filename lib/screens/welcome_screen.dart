import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medminder/screens/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    const Color primaryColor = Color(0xFF4DB6AC);
    final Color backgroundColor = isDarkMode ? const Color(0xFF161022) : const Color(0xFFF8F9FA);
    final Color textColor = isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF424242);
    final Color textMutedColor = isDarkMode ? const Color(0xFFBDBDBD) : const Color(0xFF757575);
    final Color accentColor = isDarkMode ? const Color(0xFF66BB6A) : const Color(0xFF81C784);
    final Color featureCardBg = isDarkMode ? const Color(0xFF1E182C) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                child: TextButton(
                  onPressed: () => _navigateToHome(context),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.manrope(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 300,
                      width: 300,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBzJDRTi5ZZv1cl9Jhl16gW1SHhOJXF8KZkNdke3PA5XRMPuMxRE82g7cbZppxmas1J_LHn49a97NpgewVU6jCDJ2bHxhfiE0UV7cughQ9I1On1Ds8smEy8VPZ-Z15yLiuofioMocXt-R-auxPkxEaysjlT7msfZTXIgz3UYkFhcUB_mrCGhe-Qt__hP3DAhPdlH-OcVgv66A8Y8E2n-iwbxerGN5caGkjahN_VE14Ng-hWJfdyFsafTgx9MQ14z-vTdlThrr7P9apS'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome, Alex!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your journey to better health management starts now.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: textMutedColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildFeatureTile(
                      icon: Icons.notifications,
                      title: 'Never Miss a Dose',
                      subtitle: 'Get timely reminders for all your medications.',
                      accentColor: accentColor,
                      textColor: textColor,
                      textMutedColor: textMutedColor,
                      backgroundColor: featureCardBg,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureTile(
                      icon: Icons.check_circle,
                      title: 'Track Your Progress',
                      subtitle: 'Log your intake and monitor your health journey.',
                      accentColor: accentColor,
                      textColor: textColor,
                      textMutedColor: textMutedColor,
                      backgroundColor: featureCardBg,
                    ),
                    const SizedBox(height: 16),
                     _buildFeatureTile(
                      icon: Icons.group,
                      title: 'Care for Loved Ones',
                      subtitle: 'Manage schedules for your family members.',
                      accentColor: accentColor,
                      textColor: textColor,
                      textMutedColor: textMutedColor,
                      backgroundColor: featureCardBg,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () => _navigateToHome(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 5,
                  shadowColor: primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  'Get Started',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color textColor,
    required Color textMutedColor,
    required Color backgroundColor
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: textMutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
