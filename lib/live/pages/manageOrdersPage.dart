import 'dart:convert';

import 'package:realstore/live/liveControllers/manageOrdersController.dart';
import 'package:realstore/live/models/orderModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ManageOrdersPage extends StatelessWidget {
  ManageOrdersPage({super.key});

  final ManageOrdersController ctrl = Get.put(ManageOrdersController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Manage Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.black26,
                ),
                SizedBox(height: 15),
                Text(
                  "No Orders Found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: ctrl.orders.length,
          itemBuilder: (_, index) {
            final order = ctrl.orders[index];

            return _orderCard(order, isDesktop);
          },
        );
      }),
    );
  }

  Widget _orderCard(OrderModel order, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isDesktop ? _desktopLayout(order) : _mobileLayout(order),
    );
  }

  Widget _desktopLayout(OrderModel order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _productImage(order),
        const SizedBox(width: 20),
        Expanded(child: _orderInfo(order)),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _statusChip(order),
            const SizedBox(height: 12),
            _locationChip(order),
            const SizedBox(height: 18),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(order),
            const SizedBox(width: 15),
            Expanded(child: _orderInfo(order)),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [_statusChip(order), _locationChip(order)],
        ),
        const SizedBox(height: 15),
        _actionButtons(order),
      ],
    );
  }

  Widget _productImage(OrderModel order) {
    final image = order.items.isEmpty ? '' : order.items.first.image;

    return Container(
      width: 95,
      height: 95,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: image.isEmpty
          ? const Icon(Icons.image_outlined, size: 40)
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
        const SizedBox(height: 10),
        Text(
          order.customerName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 5),
        Text(
          order.customerPhoneNumber,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 10),
        Text(
          "${order.items.length} Item(s)",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          "₦${order.totalAmount.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (order.createdAt != null)
          Text(
            DateFormat("dd MMM yyyy • hh:mm a").format(order.createdAt!),
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
      ],
    );
  }

  Widget _statusChip(OrderModel order) {
    Color color;

    switch (order.status.toLowerCase()) {
      case "delivered":
        color = Colors.green;
        break;

      case "cancelled":
        color = Colors.red;
        break;

      case "shipping":
        color = Colors.blue;
        break;

      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Text(
        order.status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _locationChip(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        order.currentLocation.isEmpty
            ? "Location Not Updated"
            : order.currentLocation,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _actionButtons(OrderModel order) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.visibility_outlined, color: Colors.black),
          onPressed: () {
            Get.to(() => OrderDetailsPage(order: order));
          },
          label: const Text(
            "View Details",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.edit_location_alt_outlined),
          onPressed: () {
            Get.to(() => UpdateOrderStatusPage(order: order));
          },
          label: const Text("Update Status"),
        ),
      ],
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _customerCard()),
                      const SizedBox(width: 20),
                      Expanded(flex: 3, child: _productsCard()),
                    ],
                  )
                : Column(
                    children: [
                      _customerCard(),
                      const SizedBox(height: 20),
                      _productsCard(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _customerCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _infoTile(Icons.person_outline, "Customer", order.customerName),
          _infoTile(Icons.phone_outlined, "Phone", order.customerPhoneNumber),
          _infoTile(
            Icons.location_on_outlined,
            "Address",
            order.customerDeliveryAddress,
          ),
          _infoTile(
            Icons.route_outlined,
            "Current Location",
            order.currentLocation.isEmpty
                ? "Not Updated"
                : order.currentLocation,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor().withOpacity(.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _statusColor().withOpacity(.4)),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: _statusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "₦${order.totalAmount.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _productsCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ordered Products",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...order.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
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
                        const SizedBox(height: 5),
                        Text("Quantity: ${item.quantity}"),
                      ],
                    ),
                  ),
                  Text(
                    "₦${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 35),
          _totalRow("Subtotal", "₦${order.subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          _totalRow("Delivery Fee", "₦${order.deliveryFee.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          _totalRow(
            "Total Amount",
            "₦${order.totalAmount.toStringAsFixed(2)}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String title, String value, {bool bold = false}) {
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

  Color _statusColor() {
    switch (order.status.toLowerCase()) {
      case 'delivered':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'shipping':
        return Colors.blue;

      default:
        return Colors.orange;
    }
  }
}

class UpdateOrderStatusPage extends StatefulWidget {
  final OrderModel order;

  const UpdateOrderStatusPage({super.key, required this.order});

  @override
  State<UpdateOrderStatusPage> createState() => _UpdateOrderStatusPageState();
}

class _UpdateOrderStatusPageState extends State<UpdateOrderStatusPage> {
  final ctrl = Get.find<ManageOrdersController>();

  late String selectedStatus;
  late String selectedLocation;

  final List<String> orderStatuses = [
    "Processing",
    "Shipping",
    "Delivered",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();

    final rawStatus = widget.order.status.trim();

    selectedStatus = orderStatuses.contains(rawStatus)
        ? rawStatus
        : "Processing";

    selectedLocation = widget.order.currentLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Update Order",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Information",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Text("Order #${widget.order.id.substring(0, 8)}"),
                  const SizedBox(height: 6),
                  Text(widget.order.customerName),

                  const SizedBox(height: 25),

                  /// =========================
                  /// STATUS DROPDOWN
                  /// =========================
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Order Status",
                      border: OutlineInputBorder(),
                    ),
                    items: orderStatuses
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// =========================
                  /// LOCATION DROPDOWN (FIXED)
                  /// =========================
                  DropdownButtonFormField<String>(
                    value: selectedLocation.isEmpty ? null : selectedLocation,
                    decoration: const InputDecoration(
                      labelText: "Current Location",
                      border: OutlineInputBorder(),
                    ),
                    items: ctrl.trackingLocations
                        .map(
                          (location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedLocation = value;
                      });
                    },
                  ),

                  const SizedBox(height: 35),

                  /// =========================
                  /// SAVE BUTTON
                  /// =========================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text("Save Changes"),
                      onPressed: () async {
                        await ctrl.updateOrder(
                          orderId: widget.order.id,
                          delivered:
                              selectedStatus.toLowerCase() == "delivered",
                          currentLocation: selectedLocation,
                          status: selectedStatus, // ✅ FIX ADDED
                        );

                        Get.back();

                        Get.snackbar("Success", "Order updated successfully");
                      },
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
}
