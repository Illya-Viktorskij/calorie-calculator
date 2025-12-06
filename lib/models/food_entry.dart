class FoodEntry {
  final String id;
  final String name;
  final double calories;
  final double quantity; // in grams or units
  final DateTime timestamp;

  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.quantity,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      calories: json['calories']?.toDouble() ?? 0.0,
      quantity: json['quantity']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  FoodEntry copyWith({
    String? id,
    String? name,
    double? calories,
    double? quantity,
    DateTime? timestamp,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

