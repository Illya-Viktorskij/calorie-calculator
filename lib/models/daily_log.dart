import 'food_entry.dart';

class DailyLog {
  final DateTime date;
  final List<FoodEntry> foodEntries;
  final double waterIntake; // in liters

  DailyLog({
    required this.date,
    required this.foodEntries,
    this.waterIntake = 0.0,
  });

  double get totalCalories {
    return foodEntries.fold(0.0, (sum, entry) => sum + entry.calories);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'foodEntries': foodEntries.map((e) => e.toJson()).toList(),
      'waterIntake': waterIntake,
    };
  }

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: DateTime.parse(json['date']),
      foodEntries: (json['foodEntries'] as List<dynamic>?)
              ?.map((e) => FoodEntry.fromJson(e))
              .toList() ??
          [],
      waterIntake: json['waterIntake']?.toDouble() ?? 0.0,
    );
  }

  DailyLog copyWith({
    DateTime? date,
    List<FoodEntry>? foodEntries,
    double? waterIntake,
  }) {
    return DailyLog(
      date: date ?? this.date,
      foodEntries: foodEntries ?? this.foodEntries,
      waterIntake: waterIntake ?? this.waterIntake,
    );
  }
}

