import 'package:realstore/live/models/orderModel.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManageOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DomainController domainCtrl = Get.find<DomainController>();

  final RxBool isLoading = false.obs;

  final RxList<OrderModel> orders = <OrderModel>[].obs;

  final trackingLocations = [
    'Order Received',
    'Processing',
    'Packed',
    'Dispatched',
    'In Transit',
    'Arrived Local Hub',
    'Out For Delivery',
    'Delivered',
  ];

  @override
  void onInit() {
    super.onInit();

    listenOrders();
  }

  void listenOrders() {
    final orgId = domainCtrl.organizationId.value;

    if (orgId.isEmpty) return;

    _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          orders.value = snapshot.docs
              .map((e) => OrderModel.fromMap(e.id, e.data()))
              .toList();
        });
  }

  Future<void> updateOrder({
    required String orderId,
    required bool delivered,
    required String currentLocation,
    required String status,
  }) async {
    final orgId = domainCtrl.organizationId.value;

    await _firestore
        .collection('organizations')
        .doc(orgId)
        .collection('orders')
        .doc(orderId)
        .update({
          'delivered': delivered,
          'status': status, // ✅ ADD THIS
          'currentLocation': currentLocation,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    Get.snackbar('Success', 'Order updated');
  }
}
