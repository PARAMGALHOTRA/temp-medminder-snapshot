import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medminder/models/medicine.dart';
import 'package:medminder/screens/order_screen.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:medminder/theme/app_theme.dart';
import 'package:medminder/utils/app_texts.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String _currentTip = AppTexts.getRandomTip();

  void _changeTip() {
    setState(() {
      _currentTip = AppTexts.getRandomTip();
    });
  }

  void _shareProgress(double progress) {
    final percentage = (progress * 100).toInt();
    Share.share(
      'I\'ve taken $percentage% of my medications today! Keeping up with my health goals via MedMinder.',
      subject: 'My MedMinder Progress',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Medicine>>(
      stream: FirestoreService.getMedicinesStream(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final medicines = snapshot.data ?? [];

        final takenMedicines = medicines.where((m) => m.isCompleted).length;
        final progress = medicines.isEmpty ? 0.0 : takenMedicines / medicines.length;

        return CustomScrollView(
          slivers: [
            _buildAppBar(theme, context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDailyProgress(theme, progress, takenMedicines, medicines.length),
                    const SizedBox(height: 24),
                    if (medicines.any((m) => !m.isCompleted))
                      _buildNextUp(theme, medicines.firstWhere((m) => !m.isCompleted)),
                    const SizedBox(height: 24),
                    _buildTipsCard(theme),
                    const SizedBox(height: 24),
                    _buildMedicineList(theme, medicines),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leadingWidth: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                ? NetworkImage(user!.photoURL!)
                : null,
            child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, ${user?.displayName?.split(' ').first ?? 'User'}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderScreen()),
            );
          },
          icon: const Icon(Icons.shopping_cart),
          tooltip: 'Order Medicines',
        ),
        IconButton(
          onPressed: () => setState(() {}), // Refreshes the stream
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildDailyProgress(ThemeData theme, double progress, int taken, int total) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Daily Progress', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => _shareProgress(progress),
                  icon: Icon(Icons.share, color: theme.colorScheme.primary),
                  tooltip: 'Share Progress',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                      Center(
                        child: Text('${(progress * 100).toInt()}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$taken of $total medicines taken', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Stay on track! Your health is your priority.', style: theme.textTheme.bodyMedium)
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextUp(ThemeData theme, Medicine medicine) {
    final isOverdue = medicine.nextDose?.isBefore(DateTime.now()) ?? false;
    return Card(
      color: isOverdue ? AppTheme.warningLight.withAlpha(50) : theme.colorScheme.secondaryContainer.withAlpha(50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isOverdue ? AppTheme.warningDark : theme.colorScheme.secondary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Next Up', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningDark.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Overdue', style: TextStyle(fontSize: 12, color: AppTheme.warningDark, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(medicine.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medicine.nextDose != null ? DateFormat.jm().format(medicine.nextDose!) : 'No time set',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: isOverdue ? AppTheme.warningDark : theme.colorScheme.secondary, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (user != null && medicine.id != null) {
                      FirestoreService.updateMedicineStatus(user!.uid, medicine.id!, true);
                    }
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Take Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(150),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(_currentTip, style: theme.textTheme.bodyLarge),
            ),
            IconButton(
              onPressed: _changeTip,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineList(ThemeData theme, List<Medicine> medicines) {
    final timeSections = {
      'Morning': (5, 12),
      'Afternoon': (12, 17),
      'Evening': (17, 24),
    };

    final groupedMeds = <String, List<Medicine>>{};
    for (var med in medicines) {
      final hour = med.nextDose?.hour;
      if (hour == null) continue;
      for (var entry in timeSections.entries) {
        if (hour >= entry.value.$1 && hour < entry.value.$2) {
          (groupedMeds[entry.key] ??= []).add(med);
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: timeSections.keys.map((title) {
        final medsForSection = groupedMeds[title] ?? [];
        return _buildMedicineSection(theme, title, medsForSection);
      }).toList(),
    );
  }

  Widget _buildMedicineSection(ThemeData theme, String title, List<Medicine> medicines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        if (medicines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text('No medications for this time.', style: theme.textTheme.bodyMedium),
            ),
          )
        else
          ...medicines.map((med) => _buildMedicineCard(theme, med)),
      ],
    );
  }

  Widget _buildMedicineCard(ThemeData theme, Medicine medicine) {
    final bool isSkipped = !medicine.isCompleted && (medicine.nextDose?.isBefore(DateTime.now()) ?? false);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: medicine.isCompleted ? AppTheme.accentGreen.withAlpha(30) : (isSkipped ? AppTheme.errorLight.withAlpha(50) : theme.cardColor),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildMedicationIcon(theme, medicine, isSkipped),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    medicine.isCompleted
                        ? 'Taken at ${DateFormat.jm().format(medicine.nextDose!)}'
                        : (isSkipped ? 'Skipped' : DateFormat.jm().format(medicine.nextDose!)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSkipped ? AppTheme.errorDark : (medicine.isCompleted ? AppTheme.accentGreenDark : null),
                      fontWeight: isSkipped || medicine.isCompleted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (!medicine.isCompleted && !isSkipped)
              ElevatedButton(
                onPressed: () {
                   if (user != null && medicine.id != null) {
                      FirestoreService.updateMedicineStatus(user!.uid, medicine.id!, true);
                    }
                },
                child: const Text('Take'),
              )
            else if (medicine.isCompleted)
              const Icon(Icons.check_circle, color: AppTheme.accentGreenDark)
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationIcon(ThemeData theme, Medicine medicine, bool isSkipped) {
    Color iconColor = theme.colorScheme.onPrimary;
    Color backgroundColor = theme.colorScheme.primary;
    IconData icon = Icons.medication;

    if (medicine.isCompleted) {
      backgroundColor = AppTheme.accentGreenDark;
      icon = Icons.check;
    } else if (isSkipped) {
      backgroundColor = AppTheme.errorDark;
      icon = Icons.close;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}
