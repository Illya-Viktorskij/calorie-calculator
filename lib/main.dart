import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const CalorieCalculatorApp());
}

class CalorieCalculatorApp extends StatelessWidget {
  const CalorieCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  // Screens: 0=Home, 1=Add, 2=History, 3=Profile
  List<Widget> get _screens => [
        HomeScreen(key: _homeKey),
        AddScreen(onBackPressed: () => _onIndexChanged(0)),
        HistoryScreen(key: _historyKey, onBackPressed: () => _onIndexChanged(0)),
        ProfileScreen(onBackPressed: () => _onIndexChanged(0)),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildNavBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Me button
        _buildNavButton(
          icon: Icons.person,
          label: 'Me',
          index: 3,
          onTap: () => _onIndexChanged(3),
        ),
        // Add button (neon, bigger, centered)
        _buildNeonAddButton(),
        // History button
        _buildNavButton(
          icon: Icons.history,
          label: 'History',
          index: 2,
          onTap: () => _onIndexChanged(2),
        ),
      ],
    );
  }

  Widget _buildNeonAddButton() {
    const neonGreen = Color(0xFF39FF14);
    
    return GestureDetector(
      onTap: () => _onIndexChanged(1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            // Outer glow
            BoxShadow(
              color: neonGreen.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            // Inner glow
            BoxShadow(
              color: neonGreen.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[900],
            border: Border.all(
              color: neonGreen,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.add,
            color: neonGreen,
            size: 32,
          ),
        ),
      ),
    );
  }

  void _onIndexChanged(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
      // Refresh home screen when switching back to it
      if (newIndex == 0) {
        _homeKey.currentState?.refresh();
      }
      // Refresh history screen when switching to it
      if (newIndex == 2) {
        _historyKey.currentState?.refresh();
      }
    });
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
