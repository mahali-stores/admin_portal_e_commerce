import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/form_section_card.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../controllers/product_form_controller.dart';

class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductFormController controller = Get.put(ProductFormController());
    // Ensure dependent controllers are ready
    Get.put(BrandsController());
    Get.put(CategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.productToEdit.value == null ? LangKeys.addProduct.tr : LangKeys.editProduct.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: controller.formKey,
          child: LayoutBuilder(builder: (context, constraints) {
            // Use a responsive two-column layout on wider screens
            if (constraints.maxWidth > 900) {
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
                        _buildStatusCard(controller),
                        _buildCategorizationCard(controller),
                        _buildImageCard(controller),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Use a single-column layout on narrower screens
              return Column(
                children: [
                  _buildBasicInfoCard(controller),
                  _buildStatusCard(controller),
                  _buildCategorizationCard(controller),
                  _buildImageCard(controller),
                  _buildVariantsCard(controller),
                ],
              );
            }
          }),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save_alt_outlined),
          label: Text(LangKeys.save.tr.toUpperCase()),
          onPressed: controller.saveProduct,
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ProductFormController controller) {
    return FormSectionCard(
      title: 'Basic Information',
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
            decoration: InputDecoration(labelText: LangKeys.productName.tr),
            validator: (v) => v!.isEmpty ? LangKeys.fieldRequired.tr : null,
          ),
          const SizedBox(height: kDefaultPadding),
          TextFormField(
            controller: controller.descriptionController,
            decoration: InputDecoration(labelText: LangKeys.productDescription.tr),
            maxLines: 6,
            minLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ProductFormController controller) {
    return FormSectionCard(
      title: 'Status',
      child: Obx(
            () => SwitchListTile(
          title: const Text('Featured Product'),
          value: controller.isFeatured.value,
          onChanged: (val) => controller.isFeatured.value = val,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildCategorizationCard(ProductFormController controller) {
    final BrandsController brandsController = Get.find();
    final CategoriesController categoriesController = Get.find();

    return FormSectionCard(
      title: 'Categorization',
      child: Column(
        children: [
          Obx(
                () => DropdownButtonFormField<BrandModel>(
              value: controller.selectedBrand.value,
              hint: Text(LangKeys.productBrand.tr),
              onChanged: (val) => controller.selectedBrand.value = val,
              items: brandsController.allBrands.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
              validator: (v) => v == null ? LangKeys.fieldRequired.tr : null,
              decoration: InputDecoration(labelText: LangKeys.productBrand.tr),
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Obx(
                () => MultiSelectDialogField<CategoryModel>(
              buttonText: Text(LangKeys.productCategories.tr),
              title: Text(LangKeys.selectCategories.tr),
              items: categoriesController.categories.map((c) => MultiSelectItem(c, c.name)).toList(),
              listType: MultiSelectListType.CHIP,
              onConfirm: (values) {
                controller.selectedCategories.value = values;
              },
              initialValue: controller.selectedCategories.toList(),
              chipDisplay: MultiSelectChipDisplay(
                onTap: (value) {
                  controller.selectedCategories.remove(value);
                },
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.productImages.tr,
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: controller.pickProductImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text("Add Images"),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
          ),
          const SizedBox(height: kDefaultPadding),
          Obx(() {
            if (controller.productImages.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(child: Text("No images selected.", style: TextStyle(color: kSecondaryTextColor))),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: controller.productImages.length,
              itemBuilder: (context, index) {
                final imageSource = controller.productImages[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultRadius / 2),
                      child: imageSource.data is String
                          ? Image.network(imageSource.data as String, fit: BoxFit.cover)
                          : Image.memory(imageSource.data as Uint8List, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => controller.removeProductImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVariantsCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.productVariants.tr,
      child: Column(
        children: [
          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.variantForms.length,
            itemBuilder: (ctx, index) => _buildVariantForm(controller, index),
            separatorBuilder: (ctx, index) => const Divider(height: kDefaultPadding * 2),
          )),
          const SizedBox(height: kDefaultPadding),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(LangKeys.addVariant.tr),
            onPressed: controller.addVariantForm,
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantForm(ProductFormController controller, int index) {
    final formState = controller.variantForms[index];
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Variant ${index + 1}", style: Get.textTheme.titleMedium),
              if (controller.variantForms.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kErrorColor),
                  onPressed: () => controller.removeVariantForm(index),
                ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          TextFormField(
            controller: formState.attributesController,
            decoration: InputDecoration(
              labelText: LangKeys.variantAttributes.tr,
              hintText: 'e.g., Color:Red, Size:XL',
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: formState.priceController,
                  decoration: InputDecoration(labelText: LangKeys.price.tr),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              Expanded(
                child: TextFormField(
                  controller: formState.stockController,
                  decoration: InputDecoration(labelText: LangKeys.stockQuantity.tr),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          TextFormField(
            controller: formState.skuController,
            decoration: InputDecoration(labelText: LangKeys.sku.tr),
          ),
        ],
      ),
    );
  }
}
