import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/recipe_service.dart';
import '../widgets/tag_chip.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class AddRecipeScreen extends StatefulWidget {
  final bool isDarkMode;

  const AddRecipeScreen({super.key, required this.isDarkMode});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final RecipeService _service = RecipeService();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _newTagController = TextEditingController();

  List<Tag> _availableTags = [];
  List<int> _selectedTagIds = [];
  List<Map<String, String>> _ingredients = [];
  List<String> _steps = [];
  bool _saving = false;
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  final _ingNameController = TextEditingController();
  final _ingQtyController = TextEditingController();
  final _ingUnitController = TextEditingController();
  final _stepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _service.getTags();
      setState(() => _availableTags = tags);
    } catch (_) {}
  }

  void _addIngredient() {
    if (_ingNameController.text.trim().isEmpty) return;
    setState(() {
      _ingredients.add({
        'name': _ingNameController.text.trim(),
        'quantity': _ingQtyController.text.trim(),
        'unit': _ingUnitController.text.trim(),
      });
      _ingNameController.clear();
      _ingQtyController.clear();
      _ingUnitController.clear();
    });
  }

  void _addStep() {
    if (_stepController.text.trim().isEmpty) return;
    setState(() {
      _steps.add(_stepController.text.trim());
      _stepController.clear();
    });
  }

  Future<void> _createNewTag() async {
    if (_newTagController.text.trim().isEmpty) return;
    try {
      final tag = await _service.createTag(_newTagController.text.trim());
      setState(() {
        _availableTags.add(tag);
        _selectedTagIds.add(tag.id);
        _newTagController.clear();
      });
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedPhoto = File(picked.path));
    }
  }

  Future<void> _uploadPhoto(int recipeId) async {
    if (_selectedPhoto == null) return;
    final base = await ApiConfig.getBaseUrl();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$base/recipes/$recipeId/photos'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', _selectedPhoto!.path),
    );
    await request.send();
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _newTagController.clear();
    _ingNameController.clear();
    _ingQtyController.clear();
    _ingUnitController.clear();
    _stepController.clear();
    setState(() {
      _ingredients = [];
      _steps = [];
      _selectedTagIds = [];
      _selectedPhoto = null;
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe title is required'),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final recipe = await _service.createRecipe({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'ingredients': _ingredients,
        'steps': _steps
            .asMap()
            .entries
            .map((e) => {
          'order_number': e.key + 1,
          'instruction': e.value,
        })
            .toList(),
        'tag_ids': _selectedTagIds,
      });

      await _uploadPhoto(recipe.id);
      _clearForm();

      if (context.mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save recipe'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );
      }
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
    final accent = const Color(0xFFFF6B35);

    InputDecoration inputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    }

    Widget sectionLabel(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFF6B35),
            letterSpacing: 1.4,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: const SizedBox(),
        title: Text(
          'New recipe',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _saving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedPhoto != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedPhoto!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 52,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: accent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _selectedPhoto != null ? 'Change photo' : 'Add photo',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            sectionLabel('TITLE'),
            TextField(
              controller: _titleController,
              style: TextStyle(color: textPrimary),
              decoration: inputDecoration('Recipe title'),
            ),
            const SizedBox(height: 24),
            sectionLabel('DESCRIPTION'),
            TextField(
              controller: _descController,
              style: TextStyle(color: textPrimary),
              maxLines: 3,
              decoration: inputDecoration('Short description (optional)'),
            ),
            const SizedBox(height: 24),
            sectionLabel('TAGS'),
            if (_availableTags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  return TagChip(
                    tag: tag,
                    selected: _selectedTagIds.contains(tag.id),
                    onTap: () {
                      setState(() {
                        if (_selectedTagIds.contains(tag.id)) {
                          _selectedTagIds.remove(tag.id);
                        } else {
                          _selectedTagIds.add(tag.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    style: TextStyle(color: textPrimary),
                    decoration: inputDecoration('New tag name'),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _createNewTag,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Icon(Icons.add, color: accent, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            sectionLabel('INGREDIENTS'),
            ..._ingredients.asMap().entries.map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${e.value['quantity'] ?? ''} ${e.value['unit'] ?? ''} ${e.value['name']}'.trim(),
                        style: TextStyle(color: textPrimary, fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _ingredients.removeAt(e.key)),
                      child: Icon(Icons.close, size: 16, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ingNameController,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    decoration: inputDecoration('Ingredient'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ingQtyController,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    decoration: inputDecoration('Qty'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ingUnitController,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    decoration: inputDecoration('Unit'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addIngredient,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Icon(Icons.add, color: accent, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            sectionLabel('STEPS'),
            ..._steps.asMap().entries.map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: border),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _steps.removeAt(e.key)),
                      child: Icon(Icons.close, size: 16, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    style: TextStyle(color: textPrimary),
                    maxLines: 2,
                    decoration: inputDecoration('Describe this step'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addStep,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Icon(Icons.add, color: accent, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}