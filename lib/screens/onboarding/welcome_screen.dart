import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withAlpha(128),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(theme),
                const SizedBox(height: 40),
                _buildTitle(theme),
                const SizedBox(height: 20),
                _buildSubtitle(theme),
                const SizedBox(height: 60),
                _buildFeatureCards(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withAlpha(50),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Icon(
        Icons.medical_services_outlined,
        size: 60,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      'Welcome to MedMinder',
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    return Text(
      'Your personal medication assistant. Never miss a dose again!',
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(
        fontSize: 16,
        color: theme.textTheme.bodyMedium?.color?.withAlpha(128),
      ),
    );
  }

  Widget _buildFeatureCards(ThemeData theme) {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.notifications_active_outlined,
          title: 'Smart Reminders',
          description: 'Get timely notifications for your medications.',
          theme: theme,
        ),
        const SizedBox(height: 20),
        _buildFeatureCard(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory Tracking',
          description: 'Keep track of your medicine stock and get refill alerts.',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: theme.primaryColor),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
