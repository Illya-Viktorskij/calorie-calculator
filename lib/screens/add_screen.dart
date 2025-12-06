import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../models/food_entry.dart';
import '../models/daily_log.dart';

class AddScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const AddScreen({super.key, this.onBackPressed});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final DataService _dataService = DataService();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _waterController = TextEditingController();
  List<Map<String, dynamic>> _foodDatabase = [];
  List<Map<String, dynamic>> _filteredFoods = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 for food, 1 for water

  @override
  void initState() {
    super.initState();
    _loadFoodDatabase();
    _searchController.addListener(_filterFoods);
  }

  Future<void> _loadFoodDatabase() async {
    await _dataService.initializeFoodDatabase();
    final foods = await _dataService.getFoodDatabase();
    setState(() {
      _foodDatabase = foods;
      _filteredFoods = foods;
      _isLoading = false;
    });
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFoods = _foodDatabase;
      } else {
        _filteredFoods = _foodDatabase
            .where((food) => food['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _addFood(Map<String, dynamic> food) async {
    final quantity = double.tryParse(_quantityController.text) ?? 100.0;
    final caloriesPer100g = food['caloriesPer100g'] as double;
    final totalCalories = (caloriesPer100g * quantity) / 100.0;

    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: food['name'] as String,
      calories: totalCalories,
      quantity: quantity,
      timestamp: DateTime.now(),
    );

    await _dataService.addFoodEntry(entry);

    if (mounted) {
      _quantityController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${food['name']} (${totalCalories.toStringAsFixed(0)} cal)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _addWater() async {
    final liters = double.tryParse(_waterController.text) ?? 0.0;
    if (liters <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount of water'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _dataService.addWater(liters);

    if (mounted) {
      _waterController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${liters.toStringAsFixed(1)} L of water'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddFoodDialog(Map<String, dynamic> food) {
    _quantityController.text = '100';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          food['name'] as String,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${food['caloriesPer100g']} cal per 100g',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
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
            onPressed: () {
              Navigator.pop(context);
              _addFood(food);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Food / Water',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab selector
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Food',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Water',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content based on selected tab
            Expanded(
              child: _selectedTab == 0 ? _buildFoodTab() : _buildWaterTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Search for food...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
        // Food list
        Expanded(
          child: _filteredFoods.isEmpty
              ? const Center(
                  child: Text(
                    'No foods found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredFoods.length,
                  itemBuilder: (context, index) {
                    final food = _filteredFoods[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          food['name'] as String,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${food['caloriesPer100g']} cal per 100g',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                        ),
                        onTap: () => _showAddFoodDialog(food),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWaterTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 40),
            const Text(
              'Add Water Intake',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the amount of water you drank in liters',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _waterController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: '0.0',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 24),
                suffixText: 'L',
                suffixStyle: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _addWater,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Water',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

