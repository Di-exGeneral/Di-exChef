import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/tag_chip.dart';
import '../config/api.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final bool isDarkMode;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final service = RecipeService();
    final isDark = isDarkMode;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
    final textPrimary = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFF7A7A7A) : const Color(0xFF888888);
    final textBody = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444);
    const accent = Color(0xFFFF6B35);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Icon(Icons.arrow_back, color: textPrimary, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: surface,
                      title: Text(
                        'Delete recipe?',
                        style: TextStyle(color: textPrimary),
                      ),
                      content: Text(
                        'This cannot be undone.',
                        style: TextStyle(color: textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel', style: TextStyle(color: textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: accent)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await service.deleteRecipe(recipe.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.delete_outline, color: accent, size: 20),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: recipe.photos.isNotEmpty
                  ? FutureBuilder<String>(
                future: ApiConfig.getBaseUrl(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(color: surface);
                  }
                  return Image.network(
                    '${snapshot.data}/photos/${recipe.photos.first}',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(color: surface),
                  );
                },
              )
                  : Container(color: surface),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipe.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: recipe.tags
                          .map((t) => TagChip(tag: t, selected: true))
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  if (recipe.description != null && recipe.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        recipe.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  const Text(
                    'INGREDIENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map(
                        (ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${ing.quantity ?? ''} ${ing.unit ?? ''} ${ing.name}'.trim(),
                            style: TextStyle(fontSize: 14, color: textBody),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'STEPS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.steps.map(
                        (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: border),
                            ),
                            child: Center(
                              child: Text(
                                '${step.orderNumber}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.instruction,
                              style: TextStyle(
                                fontSize: 14,
                                color: textBody,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}