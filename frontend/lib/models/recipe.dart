import 'ingredient.dart';
import 'step.dart';
import 'tag.dart';

class Recipe {
  final int id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final List<Tag> tags;
  final List<String> photos;

  Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.photos,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      steps: (json['steps'] as List)
          .map((s) => RecipeStep.fromJson(s))
          .toList(),
      tags: (json['tags'] as List)
          .map((t) => Tag.fromJson(t))
          .toList(),
      photos: List<String>.from(json['photos']),
    );
  }
}