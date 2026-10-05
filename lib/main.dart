import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realstore/live/liveControllers/balance_controller.dart';
import 'package:realstore/live/liveControllers/referral_controller.dart';
import 'package:realstore/live/liveControllers/status_controller.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';
import 'package:realstore/live/liveControllers/verified_controller.dart';
import 'package:realstore/live/pages/cartPage.dart';
import 'package:realstore/live/pages/checkOutPage.dart';
import 'package:realstore/live/pages/manageProductPage.dart';
import 'package:realstore/live/pages/orderPage.dart';
import 'package:realstore/live/pages/productDetailsPage.dart';
import 'package:realstore/live/pages/uploadProductPage.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:realstore/live/liveControllers/adminAuthController.dart';
import 'package:realstore/live/liveControllers/adminDashboardController.dart';
import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/liveControllers/ecommerceStoreController.dart';
import 'package:realstore/live/liveControllers/manageOrdersController.dart';
import 'package:realstore/live/liveControllers/manageProductController.dart';
import 'package:realstore/live/liveControllers/orderController.dart';
import 'package:realstore/live/liveControllers/reward_controller.dart';
import 'package:realstore/live/liveControllers/startup_controller.dart';
import 'package:realstore/live/liveControllers/uploadProductController.dart';
import 'package:realstore/live/pages/adminDashboard.dart';
import 'package:realstore/live/pages/ecommerceHomePage.dart';
import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:realstore/live/pages/manageOrdersPage.dart';
import 'package:realstore/live/pages/onboarding.dart';
import 'package:realstore/live/pages/route_guards.dart';
import 'package:realstore/live/pages/term_of_use.dart';
import 'package:realstore/live/userAuth/account_controller.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:realstore/live/userAuth/authpages.dart';
import 'package:realstore/live/userAuth/forgotpassword.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean URLs on web (no #).
  setPathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Wait for Firebase to restore the saved session so route guards see the
  // real sign-in state on a page refresh (otherwise a signed-in admin
  // refreshing /admin would be bounced to the login page).
  await FirebaseAuth.instance.authStateChanges().first;

  // Local storage is tiny and some controllers (e.g. theme) read it
  // immediately after login, so initialise it before the UI starts.
  await GetStorage.init();

  runApp(const MyApp());
}

/// Lazy controller registration. `fenix: true` recreates a controller if it
/// was disposed and is requested again.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Auth & user
    Get.put(AuthController(), permanent: true);
    Get.put(ThemeController(), permanent: true);
    Get.put(StartupController(), permanent: true);

    Get.lazyPut(() => AccountController(), fenix: true);
    //Get.lazyPut(() => StartupController(), fenix: true);
    Get.lazyPut(() => RewardController(), fenix: true);
    //Get.lazyPut(() => ThemeController(), fenix: true);
    Get.lazyPut(() => AvailableBalanceController(), fenix: true);
    Get.lazyPut(() => ReferController(), fenix: true);
    Get.lazyPut(() => StatusController(), fenix: true);
    Get.lazyPut(() => VerifiedController(), fenix: true);

    // Storefront
    Get.lazyPut(() => EcommerceStoreController(), fenix: true);
    Get.lazyPut(() => EcommerceCartController(), fenix: true);
    Get.lazyPut(() => OrderController(), fenix: true);

    // Admin
    Get.lazyPut(() => AdminAuthController(), fenix: true);
    Get.lazyPut(() => EcommerceAdminDashboardController(), fenix: true);
    Get.lazyPut(() => ManageOrdersController(), fenix: true);
    Get.lazyPut(() => ManageProductsController(), fenix: true);
    Get.lazyPut(() => UploadProductController(), fenix: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final List<GetPage> _pages = [
    //------------------------------------------------
    // PUBLIC
    //------------------------------------------------
    GetPage(name: EcommerceLiveRoutes.root, page: () => const Onboarding()),
    GetPage(
      name: EcommerceLiveRoutes.onboarding,
      page: () => const Onboarding(),
    ),
    GetPage(name: EcommerceLiveRoutes.home, page: () => EcommerceHomePage()),
    GetPage(name: EcommerceLiveRoutes.login, page: () => const EarnLogin()),
    GetPage(name: EcommerceLiveRoutes.signup, page: () => const EarnSignUp()),
    GetPage(
      name: EcommerceLiveRoutes.forgotPassword,
      page: () => ForgotPassword(),
    ),
    GetPage(
      name: EcommerceLiveRoutes.changePassword,
      page: () => ChangePassword(),
      middlewares: [AuthGuard()],
    ),
    GetPage(name: EcommerceLiveRoutes.terms, page: () => TermsOfUseScreen()),

    //------------------------------------------------
    // CUSTOMER (signed in)
    // Replace the class names with your real pages, then uncomment.
    //------------------------------------------------
    GetPage(
      name: EcommerceLiveRoutes.productDetails,
      page: () => ProductDetailsPage(),
    ),
    GetPage(
      name: EcommerceLiveRoutes.cart,
      page: () => CartPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: EcommerceLiveRoutes.checkout,
      page: () => CheckoutPage(),
      middlewares: [AuthGuard()],
    ),

    GetPage(
      name: EcommerceLiveRoutes.orders,
      page: () => OrdersPage(),
      middlewares: [AuthGuard()],
    ),

    //------------------------------------------------
    // ADMIN ONLY
    //------------------------------------------------
    GetPage(
      name: EcommerceLiveRoutes.admin,
      page: () => EcommerceAdminDashboardPage(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: EcommerceLiveRoutes.manageOrders,
      page: () => ManageOrdersPage(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: EcommerceLiveRoutes.manageProducts,
      page: () => ManageProductsPage(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: EcommerceLiveRoutes.uploadProducts,
      page: () => UploadProductsPage(),
      middlewares: [AdminGuard()],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RealStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      initialRoute: EcommerceLiveRoutes.root,
      getPages: _pages,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Page not found', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Get.offAllNamed(EcommerceLiveRoutes.home),
                  child: const Text(
                    'Back to store',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
