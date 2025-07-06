import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../core/shared_widgets/loading_overlay.dart';
import '../../models/category_model.dart';

class CategoriesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  // For search functionality
  final RxString searchQuery = ''.obs;
  final RxList<CategoryModel> filteredCategories = <CategoryModel>[].obs;

  // A flattened list for data table display that shows hierarchy
  final RxList<CategoryModel> flattenedCategoriesForDisplay = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('categories').get();
      final allCategories = snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
      categories.assignAll(allCategories);
      _buildFlattenedListForDisplay();
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _buildFlattenedListForDisplay() {
    List<CategoryModel> flattened = [];
    List<CategoryModel> topLevelCategories = categories.where((c) => c.parentCategoryId == null).toList();

    for (var cat in topLevelCategories) {
      _addCategoryAndChildren(cat, 0, flattened);
    }
    flattenedCategoriesForDisplay.assignAll(flattened);
  }

  void _addCategoryAndChildren(CategoryModel category, int depth, List<CategoryModel> list) {
    final displayCategory = category.copyWith(
      name: '${'— ' * depth}${category.name}',
    );
    list.add(displayCategory);

    List<CategoryModel> children = categories.where((c) => c.parentCategoryId == category.id).toList();
    for (var child in children) {
      _addCategoryAndChildren(child, depth + 1, list);
    }
  }

  void applyFilters() {
    List<CategoryModel> result = List.from(flattenedCategoriesForDisplay);
    if (searchQuery.value.isNotEmpty) {
      result = result.where((c) {
        final originalName = categories.firstWhere((orig) => orig.id == c.id).name;
        return originalName.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
    filteredCategories.assignAll(result);
  }

  Future<void> deleteCategory(String categoryId) async {
    LoadingOverlay.show(message: "Deleting category...");
    try {
      final WriteBatch batch = _firestore.batch();
      await _recursivelyDelete(categoryId, batch);
      await batch.commit();

      LoadingOverlay.hide();
      await fetchCategories();
      Get.snackbar('Success', 'Category and all sub-categories deleted successfully');
    } catch (e) {
      LoadingOverlay.hide();
      Get.snackbar('Error', 'Failed to delete category: $e');
    }
  }

  Future<void> _recursivelyDelete(String categoryId, WriteBatch batch) async {
    final productsSnapshot = await _firestore
        .collection('products')
        .where('categoryIds', arrayContains: categoryId)
        .get();

    for (final doc in productsSnapshot.docs) {
      batch.update(doc.reference, {
        'categoryIds': FieldValue.arrayRemove([categoryId])
      });
    }

    final childrenSnapshot = await _firestore
        .collection('categories')
        .where('parentCategoryId', isEqualTo: categoryId)
        .get();

    for (final childDoc in childrenSnapshot.docs) {
      await _recursivelyDelete(childDoc.id, batch);
    }

    final categoryRef = _firestore.collection('categories').doc(categoryId);
    batch.delete(categoryRef);
  }

  String getParentCategoryName(String? parentId) {
    if (parentId == null) return 'N/A';
    return categories.firstWhere((c) => c.id == parentId,
        orElse: () => CategoryModel(id: '', name: 'Not Found')).name;
  }
}
