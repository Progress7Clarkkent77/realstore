import 'dart:convert';

import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/liveControllers/ecommerceStoreController.dart';
import 'package:realstore/live/models/productModel.dart';
import 'package:realstore/live/pages/adminLoginPage.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:realstore/live/userAuth/authpages.dart';

import 'package:realstore/platformControllers/domainController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ecommerce_routes.dart';

class EcommerceHomePage extends StatelessWidget {
  final String organizationId;
  final String slug;

  EcommerceHomePage({
    super.key,
    required this.organizationId,
    required this.slug,
  });

  final nav = Get.put(EcommerceLiveNavController());
  final domainCtrl = Get.find<DomainController>();
  final authCtrl = Get.find<AuthController1>();
  final storeCtrl = Get.find<EcommerceStoreController>();
  final cartCtrl = Get.find<EcommerceCartController>();

  String get orgId => domainCtrl.organizationId.value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;

    if (width >= 1400) {
      crossAxisCount = 6;
    } else if (width >= 1100) {
      crossAxisCount = 5;
    } else if (width >= 800) {
      crossAxisCount = 4;
    } else if (width >= 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Obx(() {
        if (!authCtrl.isAuthenticated) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.logout),
          label: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            final confirmed = await Get.dialog<bool>(
              AlertDialog(
                backgroundColor: Colors.white,
                title: const Text("Logout"),
                content: const Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );

            if (confirmed != true) return;

            Get.dialog(
              const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(color: Colors.black),
                    SizedBox(width: 20),
                    Text(
                      "Logging out...",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              barrierDismissible: false,
            );

            try {
              await authCtrl.logout();

              // Close loading dialog
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }

              // Navigate
              final slug = Get.find<DomainController>().currentSlug.value;

              Get.offAllNamed('/$slug');
            } catch (e) {
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }

              Get.snackbar("Logout Failed", e.toString());
            }
          },
        );
      }),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(
          () => Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: domainCtrl.organizationLogo.value.isNotEmpty
                    ? NetworkImage(domainCtrl.organizationLogo.value)
                    : null,
                child: domainCtrl.organizationLogo.value.isEmpty
                    ? const Icon(Icons.store, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  domainCtrl.organizationName.value.isEmpty
                      ? "Store"
                      : domainCtrl.organizationName.value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Obx(() {
            if (!authCtrl.isAuthenticated) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () {
                    Get.to(
                      () => EarnLogin1(
                        organizationId: organizationId,
                        slug: slug,
                      ),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.receipt_long_outlined),
                  onPressed: () {
                    nav.goTo(EcommerceLiveRoutes.orders);
                  },
                ),
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
            );
          }),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              Get.to(
                () => EcommerceAdminLoginPage(
                  organizationId: organizationId,
                  slug: slug,
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _heroSection()),
          SliverToBoxAdapter(child: _searchSection()),
          SliverToBoxAdapter(child: _categorySection()),
          // const SliverToBoxAdapter(
          //   child: Padding(
          //     padding: EdgeInsets.fromLTRB(
          //       20,
          //       25,
          //       20,
          //       10,
          //     ),
          //     child: Text(
          //       "Featured Products",
          //       style: TextStyle(
          //         fontSize: 24,
          //         fontWeight: FontWeight.w700,
          //       ),
          //     ),
          //   ),
          // ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: Obx(
              () => SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, index) => _productCard(storeCtrl.filteredProducts[index]),
                  childCount: storeCtrl.filteredProducts.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: .72,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroSection() {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => Text(
              domainCtrl.organizationDescription.value.isEmpty
                  ? "Welcome to our online store."
                  : domainCtrl.organizationDescription.value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 18),

          /// ACTION ROW
          Obx(() {
            if (!authCtrl.isAuthenticated) {
              return OutlinedButton.icon(
                onPressed: () {
                  Get.to(
                    () =>
                        EarnLogin1(organizationId: organizationId, slug: slug),
                  );
                },
                icon: const Icon(Icons.login, size: 18, color: Colors.black),
                label: const Text(
                  "Login",
                  style: TextStyle(color: Colors.black),
                ),
              );
            }

            return Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    nav.goTo(EcommerceLiveRoutes.orders);
                  },
                  icon: const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "My Orders",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    nav.goTo(EcommerceLiveRoutes.cart);
                  },
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "Cart",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _searchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: storeCtrl.searchCtrl,
        onChanged: (value) {
          storeCtrl.searchText.value = value;
          storeCtrl.filterProducts();
        },
        decoration: InputDecoration(
          hintText: "Search by name, category or price",
          prefixIcon: const Icon(Icons.search),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _categorySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: storeCtrl.selectedCategory.value,
          decoration: InputDecoration(
            labelText: "Browse Category",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
          items: storeCtrl.categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;

            storeCtrl.selectedCategory.value = value;
            storeCtrl.filterProducts();
          },
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        storeCtrl.selectProduct(product);

        nav.goTo(EcommerceLiveRoutes.productDetails);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: product.images.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined, size: 40),
                      )
                    : Image.memory(
                        base64Decode(product.images.first),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "₦${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final cartCtrl = Get.find<EcommerceCartController>();

                        cartCtrl.addToCart(product);
                      },
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.black,
                        size: 18,
                      ),
                      label: const Text(
                        "Add",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
