import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/liveControllers/orderController.dart';
import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:realstore/platformControllers/themeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutPage extends StatelessWidget {
  CheckoutPage({super.key});

  //  final TextEditingController nameCtrl = TextEditingController();

  final TextEditingController phoneCtrl = TextEditingController();

  final TextEditingController addressCtrl = TextEditingController();

  final authCtrl = Get.find<AuthController1>();
  final cartCtrl = Get.find<EcommerceCartController>();
  final orderCtrl = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode;
    //  nameCtrl.text = authCtrl.currentUser?.displayName ?? '';

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Checkout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Shipping Information",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Text(
                          authCtrl.currentUser?.email ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Delivery Address",
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Order Summary",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => Column(
                      children: cartCtrl.cartItems.map((item) {
                        return _summaryTile(
                          "${item.product.name} x${item.quantity}",
                          "₦${(item.product.price * item.quantity).toStringAsFixed(2)}",
                        );
                      }).toList(),
                    ),
                  ),
                  Obx(
                    () => _summaryTile(
                      "Delivery",
                      "₦${cartCtrl.deliveryFee.toStringAsFixed(2)}",
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => _summaryTile(
                      "Total",
                      "₦${cartCtrl.grandTotal.toStringAsFixed(2)}",
                      bold: true,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark.value
                            ? Colors.white
                            : Colors.black,
                        foregroundColor: isDark.value
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: () async {
                        if (phoneCtrl.text.trim().isEmpty) {
                          Get.snackbar("Phone Required", "Enter phone number");
                          return;
                        }

                        if (addressCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            "Address Required",
                            "Enter delivery address",
                          );
                          return;
                        }

                        await orderCtrl.placeOrder(
                          phone: phoneCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                        );
                      },
                      child: const Text("Place Order"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryTile(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
      ),
    );
  }
}
