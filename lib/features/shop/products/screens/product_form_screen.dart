import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../controllers/product_form_controller.dart';

class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductFormController controller = Get.put(ProductFormController());

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.productToEdit.value == null ? LangKeys.addProduct.tr : LangKeys.editProduct.tr),
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Form(
              key: controller.formKey,
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  // Single Column Layout for Mobile
                  return Column(
                    children: [
                      _buildBasicInfoCard(controller),
                      _buildImageCard(controller),
                      _buildCategorizationCard(context, controller),
                      _buildVariantsCard(controller),
                    ],
                  );
                } else {
                  // Two Column Layout for Desktop
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildBasicInfoCard(controller),
                            _buildVariantsCard(controller),
                          ],
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildImageCard(controller),
                            _buildCategorizationCard(context, controller),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ),
          if (controller.isLoading.value)
            Container(color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator())),
        ],
      )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(LangKeys.save.tr),
          onPressed: controller.isLoading.value ? null : controller.saveProduct,
        ),
      ),
    );
  }

  // Helper methods to build form sections for better organization

  Widget _buildFormSection({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(height: kDefaultPadding),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ProductFormController controller) {
    return _buildFormSection(
      title: 'Basic Information',
      child: Column(
        children: [
          TextFormField(controller: controller.nameController, decoration: InputDecoration(labelText: LangKeys.productName.tr), validator: (v) => v!.isEmpty ? LangKeys.fieldRequired.tr : null),
          const SizedBox(height: kDefaultPadding),
          TextFormField(controller: controller.descriptionController, decoration: InputDecoration(labelText: LangKeys.productDescription.tr), maxLines: 6, minLines: 3),
        ],
      ),
    );
  }

  Widget _buildImageCard(ProductFormController controller) {
    return _buildFormSection(
      title: LangKeys.productImages.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The new "Add Images" button
          OutlinedButton.icon(
            onPressed: controller.pickProductImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text("Add Product Images"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45), // Make button wider
            ),
          ),
          const SizedBox(height: kDefaultPadding),

          // The image gallery display logic remains the same
          Obx(() {
            if (controller.imageUrls.isEmpty) {
              return const Center(child: Text("No images selected.", style: TextStyle(color: kSecondaryTextColor)));
            }
            return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: controller.imageUrls.length,
                itemBuilder: (context, index) {
                  final image = controller.imageUrls[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kDefaultRadius),
                        child: image is String
                            ? Image.network(image, fit: BoxFit.cover)
                            : Image.memory(image as Uint8List, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => controller.imageUrls.removeAt(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  );
                });
          }
          )
        ],
      ),
    );
  }

  Widget _buildCategorizationCard(BuildContext context, ProductFormController controller) {
    final BrandsController brandsController = Get.find();
    final CategoriesController categoriesController = Get.find();
    return _buildFormSection(
        title: 'Categorization',
        child: Column(
          children: [
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedBrandId.value,
              hint: Text(LangKeys.productBrand.tr),
              onChanged: (val) => controller.selectedBrandId.value = val,
              items: brandsController.allBrands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              validator: (v) => v == null ? LangKeys.fieldRequired.tr : null,
            )),
            const SizedBox(height: kDefaultPadding),
            OutlinedButton.icon(
              icon: const Icon(Icons.category_outlined),
              label: Text(LangKeys.productCategories.tr),
              onPressed: () => controller.openCategorySelectionDialog(context, categoriesController.categories),
            ),
            const SizedBox(height: kDefaultPadding / 2),
            Obx(() => Wrap(spacing: 8, children: controller.selectedCategoryNames.map((name) => Chip(label: Text(name))).toList())),
          ],
        ));
  }

  Widget _buildVariantsCard(ProductFormController controller) {
    return _buildFormSection(
        title: LangKeys.productVariants.tr,
        child: Column(
          children: [
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.variantForms.length,
              itemBuilder: (ctx, index) => _buildVariantForm(controller, index),
            )),
            const SizedBox(height: kDefaultPadding),
            OutlinedButton.icon(icon: const Icon(Icons.add), label: Text(LangKeys.addVariant.tr), onPressed: controller.addVariantForm),
          ],
        ));
  }

  Widget _buildVariantForm(ProductFormController controller, int index) {
    final formState = controller.variantForms[index];
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding / 2),
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: kBackgroundColor),
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Column(
        children: [
          if (controller.variantForms.length > 1)
            Align(alignment: Alignment.topRight, child: IconButton(icon: const Icon(Icons.close, color: kErrorColor), onPressed: () => controller.removeVariantForm(index))),
          TextFormField(controller: formState.attributesController, decoration: InputDecoration(labelText: LangKeys.variantAttributes.tr, hintText: 'Color:Red, Size:XL')),
          const SizedBox(height: kDefaultPadding),
          Row(
            children: [
              Expanded(child: TextFormField(controller: formState.priceController, decoration: InputDecoration(labelText: LangKeys.price.tr), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? LangKeys.fieldRequired.tr : null)),
              const SizedBox(width: kDefaultPadding),
              Expanded(child: TextFormField(controller: formState.stockController, decoration: InputDecoration(labelText: LangKeys.stockQuantity.tr), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? LangKeys.fieldRequired.tr : null)),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          TextFormField(controller: formState.skuController, decoration: InputDecoration(labelText: LangKeys.sku.tr)),
        ],
      ),
    );
  }
}