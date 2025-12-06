import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  DailyLog? _todayLog;
  UserProfile? _profile;
  bool _isLoading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Pulsating animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final todayLog = await _dataService.getTodayLog();
    final profile = await _dataService.getUserProfile();
    if (mounted) {
      setState(() {
        _todayLog = todayLog;
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  void refresh() {
    _loadData();
  }

  void _showFoodEntriesSheet(BuildContext context) {
    final entries = _todayLog?.foodEntries ?? [];
    final waterIntake = _todayLog?.waterIntake ?? 0.0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant_menu, color: Colors.green),
                      const SizedBox(width: 12),
                      const Text(
                        'Today\'s Food',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entries.length} items',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Water intake section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Water Intake',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                          Text(
                            '${waterIntake.toStringAsFixed(1)} L',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditWaterDialog(context, waterIntake);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Food entries list
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.no_food,
                                size: 64,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No food added today',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add food',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return _buildFoodEntryTile(context, entry);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodEntryTile(BuildContext context, FoodEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          entry.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${entry.quantity.toStringAsFixed(0)}g',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.calories.toStringAsFixed(0)} cal',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[500]),
              color: Colors.grey[800],
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.pop(context);
                  _showEditFoodDialog(context, entry);
                } else if (value == 'delete') {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, entry);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text('Edit', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFoodDialog(BuildContext context, FoodEntry entry) {
    final quantityController = TextEditingController(text: entry.quantity.toStringAsFixed(0));
    final caloriesPer100g = (entry.calories / entry.quantity) * 100;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          entry.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${caloriesPer100g.toStringAsFixed(0)} cal per 100g',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                labelText: 'Quantity (g)',
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = double.tryParse(quantityController.text) ?? entry.quantity;
              final newCalories = (caloriesPer100g * newQuantity) / 100;
              
              final updatedEntry = entry.copyWith(
                quantity: newQuantity,
                calories: newCalories,
              );
              
              await _dataService.updateFoodEntry(updatedEntry);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated ${entry.name}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Entry',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${entry.name}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dataService.deleteFoodEntry(entry.id);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted ${entry.name}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditWaterDialog(BuildContext context, double currentWater) {
    final waterController = TextEditingController(text: currentWater.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.blue),
            SizedBox(width: 12),
            Text(
              'Edit Water Intake',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the total amount of water for today',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: waterController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixText: 'L',
                suffixStyle: const TextStyle(color: Colors.blue, fontSize: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newWater = double.tryParse(waterController.text) ?? currentWater;
              await _dataService.setWater(newWater);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Water intake updated to ${newWater.toStringAsFixed(1)} L'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
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

    final calorieLimit = _profile?.calorieLimit ?? 2000.0;
    final totalCalories = _todayLog?.totalCalories ?? 0.0;
    final progress = (totalCalories / calorieLimit).clamp(0.0, 1.0);
    final isExceeded = totalCalories > calorieLimit;

    final waterIntake = _todayLog?.waterIntake ?? 0.0;
    final weight = _profile?.weight;
    final height = _profile?.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Circular Progress Indicator at top (clickable) with neon glow
                GestureDetector(
                  onTap: () => _showFoodEntriesSheet(context),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final neonColor = isExceeded 
                          ? const Color(0xFFFF073A) // Neon red
                          : const Color(0xFF39FF14); // Neon green
                      
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            // Outer glow
                            BoxShadow(
                              color: neonColor.withOpacity(0.3 * _pulseAnimation.value),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                            // Inner glow
                            BoxShadow(
                              color: neonColor.withOpacity(0.5 * _pulseAnimation.value),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background circle
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[900],
                                ),
                              ),
                              // Progress circle with neon effect
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 14,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: AlwaysStoppedAnimation<Color>(neonColor),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              // Center content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    totalCalories.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: neonColor.withOpacity(0.8),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'calories',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '/ ${calorieLimit.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: neonColor,
                                      shadows: [
                                        Shadow(
                                          color: neonColor.withOpacity(0.6),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // Three info widgets
                _buildInfoCard(
                  icon: Icons.water_drop,
                  iconColor: Colors.blue,
                  title: 'Water Intake',
                  value: '${waterIntake.toStringAsFixed(1)} L',
                  subtitle: 'Today',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  title: 'Calorie Limit',
                  value: '${calorieLimit.toStringAsFixed(0)} cal',
                  subtitle: 'Daily goal',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.person,
                  iconColor: Colors.green,
                  title: 'Body Stats',
                  value: weight != null && height != null
                      ? '${weight.toStringAsFixed(1)} kg • ${height.toStringAsFixed(0)} cm'
                      : 'Not set',
                  subtitle: weight != null && height != null ? 'Weight • Height' : 'Go to profile to set',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
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

