import 'package:get/get.dart';

class EcommerceLiveRoutes {
  static const home = '/home';
  static const products = '/products';
  static const productDetails = '/product-details';
  static const categories = '/categories';
  static const cart = '/cart';
  static const orders = '/orders';
  static const customers = '/customers';
  static const admin = '/admin';
  static const adminLogin = '/admin-login';
  static const checkout = '/checkout';
  static const manageProducts = '/manage-products';
  static const manageOrders = '/manage-orders';
  static const uploadProducts = '/upload-products';
  static const signup = '/signup';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  static var all;
}

class EcommerceLiveNavController extends GetxController {
  void goTo(String route) => Get.toNamed(route);
}
