import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../models/sale_model.dart';
import '../../products/controllers/products_controller.dart';
import '../widgets/item_selection_dialog.dart';

class SaleFormController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountController = TextEditingController();

  // Reactive variables for state management
  final RxBool isLoading = false.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 7)).obs;
  final RxBool isActive = true.obs;
  final RxString appliesTo = 'products'.obs; // 'products' or 'categories'
  final RxList<String> targetIds = <String>[].obs;

  // To show names of selected items
  final RxList<String> targetNames = <String>[].obs;

  Rx<SaleModel?> saleToEdit = Rx<SaleModel?>(null);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is SaleModel) {
      saleToEdit.value = Get.arguments;
      _loadSaleData(saleToEdit.value!);
    }
  }

  void _loadSaleData(SaleModel sale) {
    nameController.text = sale.name;
    descriptionController.text = sale.description ?? '';
    discountController.text = sale.discountPercentage.toString();
    startDate.value = sale.startDate.toDate();
    endDate.value = sale.endDate.toDate();
    isActive.value = sale.isActive;
    appliesTo.value = sale.appliesTo;
    targetIds.assignAll(sale.targetIds);
    _updateTargetNames();
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate.value : endDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      if (isStart) {
        startDate.value = pickedDate;
      } else {
        endDate.value = pickedDate;
      }
    }
  }

  void openItemSelectionDialog(BuildContext context) {
    if (appliesTo.value == 'products') {
      final productsController = Get.find<ProductsController>();
      showItemSelectionDialog(
        context: context,
        title: LangKeys.selectProducts.tr,
        allItems: productsController.allProducts
            .map((p) => SelectableItem(id: p.id, name: p.name))
            .toList(),
        initiallySelectedIds: targetIds,
        onConfirm: (selectedIds) {
          targetIds.assignAll(selectedIds);
          _updateTargetNames();
        },
      );
    } else {
      final categoriesController = Get.find<CategoriesController>();
      showItemSelectionDialog(
        context: context,
        title: LangKeys.selectCategories.tr,
        allItems: categoriesController.categories
            .map((c) => SelectableItem(id: c.id, name: c.name))
            .toList(),
        initiallySelectedIds: targetIds,
        onConfirm: (selectedIds) {
          targetIds.assignAll(selectedIds);
          _updateTargetNames();
        },
      );
    }
  }

  void _updateTargetNames() {
    if (targetIds.isEmpty) {
      targetNames.clear();
      return;
    }
    List<String> names = [];
    if (appliesTo.value == 'products') {
      final productsController = Get.find<ProductsController>();
      names = targetIds
          .map((id) => productsController.allProducts.firstWhereOrNull((p) => p.id == id)?.name)
          .whereType<String>()
          .toList();
    } else {
      final categoriesController = Get.find<CategoriesController>();
      names = targetIds
          .map((id) => categoriesController.categories.firstWhereOrNull((c) => c.id == id)?.name)
          .whereType<String>()
          .toList();
    }
    targetNames.assignAll(names);
  }

  Future<void> saveSale() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final saleData = SaleModel(
        id: saleToEdit.value?.id ?? '',
        // ID is handled by Firestore
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        discountPercentage: double.tryParse(discountController.text) ?? 0.0,
        startDate: Timestamp.fromDate(startDate.value),
        endDate: Timestamp.fromDate(endDate.value),
        isActive: isActive.value,
        appliesTo: appliesTo.value,
        targetIds: targetIds,
      );

      if (saleToEdit.value != null) {
        await _firestore
            .collection('sales')
            .doc(saleToEdit.value!.id)
            .update(saleData.toJson());
      } else {
        await _firestore.collection('sales').add(saleData.toJson());
      }

      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Sale saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save sale: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
