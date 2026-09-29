import 'package:realstore/live/models/productModel.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}
