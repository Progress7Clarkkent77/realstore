import 'dart:convert';

import 'package:realstore/live/liveControllers/orderController.dart';
import 'package:realstore/live/models/orderModel.dart';
import 'package:realstore/live/pages/manageOrdersPage.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatelessWidget {
  OrdersPage({super.key});

  final OrderController orderCtrl = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Obx(() {
        if (orderCtrl.orders.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                    color: Colors.black54,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "No orders yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text("Your placed orders will appear here."),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orderCtrl.orders.length,
          itemBuilder: (_, index) {
            final order = orderCtrl.orders[index];

            return _orderCard(order, isDesktop);
          },
        );
      }),
    );
  }

  Widget _orderCard(OrderModel order, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop ? _desktopLayout(order) : _mobileLayout(order),
    );
  }

  Widget _desktopLayout(OrderModel order) {
    return Row(
      children: [
        _imagePreview(order),
        const SizedBox(width: 20),
        Expanded(child: _orderInfo(order)),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _statusChip(order),
            const SizedBox(height: 15),
            SizedBox(width: 220, child: _currentLocation(order)),
            const SizedBox(height: 15),
            _actionButtons(order),
          ],
        ),
      ],
    );
  }

  Widget _mobileLayout(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _imagePreview(order),
            const SizedBox(width: 15),
            Expanded(child: _orderInfo(order)),
          ],
        ),
        const SizedBox(height: 15),
        _statusChip(order),
        const SizedBox(height: 12),
        _currentLocation(order),
        const SizedBox(height: 15),
        _actionButtons(order),
      ],
    );
  }

  Widget _imagePreview(OrderModel order) {
    String image = '';

    if (order.items.isNotEmpty) {
      image = order.items.first.image;
    }

    return Container(
      width: 95,
      height: 95,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: image.isEmpty
          ? const Center(child: Icon(Icons.image_outlined, size: 40))
          : Image.memory(base64Decode(image), fit: BoxFit.cover),
    );
  }

  Widget _orderInfo(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order #${order.id.substring(0, 8).toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          "${order.items.length} item(s)",
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          order.createdAt == null
              ? ''
              : DateFormat("dd MMM yyyy, hh:mm a").format(order.createdAt!),
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Text(
          "₦${order.totalAmount.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _statusChip(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(),
      ),
      child: Text(
        order.status,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _currentLocation(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              order.currentLocation.isEmpty
                  ? "Order Received"
                  : order.currentLocation,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(OrderModel order) {
    final orderCtrl = Get.find<OrderController>();

    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: () {
          orderCtrl.selectOrder(order);

          Get.to(() => OrderDetailsPage());
        },
        icon: const Icon(
          Icons.receipt_long_outlined,
          color: Colors.black,
          size: 18,
        ),
        label: const Text(
          "View Details",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  OrderDetailsPage({super.key});

  final OrderController orderCtrl = Get.find<OrderController>();
  final AuthController1 authCtrl = Get.find<AuthController1>();

  @override
  Widget build(BuildContext context) {
    final order = orderCtrl.selectedOrder.value;

    if (order == null) {
      return const Scaffold(body: Center(child: Text("Order not found")));
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    // ✅ FORCE EMAIL AS CUSTOMER NAME
    final customerEmail = authCtrl.currentUser?.email ?? order.customerName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _leftSection(order)),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: _rightSection(order, customerEmail),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _leftSection(order),
                      const SizedBox(height: 20),
                      _rightSection(order, customerEmail),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ================= LEFT =================
  Widget _leftSection(OrderModel order) {
    return Column(
      children: [
        _orderHeader(order),
        const SizedBox(height: 20),
        _productsCard(order),
      ],
    );
  }

  // ================= RIGHT =================
  Widget _rightSection(OrderModel order, String customerEmail) {
    return Column(
      children: [
        _customerCard(order, customerEmail),
        const SizedBox(height: 20),
        _locationCard(order),
        const SizedBox(height: 20),
        _summaryCard(order),
      ],
    );
  }

  // ================= HEADER =================
  Widget _orderHeader(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order #${order.id.substring(0, 8).toUpperCase()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(
            order.createdAt == null
                ? ''
                : DateFormat("dd MMM yyyy, hh:mm a").format(order.createdAt!),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(),
            ),
            child: Text(
              order.status,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCTS =================
  Widget _productsCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ordered Products",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...order.items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 85,
                    height: 85,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: item.image.isEmpty
                        ? const Icon(Icons.image_outlined)
                        : Image.memory(
                            base64Decode(item.image),
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Quantity: ${item.quantity}"),
                      ],
                    ),
                  ),
                  Text(
                    "₦${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= CUSTOMER =================
  Widget _customerCard(OrderModel order, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // ✅ EMAIL USED HERE
          Text("Email: $email"),
          const SizedBox(height: 10),

          Text("Phone: ${order.customerPhoneNumber}"),
          const SizedBox(height: 10),

          Text("Address: ${order.customerDeliveryAddress}"),
        ],
      ),
    );
  }

  // ================= LOCATION =================
  Widget _locationCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              order.currentLocation.isEmpty
                  ? "Processing"
                  : order.currentLocation,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          _summaryRow("Subtotal", "₦${order.subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          _summaryRow(
            "Delivery Fee",
            "₦${order.deliveryFee.toStringAsFixed(2)}",
          ),
          const Divider(height: 30),
          _summaryRow(
            "Total",
            "₦${order.totalAmount.toStringAsFixed(2)}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false}) {
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
