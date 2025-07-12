import 'dart:typed_data';
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
    // Initialize controllers. Using permanent: true can help retain state if you
    // navigate to another screen (like 'add new brand') and then return.
    final ProductFormController controller = Get.put(ProductFormController());
    Get.put(BrandsController(), permanent: true);
    Get.put(CategoriesController(), permanent: true);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.productToEdit.value == null
            ? LangKeys.addProduct.tr
            : LangKeys.editProduct.tr)),
      ),
      body: Center(
        child: SizedBox(
          width: 1200,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Form(
              key: controller.formKey,
              child: LayoutBuilder(builder: (context, constraints) {
                // Responsive layout for wide vs. narrow screens
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildBasicInfoCard(controller),
                            _buildProductAttributesCard(controller),
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
                }
                // Layout for smaller screens
                return Column(
                  children: [
                    _buildBasicInfoCard(controller),
                    _buildProductAttributesCard(controller),
                    _buildStatusCard(controller),
                    _buildCategorizationCard(controller),
                    _buildImageCard(controller),
                    _buildVariantsCard(controller),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(LangKeys.cancel.tr),
              ),
              const SizedBox(width: kDefaultPadding),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: Text(LangKeys.save.tr.toUpperCase()),
                onPressed: controller.saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.basicInformation.tr,
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
            decoration:
            InputDecoration(labelText: LangKeys.productDescription.tr),
            maxLines: 6,
            minLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.status.tr,
      child: Obx(
            () => SwitchListTile(
          title: Text(LangKeys.featuredProduct.tr),
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
      title: LangKeys.categorization.tr,
      child: Column(
        children: [
          Obx(
                () => DropdownButtonFormField<BrandModel>(
              value: controller.selectedBrand.value,
              hint: Text(LangKeys.productBrand.tr),
              onChanged: (val) => controller.selectedBrand.value = val,
              items: brandsController.allBrands
                  .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                  .toList(),
              validator: (v) => v == null ? LangKeys.fieldRequired.tr : null,
              decoration: InputDecoration(labelText: LangKeys.productBrand.tr),
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          Obx(
                () => MultiSelectDialogField<CategoryModel>(
              buttonText: Text(LangKeys.productCategories.tr),
              title: Text(LangKeys.selectCategories.tr),
              items: categoriesController.flattenedCategoriesForDisplay
                  .map((c) => MultiSelectItem(c, c.name))
                  .toList(),
              listType: MultiSelectListType.LIST,
              onConfirm: (values) {
                controller.selectedCategories.value = values;
              },
              initialValue: controller.selectedCategories.toList(),
              chipDisplay: MultiSelectChipDisplay.none(),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
              selectedItemsTextStyle:
              TextStyle(color: Get.theme.primaryColor),
            ),
          ),
          Obx(() {
            if (controller.selectedCategories.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: controller.selectedCategories
                    .map((item) => Chip(
                  label: Text(
                      item.name.replaceAll(RegExp(r'—\s*'), '')),
                  onDeleted: () {
                    controller.selectedCategories.remove(item);
                  },
                ))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.productImages.tr,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickProductImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(LangKeys.addImages.tr),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 45)),
                ),
              ),
              const SizedBox(width: kDefaultPadding / 2),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.dialog(_UrlInputDialog(controller: controller));
                  },
                  icon: const Icon(Icons.link),
                  label: Text(LangKeys.addImageUrls.tr),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 45)),
                ),
              ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          Obx(() {
            if (controller.productImages.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(
                    child: Text(LangKeys.noImagesSelected.tr,
                        style: const TextStyle(color: kSecondaryTextColor))),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: controller.productImages.length,
              itemBuilder: (context, index) {
                // This part should be updated to use the ImageSourceData model
                final imageSource = controller.productImages[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultRadius / 2),
                      child: imageSource.data is String
                          ? Image.network(imageSource.data as String,
                          fit: BoxFit.cover)
                          : Image.memory(imageSource.data as Uint8List,
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => controller.removeProductImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                          Icon(Icons.close, color: Colors.white, size: 16),
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

  /// Builds the card for managing the MASTER list of attribute names.
  Widget _buildProductAttributesCard(ProductFormController controller) {
    return FormSectionCard(
      title: "Product Attributes",
      child: Column(
        children: [
          // This Obx correctly rebuilds the list when attributes are added or removed.
          Obx(
                () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.productAttributeNames.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.productAttributeNames[index],
                        decoration: InputDecoration(
                          labelText: 'Attribute Name ${index + 1}',
                          hintText: 'e.g. Color, Size...',
                        ),
                        validator: (v) =>
                        v!.trim().isEmpty ? LangKeys.fieldRequired.tr : null,
                      ),
                    ),
                    if (controller.productAttributeNames.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: kErrorColor),
                        onPressed: () =>
                            controller.removeProductAttribute(index),
                      )
                  ],
                );
              },
              separatorBuilder: (_, __) =>
              const SizedBox(height: kDefaultPadding),
            ),
          ),
          const SizedBox(height: kDefaultPadding),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text("Add Attribute Name"),
            onPressed: controller.addProductAttribute,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45)),
          ),
        ],
      ),
    );
  }

  /// Builds the card that contains the list of variants.
  Widget _buildVariantsCard(ProductFormController controller) {
    return FormSectionCard(
      title: LangKeys.productVariants.tr,
      child: Column(
        children: [
          // This Obx correctly rebuilds the list when variants are added or removed.
          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.variantForms.length,
            itemBuilder: (ctx, index) =>
                _buildVariantForm(controller, index),
            separatorBuilder: (ctx, index) =>
            const Divider(height: kDefaultPadding * 2),
          )),
          const SizedBox(height: kDefaultPadding),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(LangKeys.addVariant.tr),
            onPressed: controller.addVariantForm,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45)),
          ),
        ],
      ),
    );
  }

  /// Builds the UI for a SINGLE variant.
  Widget _buildVariantForm(ProductFormController controller, int index) {
    final formState = controller.variantForms[index];

    // Using an AnimatedBuilder is an efficient way to make the UI listen to changes
    // in the text of the attribute name controllers without needing a complex Obx structure.
    return AnimatedBuilder(
      animation: Listenable.merge(controller.productAttributeNames),
      builder: (context, child) {
        return Container(
          key: ValueKey(formState
              .hashCode), // A key helps Flutter manage the state of the widget correctly
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${LangKeys.variant.tr} ${index + 1}",
                      style: Get.textTheme.titleMedium),
                  if (controller.variantForms.length > 1)
                    IconButton(
                      icon:
                      const Icon(Icons.delete_outline, color: kErrorColor),
                      onPressed: () => controller.removeVariantForm(index),
                    ),
                ],
              ),
              const SizedBox(height: kDefaultPadding),

              // This ListView is built directly. It's inside an Obx (for the variants list)
              // and an AnimatedBuilder (for the attribute names), so it will update correctly and efficiently.
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.productAttributeNames.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: kDefaultPadding),
                itemBuilder: (context, attrIndex) {
                  final attrNameController =
                  controller.productAttributeNames[attrIndex];
                  final attrValueController =
                  formState.attributeValueControllers[attrIndex];

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          attrNameController.text.trim().isEmpty
                              ? 'Attribute ${attrIndex + 1}'
                              : attrNameController.text.trim(),
                          style: Get.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      Expanded(
                        child: TextFormField(
                          controller: attrValueController,
                          decoration: const InputDecoration(labelText: 'Value'),
                          validator: (v) =>
                          v!.trim().isEmpty ? LangKeys.fieldRequired.tr : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: kDefaultPadding),

              // --- Price, Stock, SKU Fields ---
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: formState.priceController,
                      decoration: InputDecoration(labelText: LangKeys.price.tr),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                      v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: formState.stockController,
                      decoration:
                      InputDecoration(labelText: LangKeys.stockQuantity.tr),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                      v!.isEmpty ? LangKeys.fieldRequired.tr : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kDefaultPadding),
              TextFormField(
                controller: formState.skuController,
                decoration: InputDecoration(labelText: LangKeys.sku.tr),
              ),
              const SizedBox(height: kDefaultPadding),

              // --- Variant Image Section ---
              const Divider(),
              const SizedBox(height: kDefaultPadding / 2),
              OutlinedButton.icon(
                onPressed: () => controller.pickVariantImages(index),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                    LangKeys.addVariantImage.tr), // Add key to your lang files
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45)),
              ),
              const SizedBox(height: kDefaultPadding),
              Obx(() {
                if (formState.images.isEmpty) {
                  return Center(
                    child: Text(
                      LangKeys.noImagesSelected.tr,
                      style: const TextStyle(color: kSecondaryTextColor),
                    ),
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
                  itemCount: formState.images.length,
                  itemBuilder: (context, imageIndex) {
                    final imageSource = formState.images[imageIndex];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(kDefaultRadius / 2),
                          child: imageSource.data is String
                              ? Image.network(imageSource.data as String,
                              fit: BoxFit.cover)
                              : Image.memory(imageSource.data as Uint8List,
                              fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => controller.removeVariantImage(
                                index, imageIndex),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// A dialog for entering image URLs.
class _UrlInputDialog extends StatelessWidget {
  final ProductFormController controller;
  const _UrlInputDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LangKeys.enterImageUrls.tr),
      content: SizedBox(
        width: Get.width * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.urlControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.urlControllers[index],
                              decoration: InputDecoration(
                                labelText:
                                "${LangKeys.imageUrl.tr} ${index + 1}",
                                hintText: LangKeys.imageUrlHint.tr,
                              ),
                            ),
                          ),
                          if (controller.urlControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: kErrorColor),
                              onPressed: () =>
                                  controller.removeUrlField(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => {}, // controller.addUrlField,
                icon: const Icon(Icons.add),
                label: Text(LangKeys.addUrl.tr),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text(LangKeys.cancel.tr),
        ),
        ElevatedButton(
          onPressed: () => {}, // controller.addImageUrlsFromDialog,
          child: Text(LangKeys.addImages.tr),
        ),
      ],
    );
  }
}