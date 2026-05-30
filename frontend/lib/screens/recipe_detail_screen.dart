import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/tag_chip.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFFEEEEEE), size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: const Text(
                        'Delete recipe?',
                        style: TextStyle(color: Color(0xFFEEEEEE)),
                      ),
                      content: const Text(
                        'This cannot be undone.',
                        style: TextStyle(color: Color(0xFF7A7A7A)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF7A7A7A))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B35))),
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
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.delete_outline, color: Color(0xFFFF6B35), size: 20),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: recipe.photos.isNotEmpty
                  ? Image.network(
                'http://10.0.2.2:8000/photos/${recipe.photos.first}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E1E1E)),
              )
                  : Container(color: const Color(0xFF1E1E1E)),
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
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  if (recipe.description != null && recipe.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        recipe.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7A7A7A),
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
                      color: Color(0xFFFF6B35),
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
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${ing.quantity ?? ''} ${ing.unit ?? ''} ${ing.name}'.trim(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFCCCCCC),
                            ),
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
                      color: Color(0xFFFF6B35),
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
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2C2C2C)),
                            ),
                            child: Center(
                              child: Text(
                                '${step.orderNumber}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.instruction,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFCCCCCC),
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