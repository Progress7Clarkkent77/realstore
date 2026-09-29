import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final String category;
  final double price;
  final double deliveryFee;
  final int stock;
  final bool isActive;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.category,
    required this.price,
    required this.deliveryFee,
    required this.stock,
    required this.isActive,
    this.createdAt,
  });

  factory ProductModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      images: List<String>.from(
        data['images'] ?? [],
      ),
      price: (data['price'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'images': images,
      'price': price,
      'deliveryFee': deliveryFee,
      'stock': stock,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
