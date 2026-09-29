import 'dart:convert';

import 'package:realstore/live/liveControllers/manageProductController.dart';
import 'package:realstore/live/models/productModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageProductsPage extends StatelessWidget {
  ManageProductsPage({super.key});

  final ManageProductsController ctrl = Get.put(ManageProductsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Manage Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ctrl.listenProducts();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                ctrl.searchQuery.value = value;
              },
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          /// PRODUCTS
          Expanded(
            child: Obx(() {
              final products = ctrl.filteredProducts;

              if (products.isEmpty) {
                return const Center(child: Text("No products found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                itemBuilder: (_, index) {
                  final product = products[index];

                  return _productCard(product);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        /// IMAGE
        leading: product.images.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(product.images.first),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_not_supported),
              ),

        /// DETAILS
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(product.category),
            const SizedBox(height: 4),
            Text("₦${product.price.toStringAsFixed(2)}"),
            const SizedBox(height: 4),
            Text("Stock: ${product.stock}"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.isActive
                    ? Colors.green.withOpacity(.1)
                    : Colors.red.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                product.isActive ? "Active" : "Inactive",
                style: TextStyle(
                  color: product.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        /// ACTIONS
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: "Enable / Disable",
                icon: Icon(
                  product.isActive ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  ctrl.toggleProductStatus(product);
                },
              ),
              IconButton(
                tooltip: "Delete Product",
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Delete Product",
                    middleText: "Are you sure you want to delete this product?",
                    textConfirm: "Delete",
                    textCancel: "Cancel",
                    confirmTextColor: Colors.white,
                    onConfirm: () async {
                      Get.back();

                      await ctrl.deleteProduct(product.id);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
