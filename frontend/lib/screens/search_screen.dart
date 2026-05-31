import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool isDarkMode;

  const SearchScreen({super.key, required this.isDarkMode});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RecipeService _service = RecipeService();
  final TextEditingController _controller = TextEditingController();

  List<Recipe> _results = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final results = await _service.getRecipes(ingredient: query.trim());
      setState(() {
        _results = results;
        _searched = true;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
    final textPrimary = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFF7A7A7A) : const Color(0xFF888888);
    final textHint = isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Find recipes by ingredient',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),

                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      onChanged: _search,
                      decoration: InputDecoration(
                        hintText: 'e.g. eggs, butter, garlic...',
                        hintStyle: TextStyle(color: textHint, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: textHint, size: 20),
                        suffixIcon: _controller.text.isNotEmpty
                            ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            _search('');
                          },
                          child: Icon(Icons.close, color: textHint, size: 18),
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6B35),
                ),
              )
                  : !_searched
                  ? Center(
                child: Text(
                  'Type an ingredient to search',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
                  : _results.isEmpty
                  ? Center(
                child: Text(
                  'No recipes found.',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    recipe: _results[index],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(
                            recipe: _results[index],
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                      );
                      _search(_controller.text);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}