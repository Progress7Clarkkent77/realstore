import 'dart:convert';

import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final nav = Get.find<EcommerceLiveNavController>();
  final cartCtrl = Get.find<EcommerceCartController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Shopping Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isDesktop
          ? Row(
              children: [
                Expanded(flex: 7, child: _cartItems()),
                SizedBox(width: 350, child: _summaryCard()),
              ],
            )
          : Column(
              children: [
                Expanded(child: _cartItems()),
                _summaryCard(),
              ],
            ),
    );
  }

  Widget _cartItems() {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: cartCtrl.cartItems.length,
        itemBuilder: (_, index) {
          final item = cartCtrl.cartItems[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: item.product.images.isEmpty
                      ? const Icon(Icons.image)
                      : Image.memory(
                          base64Decode(item.product.images.first),
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.name),
                      const SizedBox(height: 5),
                      Text("₦${item.product.price}"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              cartCtrl.decreaseQty(item.product);
                            },
                            child: _qtyBtn(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(item.quantity.toString()),
                          ),
                          GestureDetector(
                            onTap: () {
                              cartCtrl.increaseQty(item.product);
                            },
                            child: _qtyBtn(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cartCtrl.removeItem(item.product);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _qtyBtn(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18),
    );
  }

  Widget _summaryCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _row("Subtotal", "₦${cartCtrl.subtotal.toStringAsFixed(2)}"),
          ),
          const SizedBox(height: 10),
          Obx(
            () =>
                _row("Delivery", "₦${cartCtrl.deliveryFee.toStringAsFixed(2)}"),
          ),
          const Divider(height: 30),
          Obx(
            () => _row(
              "Total",
              "₦${cartCtrl.grandTotal.toStringAsFixed(2)}",
              bold: true,
            ),
          ),
          const SizedBox(height: 25),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: cartCtrl.cartItems.isEmpty
                    ? null
                    : () {
                        nav.goTo(EcommerceLiveRoutes.checkout);
                      },
                child: Text(
                  cartCtrl.cartItems.isEmpty
                      ? "Cart Empty"
                      : "Proceed to Checkout",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool bold = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
