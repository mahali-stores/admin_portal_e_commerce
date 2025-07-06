import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/lang_keys.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/shared_widgets/form_section_card.dart';
import '../../../../core/shared_widgets/image_uploader_widget.dart';
import '../controllers/brand_form_controller.dart';

class BrandFormScreen extends StatelessWidget {
  const BrandFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandFormController controller = Get.put(BrandFormController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.brandToEdit.value == null
              ? LangKeys.addBrand.tr
              : LangKeys.editBrand.tr,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              FormSectionCard(
                title: 'Brand Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        labelText: LangKeys.brandName.tr,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LangKeys.fieldRequired.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kDefaultPadding),
                    TextFormField(
                      controller: controller.descriptionController,
                      decoration: InputDecoration(
                        labelText: LangKeys.brandDescription.tr,
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              FormSectionCard(
                title: LangKeys.brandLogo.tr,
                child: ImageUploaderWidget(
                  // Pass the controller's TextEditingController to the widget
                  urlController: controller.urlController,
                  initialImageUrl: controller.brandToEdit.value?.logoUrl,
                  onFileSelected: controller.onFileSelected,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save_alt_outlined),
          label: Text(LangKeys.save.tr.toUpperCase()),
          onPressed: controller.saveBrand,
        ),
      ),
    );
  }
}
