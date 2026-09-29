import 'package:realstore/live/models/orderItemModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;

  final String organizationId;
  final String customerUid;

  final String customerName;
  final String customerPhoneNumber;
  final String customerDeliveryAddress;

  final double subtotal;
  final double deliveryFee;
  final double totalAmount;

  final bool delivered;

  final String currentLocation;

  final String status;

  final List<OrderItemModel> items;

  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.organizationId,
    required this.customerUid,
    required this.customerName,
    required this.customerPhoneNumber,
    required this.customerDeliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.delivered,
    required this.currentLocation,
    required this.status,
    required this.items,
    this.createdAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      organizationId: data['organizationId'] ?? '',
      customerUid: data['customerUid'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhoneNumber: data['customerPhoneNumber'] ?? '',
      customerDeliveryAddress: data['customerDeliveryAddress'] ?? '',
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      delivered: data['delivered'] ?? false,
      currentLocation: data['currentLocation'] ?? '',
      status: data['status'] ?? 'Pending',
      items: (data['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organizationId': organizationId,
      'customerUid': customerUid,
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'customerDeliveryAddress': customerDeliveryAddress,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'delivered': delivered,
      'currentLocation': currentLocation,
      'status': status,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
