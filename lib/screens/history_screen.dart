import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medminder/models/medication_log.dart';
import 'package:medminder/services/firestore_service.dart';
import 'package:medminder/theme/app_theme.dart';
import 'package:collection/collection.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      FirestoreService.logSkippedDoses(user!.uid);
    }
    _selectedDay = _focusedDay;
  }

  // --- Statistics Calculation ---

  double _calculateWeeklyAdherence(List<MedicationLog> logs) {
    if (logs.isEmpty) return 0.0;

    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentLogs =
        logs.where((log) => log.timestamp.isAfter(oneWeekAgo)).toList();

    if (recentLogs.isEmpty) return 0.0;

    final takenCount = recentLogs.where((log) => log.status == 'Taken').length;
    return takenCount / recentLogs.length;
  }

  int _calculateCurrentStreak(List<MedicationLog> logs) {
    if (logs.isEmpty) return 0;

    final takenLogsByDay = groupBy(
      logs.where((log) => log.status == 'Taken'),
      (MedicationLog log) =>
          DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day),
    );

    if (takenLogsByDay.isEmpty) return 0;

    final sortedDays = takenLogsByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    // Check if the streak includes today or yesterday
    if (sortedDays.first.isAtSameMomentAs(currentDate) ||
        sortedDays.first
            .isAtSameMomentAs(currentDate.subtract(const Duration(days: 1)))) {
      streak++;
      for (int i = 0; i < sortedDays.length - 1; i++) {
        final diff = sortedDays[i].difference(sortedDays[i + 1]).inDays;
        if (diff == 1) {
          streak++;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder<List<MedicationLog>>(
        stream: FirestoreService.getMedicationLogStream(user?.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No medication history yet.'));
          }

          final groupedLogs = groupBy(logs, (MedicationLog log) {
            final date = log.timestamp;
            return DateTime(date.year, date.month, date.day);
          });

          final weeklyAdherence = _calculateWeeklyAdherence(logs);
          final currentStreak = _calculateCurrentStreak(logs);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('History'),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                    icon: const Icon(Icons.ios_share),
                  ),
                ],
                pinned: true,
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStatsCards(theme, weeklyAdherence, currentStreak),
                    _buildCalendarView(theme, groupedLogs),
                    _buildFilters(theme),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final date = groupedLogs.keys.elementAt(index);
                    final logsForDay = groupedLogs[date]!;
                    return _buildHistoryGroup(theme, date, logsForDay);
                  },
                  childCount: groupedLogs.length,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme, double adherence, int streak) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _buildAdherenceCard(theme, adherence)),
          const SizedBox(width: 16),
          Expanded(child: _buildStreakCard(theme, streak)),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(ThemeData theme, double adherence) {
    final percentage = (adherence * 100).toInt();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Week',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$percentage%',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.greenAdherence)),
              ],
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: adherence,
                strokeWidth: 5,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.greenAdherence),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(ThemeData theme, int streak) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Streak',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$streak Days',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orangeAdherence)),
              ],
            ),
            const Icon(Icons.local_fire_department,
                color: AppTheme.orangeAdherence, size: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(
      ThemeData theme, Map<DateTime, List<MedicationLog>> groupedLogs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return groupedLogs[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.accentGreen,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search medicine...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip(theme, 'Filter', Icons.filter_list),
              const SizedBox(width: 8),
              _buildFilterChip(theme, 'Sort: Status', Icons.swap_vert),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {},
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) {
      return 'Today, ${DateFormat.yMMMMd().format(date)}';
    }
    if (date == yesterday) {
      return 'Yesterday, ${DateFormat.yMMMMd().format(date)}';
    }
    return DateFormat.yMMMMd().format(date);
  }

  Widget _buildHistoryGroup(
      ThemeData theme, DateTime date, List<MedicationLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(_formatDate(date), style: theme.textTheme.titleLarge),
        ),
        ...logs.map((log) => _buildHistoryItem(theme, log)),
      ],
    );
  }

  Widget _buildHistoryItem(ThemeData theme, MedicationLog log) {
    final color =
        log.status == 'Taken' ? AppTheme.greenAdherence : AppTheme.redAdherence;
    final icon = log.status == 'Taken' ? Icons.check_circle : Icons.cancel;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(26),
          child: Icon(icon, color: color),
        ),
        title: Text(log.medicineName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(log.dosage),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(log.status,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Text(DateFormat.jm().format(log.timestamp),
                style: theme.textTheme.bodySmall),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
