import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/form_section_card.dart';
import '../../../../core/shared_widgets/image_uploader_widget.dart';
import '../controllers/category_form_controller.dart';

class CategoryFormScreen extends StatelessWidget {
  const CategoryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryFormController controller = Get.put(CategoryFormController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(
              () => Text(
            controller.categoryToEdit.value == null
                ? LangKeys.addCategory.tr
                : LangKeys.editCategory.tr,
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  FormSectionCard(
                    title: LangKeys.categoryDetails.tr,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.nameController,
                          decoration: InputDecoration(
                            labelText: LangKeys.categoryName.tr,
                            prefixIcon:
                            const Icon(Icons.label_important_outline),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? LangKeys.fieldRequired.tr : null,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        Obx(
                              () => DropdownButtonFormField<String>(
                            value: controller.parentCategoryId.value,
                            hint: Text(LangKeys.parentCategory.tr),
                            onChanged: controller.onParentCategoryChanged,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(LangKeys.noParent.tr),
                              ),
                              ...controller.availableParentCategories
                                  .map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Text(cat.name),
                                );
                              }).toList(),
                            ],
                            decoration: InputDecoration(
                              labelText: LangKeys.parentCategory.tr,
                              prefixIcon: const Icon(Icons.account_tree_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        TextFormField(
                          controller: controller.descriptionController,
                          decoration: InputDecoration(
                            labelText: LangKeys.categoryDescription.tr,
                            prefixIcon: const Icon(Icons.description_outlined),
                          ),
                          maxLines: 4,
                          minLines: 2,
                        ),
                      ],
                    ),
                  ),
                  FormSectionCard(
                    title: LangKeys.categoryImage.tr,
                    child: ImageUploaderWidget(
                      urlController: controller.urlController,
                      initialImageUrl: controller.categoryToEdit.value?.imageUrl,
                      onFileSelected: controller.onFileSelected,
                    ),
                  ),
                ],
              ),
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
                onPressed: controller.saveCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
