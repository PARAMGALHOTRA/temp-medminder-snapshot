import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medminder/providers/theme_provider.dart';
import 'package:medminder/screens/auth_screen.dart';
import 'package:medminder/screens/edit_profile_screen.dart';
import 'package:medminder/screens/emergency_contact_screen.dart';
import 'package:medminder/screens/my_doctor_screen.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medminder/services/notification_settings_service.dart';
import 'package:medminder/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late NotificationSettingsService _notificationSettingsService;
  final StorageService _storageService = StorageService();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _notificationSettingsService = NotificationSettingsService(user!.uid);
      _loadNotificationSettings();
    }
  }

  Future<void> _loadNotificationSettings() async {
    final bool isEnabled = await _notificationSettingsService.getNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = isEnabled;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

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

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && user != null) {
      final File imageFile = File(image.path);
      final String? downloadUrl = await _storageService.uploadProfileImage(user!.uid, imageFile);

      if (downloadUrl != null) {
        await user!.updatePhotoURL(downloadUrl);
        await FirestoreService.updateUserData(user!.uid, {'photoURL': downloadUrl});
        setState(() {}); // Refresh the screen to show the new image
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final Color background = isDarkMode ? const Color(0xFF161022) : const Color(0xFFF8F9FA);
    final Color cardColor = isDarkMode ? const Color(0xFF1E182C) : Colors.white;
    final Color primaryText = isDarkMode ? const Color(0xFFEAE8ED) : const Color(0xFF333333);
    final Color secondaryText = isDarkMode ? const Color(0xFFA09BA6) : const Color(0xFF757575);
    const Color primaryColor = Color(0xFF4A90E2);
    const Color accentGreen = Color(0xFF50C878);
    const Color accentRed = Color(0xFFE57373);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: primaryText,
          ),
        ),
        backgroundColor: background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            color: primaryText,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user logged in.'))
          : FutureBuilder<Object>(
              future: FirestoreService.getUserData(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error loading user data.'));
                }

                final userName = user?.displayName ?? 'Jessica Linden';

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildProfileHeader(context, userName, primaryColor, primaryText),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Settings',
                      [
                        _buildSettingsItem(
                          icon: Icons.notifications,
                          text: 'Notifications',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                              _notificationSettingsService.setNotificationsEnabled(value);
                            },
                            activeThumbColor: accentGreen,
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          primaryText: primaryText,
                        ),
                        _buildSettingsItem(
                          icon: Icons.dark_mode,
                          text: 'Dark Mode',
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme(value);
                            },
                            activeThumbColor: accentGreen,
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          primaryText: primaryText,
                        ),
                      ],
                      primaryText,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Health Information',
                      [
                        _buildActionItem(
                          icon: Icons.contact_emergency,
                          text: 'Emergency Contact',
                          trailingText: 'Add Contact',
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const EmergencyContactScreen())),
                          primaryColor: accentRed,
                          cardColor: cardColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                        _buildActionItem(
                          icon: Icons.medical_services,
                          text: 'My Doctor',
                          trailingText: 'Add Info',
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDoctorScreen())),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                      ],
                      primaryText,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'About',
                      [
                        _buildSettingsItem(
                          icon: Icons.info,
                          text: 'App Version',
                          trailing: Text(
                            'v1.0.0',
                            style: GoogleFonts.manrope(fontSize: 14, color: secondaryText),
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          primaryText: primaryText,
                        ),
                        _buildActionItem(
                          icon: Icons.shield,
                          text: 'Privacy Policy',
                          onTap: () => _launchURL('https://your-privacy-policy.com'),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                        _buildActionItem(
                          icon: Icons.help_center,
                          text: 'Help & Support',
                          onTap: () => _launchURL('https://your-support-page.com'),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                      ],
                      primaryText,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Logout'),
                    )
                  ],
                );
              },
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, Color primaryColor, Color primaryText) {
    final userInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final photoURL = user?.photoURL;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: primaryColor.withAlpha(50),
              backgroundImage: (photoURL != null && photoURL.isNotEmpty) ? NetworkImage(photoURL) : null,
              child: (photoURL == null || photoURL.isEmpty)
                  ? Text(
                      userInitial,
                      style: GoogleFonts.manrope(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            setState(() {});
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.edit, color: primaryColor, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items, Color primaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E182C) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]),
          child: Column(
            children: items,
          ),
        )
      ],
    );
  }

  Widget _buildActionItem(
      {required IconData icon,
      required String text,
      String? trailingText,
      required VoidCallback onTap,
      required Color primaryColor,
      required Color cardColor,
      required Color primaryText,
      required Color secondaryText}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryText,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: GoogleFonts.manrope(fontSize: 14, color: secondaryText),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      {required IconData icon,
      required String text,
      required Widget trailing,
      required Color primaryColor,
      required Color cardColor,
      required Color primaryText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryText,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
