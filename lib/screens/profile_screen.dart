import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medminder/providers/theme_provider.dart';
import 'package:medminder/screens/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:medminder/services/notification_settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late NotificationSettingsService _notificationSettingsService;
  bool _notificationsEnabled = true;
  bool _refillRemindersEnabled = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _notificationSettingsService = NotificationSettingsService(user!.uid);
      _loadSettings();
    }
  }

  void _loadSettings() async {
    final notifications = await _notificationSettingsService.getNotificationsEnabled();
    final refills = await _notificationSettingsService.getRefillRemindersEnabled();
    setState(() {
      _notificationsEnabled = notifications;
      _refillRemindersEnabled = refills;
    });
  }

  Future<void> _updateNotifications(bool value) async {
    await _notificationSettingsService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updateRefillReminders(bool value) async {
    await _notificationSettingsService.setRefillRemindersEnabled(value);
    setState(() {
      _refillRemindersEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await FirebaseAuth.instance.signOut();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User data not found.'));
                }

                final userData = snapshot.data!.data()!;
                final String name = userData['name'] ?? 'N/A';
                final String email = user!.email ?? 'N/A';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileHeader(name, email, theme),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Settings', theme),
                      _buildSettingsTile(
                        'Notifications',
                        _notificationsEnabled,
                        _updateNotifications,
                        Icons.notifications_outlined,
                        theme,
                      ),
                      _buildSettingsTile(
                        'Refill Reminders',
                        _refillRemindersEnabled,
                        _updateRefillReminders,
                        Icons.inventory_2_outlined,
                        theme,
                      ),
                      _buildSettingsTile(
                        'Dark Mode',
                        themeProvider.themeMode == ThemeMode.dark,
                        (value) => themeProvider.toggleTheme(),
                        Icons.dark_mode_outlined,
                        theme,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Account Actions', theme),
                      _buildInfoCard('Delete Account', 'Permanently delete your account and all associated data.', Icons.delete_forever, Colors.red, () { /* Implement delete account */ }, theme),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProfileHeader(String name, String email, ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.primaryColor,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '',
            style: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(email, style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
      ),
    );
  }

  Widget _buildSettingsTile(String title, bool value, ValueChanged<bool> onChanged, IconData icon, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: theme.primaryColor),
        activeTrackColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: iconColor)),
        subtitle: Text(subtitle, style: GoogleFonts.manrope(color: Colors.grey[600])),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
