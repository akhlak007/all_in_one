class Meal {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String mealType; // breakfast, lunch, dinner
  final bool isVegetarian;
  final bool isGlutenFree;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> availableSizes;
  final List<String> availableExtras;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.mealType,
    required this.isVegetarian,
    required this.isGlutenFree,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.availableSizes,
    required this.availableExtras,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      mealType: json['mealType'],
      isVegetarian: json['isVegetarian'],
      isGlutenFree: json['isGlutenFree'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      availableSizes: List<String>.from(json['availableSizes'] ?? []),
      availableExtras: List<String>.from(json['availableExtras'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'mealType': mealType,
      'isVegetarian': isVegetarian,
      'isGlutenFree': isGlutenFree,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'availableSizes': availableSizes,
      'availableExtras': availableExtras,
    };
  }
}