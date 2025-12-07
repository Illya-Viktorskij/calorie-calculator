import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/daily_log.dart';
import '../models/user_profile.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const HistoryScreen({super.key, this.onBackPressed});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final DataService _dataService = DataService();
  Map<String, DailyLog> _dailyLogs = {};
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void refresh() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final logs = await _dataService.getAllDailyLogs();
    final profile = await _dataService.getUserProfile();
    setState(() {
      _dailyLogs = logs;
      _profile = profile;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(date.year, date.month, date.day);

    if (logDate == today) {
      return 'Today';
    } else if (logDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      );
    }

    final sortedDates = _dailyLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: widget.onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackPressed,
              )
            : null,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: sortedDates.isEmpty
            ? const Center(
                child: Text(
                  'No history yet',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadHistory,
                color: Colors.green,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final dateKey = sortedDates[index];
                    final log = _dailyLogs[dateKey]!;
                    final totalCalories = log.totalCalories;
                    final logCalorieLimit = log.calorieLimit; // Use the limit stored for this day
                    final isExceeded = totalCalories > logCalorieLimit;
                    final isToday = _formatDate(log.date) == 'Today';

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: isToday
                            ? const Icon(Icons.edit, color: Colors.green, size: 20)
                            : Icon(Icons.lock_outline, color: Colors.grey[600], size: 20),
                        title: Row(
                          children: [
                            Text(
                              _formatDate(log.date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${totalCalories.toStringAsFixed(0)} / ${logCalorieLimit.toStringAsFixed(0)} calories',
                              style: TextStyle(
                                color: isExceeded ? Colors.red : Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            if (log.waterIntake > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${log.waterIntake.toStringAsFixed(1)} L',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        children: [
                          if (log.foodEntries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No food entries',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ...log.foodEntries.map((entry) {
                              return ListTile(
                                title: Text(
                                  entry.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${entry.quantity.toStringAsFixed(0)}g',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Text(
                                  '${entry.calories.toStringAsFixed(0)} cal',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          if (isToday && log.foodEntries.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'Tap the circle on Home to edit today\'s entries',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

