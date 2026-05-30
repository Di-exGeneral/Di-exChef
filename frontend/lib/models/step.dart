class RecipeStep {
  final int id;
  final int orderNumber;
  final String instruction;

  RecipeStep({
    required this.id,
    required this.orderNumber,
    required this.instruction,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'],
      orderNumber: json['order_number'],
      instruction: json['instruction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_number': orderNumber,
      'instruction': instruction,
    };
  }
}