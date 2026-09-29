import 'dart:convert';

import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/liveControllers/ecommerceStoreController.dart';
import 'package:realstore/live/models/productModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ecommerce_routes.dart';

class ProductDetailsPage extends StatelessWidget {
  ProductDetailsPage({super.key});

  final nav = Get.find<EcommerceLiveNavController>();

  final storeCtrl = Get.find<EcommerceStoreController>();

  final cartCtrl = Get.find<EcommerceCartController>();

  final RxInt quantity = 1.obs;

  final RxInt currentImageIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = storeCtrl.selectedProduct.value;

      if (product == null) {
        return const Scaffold(body: Center(child: Text('Product not found')));
      }

      final width = MediaQuery.of(context).size.width;

      final isDesktop = width > 900;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Product Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(
            //     Icons.shopping_cart_outlined,
            //   ),
            //   onPressed: () {
            //     nav.goTo(
            //       EcommerceLiveRoutes.cart,
            //     );
            //   },
            // )
            Obx(
              () => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      nav.goTo(EcommerceLiveRoutes.cart);
                    },
                  ),
                  if (cartCtrl.cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCtrl.cartCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _gallerySection(product)),
                    const SizedBox(width: 40),
                    Expanded(flex: 4, child: _detailsSection(product)),
                  ],
                )
              : Column(
                  children: [
                    _gallerySection(product),
                    const SizedBox(height: 20),
                    _detailsSection(product),
                  ],
                ),
        ),
      );
    });
  }

  Widget _gallerySection(ProductModel product) {
    return Obx(() {
      final imageIndex = currentImageIndex.value;

      final width = Get.width;

      final imageHeight = width < 600 ? 250.0 : 450.0;

      return Column(
        children: [
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: product.images.isEmpty
                      ? const Center(
                          child: Icon(Icons.image_outlined, size: 70),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.memory(
                            base64Decode(product.images[imageIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),

                //--------------------------------
                // LEFT ARROW
                //--------------------------------
                if (product.images.length > 1)
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (currentImageIndex.value > 0) {
                              currentImageIndex.value--;
                            } else {
                              currentImageIndex.value =
                                  product.images.length - 1;
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                //--------------------------------
                // RIGHT ARROW
                //--------------------------------
                if (product.images.length > 1)
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (currentImageIndex.value <
                                product.images.length - 1) {
                              currentImageIndex.value++;
                            } else {
                              currentImageIndex.value = 0;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          //--------------------------------
          // IMAGE INDICATORS
          //--------------------------------
          if (product.images.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImageIndex.value == index
                        ? Colors.black
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _detailsSection(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Text("₦${product.price.toStringAsFixed(2)}"),
        const SizedBox(height: 10),
        Text(product.stock > 0 ? "In Stock" : "Out Of Stock"),
        const SizedBox(height: 25),
        const Text(
          "Description",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(product.description),
        const SizedBox(height: 30),
        _quantitySelector(),
        const SizedBox(height: 25),
        _buttons(product),
        const SizedBox(height: 35),
        _specifications(product),
        const SizedBox(height: 35),
        _relatedProducts(product),
      ],
    );
  }

  Widget _quantitySelector() {
    return Row(
      children: [
        const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Obx(
          () => Row(
            children: [
              _qtyBtn(Icons.remove, () {
                if (quantity.value > 1) {
                  quantity.value--;
                }
              }),
              const SizedBox(width: 12),
              Text(
                quantity.value.toString(),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 12),
              _qtyBtn(Icons.add, () {
                quantity.value++;
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _buttons(ProductModel product) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () async {
              await cartCtrl.addToCart(product, quantity: quantity.value);

              Get.snackbar(
                "Added To Cart",
                "${quantity.value} ${product.name} added to cart",
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            label: const Text(
              "Add To Cart",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await cartCtrl.addToCart(product, quantity: quantity.value);

              nav.goTo(EcommerceLiveRoutes.cart);
            },
            child: const Text("Buy Now"),
          ),
        ),
      ],
    );
  }

  Widget _specifications(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Specifications",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text("Category: ${product.category}"),
        Text("Stock: ${product.stock}"),
        Text("Delivery Fee: ₦${product.deliveryFee}"),
        Text(product.isActive ? "Status: Active" : "Status: Inactive"),
      ],
    );
  }

  Widget _relatedProducts(ProductModel product) {
    final relatedProducts = storeCtrl.products
        .where(
          (item) => item.category == product.category && item.id != product.id,
        )
        .take(10)
        .toList();

    if (relatedProducts.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Related Products",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            itemBuilder: (_, index) {
              final related = relatedProducts[index];

              return InkWell(
                onTap: () {
                  currentImageIndex.value = 0;

                  storeCtrl.selectProduct(related);

                  nav.goTo(EcommerceLiveRoutes.productDetails);
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: related.images.isEmpty
                              ? const Center(child: Icon(Icons.image_outlined))
                              : Image.memory(
                                  base64Decode(related.images.first),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              related.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₦${related.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
