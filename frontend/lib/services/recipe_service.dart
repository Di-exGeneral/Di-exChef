import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/recipe.dart';
import '../models/tag.dart';

class RecipeService {
  Future<String> get _base => ApiConfig.getBaseUrl();

  Future<List<Recipe>> getRecipes({String? tag, String? ingredient}) async {
    final base = await _base;
    String url = '$base/recipes/';

    if (tag != null) url += '?tag=$tag';
    if (ingredient != null) url += '?ingredient=$ingredient';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((r) => Recipe.fromJson(r)).toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<Recipe> getRecipe(int id) async {
    final base = await _base;
    final response = await http.get(Uri.parse('$base/recipes/$id'));

    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load recipe');
  }

  Future<Recipe> createRecipe(Map<String, dynamic> payload) async {
    final base = await _base;
    final response = await http.post(
      Uri.parse('$base/recipes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create recipe');
  }

  Future<void> deleteRecipe(int id) async {
    final base = await _base;
    final response = await http.delete(Uri.parse('$base/recipes/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe');
    }
  }

  Future<List<Tag>> getTags() async {
    final base = await _base;
    final response = await http.get(Uri.parse('$base/tags/'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((t) => Tag.fromJson(t)).toList();
    }
    throw Exception('Failed to load tags');
  }

  Future<Tag> createTag(String name) async {
    final base = await _base;
    final response = await http.post(
      Uri.parse('$base/tags/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      return Tag.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create tag');
  }
}