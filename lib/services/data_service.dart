import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';

class DataService {
  static const String _profileKey = 'user_profile';
  static const String _dailyLogsKey = 'daily_logs';
  static const String _foodDatabaseKey = 'food_database';

  // User Profile
  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      return UserProfile.fromJson(jsonDecode(profileJson));
    }
    return null;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // Daily Logs
  Future<Map<String, DailyLog>> getAllDailyLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_dailyLogsKey);
    if (logsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(logsJson);
      return decoded.map((key, value) =>
          MapEntry(key, DailyLog.fromJson(value as Map<String, dynamic>)));
    }
    return {};
  }

  Future<DailyLog> getTodayLog() async {
    final logs = await getAllDailyLogs();
    final today = DateTime.now();
    final todayKey = _getDateKey(today);
    final profile = await getUserProfile();
    final calorieLimit = profile?.calorieLimit ?? 2000.0;
    
    if (logs[todayKey] != null) {
      // If log exists, ensure it has the current calorie limit (for today only)
      final existingLog = logs[todayKey]!;
      if (existingLog.calorieLimit != calorieLimit) {
        // Update the limit if it changed (only for today)
        final updatedLog = existingLog.copyWith(calorieLimit: calorieLimit);
        logs[todayKey] = updatedLog;
        await _saveAllLogs(logs);
        return updatedLog;
      }
      return existingLog;
    }
    
    return DailyLog(
      date: today,
      foodEntries: [],
      waterIntake: 0.0,
      calorieLimit: calorieLimit,
    );
  }
  
  Future<void> _saveAllLogs(Map<String, DailyLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logsMap = logs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_dailyLogsKey, jsonEncode(logsMap));
  }

  Future<void> saveDailyLog(DailyLog log) async {
    final logs = await getAllDailyLogs();
    final dateKey = _getDateKey(log.date);
    final today = DateTime.now();
    final todayKey = _getDateKey(today);
    
    // If saving today's log, ensure it has the current calorie limit
    // If saving a past day's log, preserve its original limit (don't change it)
    DailyLog logToSave = log;
    if (dateKey == todayKey) {
      final profile = await getUserProfile();
      final currentLimit = profile?.calorieLimit ?? 2000.0;
      logToSave = log.copyWith(calorieLimit: currentLimit);
    }
    
    logs[dateKey] = logToSave;
    await _saveAllLogs(logs);
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    final todayLog = await getTodayLog();
    final updatedEntries = List<FoodEntry>.from(todayLog.foodEntries)..add(entry);
    final profile = await getUserProfile();
    final currentLimit = profile?.calorieLimit ?? 2000.0;
    final updatedLog = todayLog.copyWith(
      foodEntries: updatedEntries,
      calorieLimit: currentLimit,
    );
    await saveDailyLog(updatedLog);
  }

  Future<void> updateFoodEntry(FoodEntry updatedEntry) async {
    final todayLog = await getTodayLog();
    final updatedEntries = todayLog.foodEntries.map((entry) {
      if (entry.id == updatedEntry.id) {
        return updatedEntry;
      }
      return entry;
    }).toList();
    final profile = await getUserProfile();
    final currentLimit = profile?.calorieLimit ?? 2000.0;
    final updatedLog = todayLog.copyWith(
      foodEntries: updatedEntries,
      calorieLimit: currentLimit,
    );
    await saveDailyLog(updatedLog);
  }

  Future<void> deleteFoodEntry(String entryId) async {
    final todayLog = await getTodayLog();
    final updatedEntries = todayLog.foodEntries
        .where((entry) => entry.id != entryId)
        .toList();
    final profile = await getUserProfile();
    final currentLimit = profile?.calorieLimit ?? 2000.0;
    final updatedLog = todayLog.copyWith(
      foodEntries: updatedEntries,
      calorieLimit: currentLimit,
    );
    await saveDailyLog(updatedLog);
  }

  Future<void> addWater(double liters) async {
    final todayLog = await getTodayLog();
    final profile = await getUserProfile();
    final currentLimit = profile?.calorieLimit ?? 2000.0;
    final updatedLog = todayLog.copyWith(
      waterIntake: todayLog.waterIntake + liters,
      calorieLimit: currentLimit,
    );
    await saveDailyLog(updatedLog);
  }

  Future<void> setWater(double liters) async {
    final todayLog = await getTodayLog();
    final profile = await getUserProfile();
    final currentLimit = profile?.calorieLimit ?? 2000.0;
    final updatedLog = todayLog.copyWith(
      waterIntake: liters,
      calorieLimit: currentLimit,
    );
    await saveDailyLog(updatedLog);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Food Database (predefined foods)
  Future<List<Map<String, dynamic>>> getFoodDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final foodsJson = prefs.getString(_foodDatabaseKey);
    if (foodsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(foodsJson));
    }
    // Return default food database
    return _getDefaultFoodDatabase();
  }

  Future<void> initializeFoodDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_foodDatabaseKey);
    if (existing == null) {
      final defaultFoods = _getDefaultFoodDatabase();
      await prefs.setString(_foodDatabaseKey, jsonEncode(defaultFoods));
    }
  }

  List<Map<String, dynamic>> _getDefaultFoodDatabase() {
    return [
      {'name': 'Apple', 'caloriesPer100g': 52.0},
      {'name': 'Banana', 'caloriesPer100g': 89.0},
      {'name': 'Orange', 'caloriesPer100g': 47.0},
      {'name': 'Chicken Breast', 'caloriesPer100g': 165.0},
      {'name': 'Salmon', 'caloriesPer100g': 208.0},
      {'name': 'Rice (cooked)', 'caloriesPer100g': 130.0},
      {'name': 'Pasta (cooked)', 'caloriesPer100g': 131.0},
      {'name': 'Bread (white)', 'caloriesPer100g': 265.0},
      {'name': 'Egg', 'caloriesPer100g': 155.0},
      {'name': 'Milk (whole)', 'caloriesPer100g': 61.0},
      {'name': 'Yogurt', 'caloriesPer100g': 59.0},
      {'name': 'Cheese (cheddar)', 'caloriesPer100g': 402.0},
      {'name': 'Broccoli', 'caloriesPer100g': 34.0},
      {'name': 'Carrot', 'caloriesPer100g': 41.0},
      {'name': 'Tomato', 'caloriesPer100g': 18.0},
      {'name': 'Potato', 'caloriesPer100g': 77.0},
      {'name': 'Avocado', 'caloriesPer100g': 160.0},
      {'name': 'Almonds', 'caloriesPer100g': 579.0},
      {'name': 'Peanut Butter', 'caloriesPer100g': 588.0},
      {'name': 'Oatmeal', 'caloriesPer100g': 68.0},
      {'name': 'Chocolate Bar', 'caloriesPer100g': 546.0},
      {'name': 'Pizza Slice', 'caloriesPer100g': 266.0},
      {'name': 'Hamburger', 'caloriesPer100g': 295.0},
      {'name': 'French Fries', 'caloriesPer100g': 365.0},
    ];
  }
}

