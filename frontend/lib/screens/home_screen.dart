import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/tag.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/tag_chip.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;

  const HomeScreen({super.key, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _service = RecipeService();

  List<Recipe> _recipes = [];
  List<Tag> _tags = [];
  Tag? _selectedTag;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final recipes = await _service.getRecipes(
        tag: _selectedTag?.name,
      );
      final tags = await _service.getTags();
      setState(() {
        _recipes = recipes;
        _tags = tags;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _selectTag(Tag tag) {
    setState(() {
      _selectedTag = _selectedTag?.id == tag.id ? null : tag;
    });
    _load();
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Di-exChef',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What are we cooking today?',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: textHint, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Search recipes...',
                            style: TextStyle(color: textHint, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_tags.isNotEmpty)
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tags.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final tag = _tags[index];
                          return TagChip(
                            tag: tag,
                            selected: _selectedTag?.id == tag.id,
                            onTap: () => _selectTag(tag),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
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
                  : _recipes.isEmpty
                  ? Center(
                child: Text(
                  'No recipes yet.\nTap + to add your first one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              )
                  : RefreshIndicator(
                color: const Color(0xFFFF6B35),
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeCard(
                      recipe: _recipes[index],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(
                              recipe: _recipes[index],
                              isDarkMode: widget.isDarkMode,
                            ),
                          ),
                        );
                        _load();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}