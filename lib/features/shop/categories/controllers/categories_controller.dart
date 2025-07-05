import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/category_model.dart';

class CategoriesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  // For search functionality
  final RxString searchQuery = ''.obs;
  final RxList<CategoryModel> filteredCategories = <CategoryModel>[].obs;

  // A flattened list for data table display
  final RxList<CategoryModel> flattenedCategories = <CategoryModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    // Add listener to refilter when search query changes
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('categories').get();
      final allCategories = snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
      categories.assignAll(allCategories);
      _buildFlattenedList();
      applyFilters(); // Apply initial filters
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _buildFlattenedList() {
    List<CategoryModel> flattened = [];
    List<CategoryModel> topLevelCategories = categories.where((c) => c.parentCategoryId == null).toList();

    for (var cat in topLevelCategories) {
      _addCategoryAndChildren(cat, 0, flattened);
    }
    flattenedCategories.assignAll(flattened);
  }

  void _addCategoryAndChildren(CategoryModel category, int depth, List<CategoryModel> list) {
    // Modify name to show depth for visual hierarchy in the table
    final displayCategory = CategoryModel(
      id: category.id,
      name: '${'— ' * depth}${category.name.replaceAll('— ', '')}', // Apply hierarchy indicator
      description: category.description,
      imageUrl: category.imageUrl,
      parentCategoryId: category.parentCategoryId,
    );

    list.add(displayCategory);

    List<CategoryModel> children = categories.where((c) => c.parentCategoryId == category.id).toList();
    for (var child in children) {
      // Pass the original child object to the recursive call
      _addCategoryAndChildren(child, depth + 1, list);
    }
  }

  void applyFilters() {
    List<CategoryModel> result = List.from(flattenedCategories);
    if (searchQuery.value.isNotEmpty) {
      result = result.where((c) => c.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    filteredCategories.assignAll(result);
  }

  // --- Final Delete Logic ---
  // This is the main function called from the UI.
  Future<void> deleteCategory(String categoryId) async {
    // Show a loading dialog for better UX
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      // A WriteBatch allows multiple operations to be committed atomically.
      final WriteBatch batch = _firestore.batch();

      // Start the recursive deletion process, passing the batch around.
      await _recursivelyDeleteChildrenAndProducts(categoryId, batch);

      // Commit all the batched operations at once.
      await batch.commit();

      Get.back(); // Close loading dialog
      await fetchCategories(); // Refresh the list from Firestore.
      Get.snackbar('Success', 'Category and all sub-categories deleted successfully');
    } catch (e) {
      Get.back(); // Close loading dialog on error.
      Get.snackbar('Error', 'Failed to delete category: $e');
    }
  }

  /// A helper function that recursively finds children and associated products to delete.
  Future<void> _recursivelyDeleteChildrenAndProducts(String categoryId, WriteBatch batch) async {
    // 1. Find and remove this category from any product's `categoryIds` array.
    final productsSnapshot = await _firestore
        .collection('products')
        .where('categoryIds', arrayContains: categoryId) // Modern syntax
        .get();

    for (final doc in productsSnapshot.docs) {
      batch.update(doc.reference, {
        'categoryIds': FieldValue.arrayRemove([categoryId])
      });
    }

    // 2. Find all direct children of the current category.
    final childrenSnapshot = await _firestore
        .collection('categories')
        .where('parentCategoryId', isEqualTo: categoryId) // Modern syntax
        .get();

    // 3. For each child, call this function again to continue the chain.
    for (final childDoc in childrenSnapshot.docs) {
      // The recursive call adds its own operations to the same batch.
      await _recursivelyDeleteChildrenAndProducts(childDoc.id, batch);
    }

    // 4. After handling children and products, delete the current category document itself.
    final categoryRef = _firestore.collection('categories').doc(categoryId);
    batch.delete(categoryRef);
  }
  // --- End of Final Delete Logic ---

  String getParentCategoryName(String? parentId) {
    if (parentId == null) return 'N/A';
    // Remove hierarchy indicator for clean display
    return categories.firstWhere((c) => c.id == parentId, orElse: () => CategoryModel(id: '', name: 'Not Found')).name.replaceAll('— ', '');
  }
}