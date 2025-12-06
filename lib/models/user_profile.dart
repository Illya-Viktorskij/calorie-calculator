class UserProfile {
  final double? weight; // in kg
  final double? height; // in cm
  final double calorieLimit; // daily calorie limit

  UserProfile({
    this.weight,
    this.height,
    required this.calorieLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'calorieLimit': calorieLimit,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      calorieLimit: json['calorieLimit']?.toDouble() ?? 2000.0,
    );
  }

  UserProfile copyWith({
    double? weight,
    double? height,
    double? calorieLimit,
  }) {
    return UserProfile(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      calorieLimit: calorieLimit ?? this.calorieLimit,
    );
  }
}

