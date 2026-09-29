import 'package:realstore/live/liveControllers/uploadProductController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UploadProductsPage extends StatelessWidget {
  UploadProductsPage({super.key});

  final uploadCtrl = Get.put(UploadProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Upload Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: Obx(
                () => InkWell(
                  onTap: uploadCtrl.pickImages,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: uploadCtrl.selectedImages.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 40),
                                SizedBox(height: 10),
                                Text("Select Product Images"),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: uploadCtrl.selectedImages.length,
                            itemBuilder: (_, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 180,
                                    margin: const EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.memory(
                                        uploadCtrl.selectedImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      onPressed: () {
                                        uploadCtrl.removeImage(index);
                                      },
                                      icon: const CircleAvatar(
                                        radius: 14,
                                        child: Icon(Icons.close, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: uploadCtrl.nameCtrl,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Obx(
              () => DropdownButtonFormField<String>(
                value: uploadCtrl.selectedCategory.value.isEmpty
                    ? null
                    : uploadCtrl.selectedCategory.value,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: uploadCtrl.categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    uploadCtrl.selectedCategory.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: uploadCtrl.priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: uploadCtrl.deliveryFeeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Delivery Fee",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: uploadCtrl.stockCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Stock Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: uploadCtrl.descriptionCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: uploadCtrl.isLoading.value
                      ? null
                      : uploadCtrl.uploadProduct,
                  child: uploadCtrl.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Upload Product",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
