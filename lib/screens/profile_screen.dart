import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medminder/providers/theme_provider.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? _appVersion;

  final _emergencyContactController = TextEditingController();
  final _doctorNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _loadUserData();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final userDoc = await FirestoreService.getUserData(user!.uid);
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _emergencyContactController.text = userData['emergencyContact'] ?? '';
          _doctorNameController.text = userData['doctorName'] ?? '';
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (user == null) return;
    final data = {
      'emergencyContact': _emergencyContactController.text,
      'doctorName': _doctorNameController.text,
    };
    await FirestoreService.updateUserData(user!.uid, data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUserData,
            tooltip: 'Save Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(theme),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Quick Actions',
                items: [
                  _buildProfileItem(
                    icon: Icons.upload_file,
                    title: 'Upload Prescription',
                    onTap: _uploadPrescription,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Settings',
                items: [
                  _buildNotificationItem(theme, themeProvider),
                  _buildDarkModeItem(theme, themeProvider),
                ],
              ),
              const SizedBox(height: 24),
              _buildHealthInfoSection(theme),
              const SizedBox(height: 24),
              _buildAboutSection(theme),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Navigate to auth screen if needed
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final displayName = user?.displayName ?? 'Jessica Linden';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'J';

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withAlpha(50),
            child: Text(initial, style: TextStyle(fontSize: 48, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(displayName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
                onPressed: () {
                  // Handle edit name
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildHealthInfoSection(ThemeData theme) {
    return _buildSection(
      title: 'Health Information',
      items: [
        _buildEditableProfileItem(
          icon: Icons.contact_emergency,
          title: 'Emergency Contact',
          controller: _emergencyContactController,
        ),
        _buildEditableProfileItem(
          icon: Icons.medical_services,
          title: 'My Doctor',
          controller: _doctorNameController,
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return _buildSection(
      title: 'About',
      items: [
        _buildProfileItem(
          icon: Icons.info,
          title: 'App Version',
          trailing: Text(_appVersion ?? 'Loading...'),
        ),
        _buildProfileItem(
          icon: Icons.shield,
          title: 'Privacy Policy',
          onTap: () => _launchURL('https://your-privacy-policy.com'),
        ),
        _buildProfileItem(
          icon: Icons.help_center,
          title: 'Help & Support',
          onTap: () => _launchURL('https://your-support-page.com'),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildEditableProfileItem({
    required IconData icon,
    required String title,
    required TextEditingController controller,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(ThemeData theme, ThemeProvider themeProvider) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.notifications, color: theme.colorScheme.primary),
      ),
      title: const Text('Notifications'),
      value: true, // Replace with actual notification status
      onChanged: (value) {
        // Handle notification toggle
      },
    );
  }

  Widget _buildDarkModeItem(ThemeData theme, ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.dark_mode, color: theme.colorScheme.primary),
      ),
      title: const Text('Dark Mode'),
      trailing: DropdownButton<ThemeMode>(
        value: themeProvider.themeMode,
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: (value) {
          if (value != null) {
            themeProvider.setThemeMode(value);
          }
        },
      ),
    );
  }

  Future<void> _uploadPrescription() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading ${pickedFile.name}...')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    } else {
      await launchUrl(uri);
    }
  }
}
