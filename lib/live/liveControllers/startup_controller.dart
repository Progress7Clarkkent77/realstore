import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';

class StartupController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ThemeController themeCtrl = Get.put(ThemeController());

  final RxBool isChecking = true.obs;

  /// ✅ Decide where app should go
  Future<void> initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      final user = _auth.currentUser;
      final themeController = Get.find<ThemeController>();

      await themeController.loadTheme();

      /// ✅ User already logged in
      if (user != null) {
        Get.offAllNamed('/home');
      } else {
        /// ❌ Not logged in
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.offAllNamed('/home');
    } finally {
      isChecking.value = false;
    }
  }
}
