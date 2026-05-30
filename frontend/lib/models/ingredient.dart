class Ingredient {
  final int id;
  final String name;
  final String? quantity;
  final String? unit;

  Ingredient({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}