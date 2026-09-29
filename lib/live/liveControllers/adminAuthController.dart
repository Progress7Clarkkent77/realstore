import 'package:realstore/live/pages/adminDashboard.dart';

import 'package:get/get.dart';
import 'package:realstore/live/userAuth/authController.dart';

class AdminAuthController extends GetxController {
  final AuthController authCtrl = Get.find<AuthController>();

  final RxBool isLoading = false.obs;

  Future<void> loginAdmin({
    required String email,
    required String password,
    required String organizationId,
    required String slug,
  }) async {
    try {
      isLoading.value = true;

      if (email.trim().isEmpty || password.trim().isEmpty) {
        Get.snackbar("Missing Fields", "Email and password are required");
        return;
      }

      final user = authCtrl.currentUser;

      if (user == null) {
        Get.snackbar("Authentication", "Please login first");
        return;
      }

      final valid = await authCtrl.verifyPassword(
        email.trim(),
        password.trim(),
      );

      if (!valid) {
        Get.snackbar("Access Denied", "Invalid password");
        return;
      }

      final hasAccess = await orgCtrl.hasAdminAccess(
        organizationId: organizationId,
        userId: user.uid,
      );

      if (!hasAccess) {
        Get.snackbar("Access Denied", "Admin permission required");
        return;
      }

      if (!hasAccess) {
        Get.snackbar("Access Denied", "Admin permission required");
        return;
      }

      await domainCtrl.resolveOrganizationById(organizationId);

      await domainCtrl.refreshAccessState();

      if (domainCtrl.isLocked.value) {
        Get.snackbar("Subscription Expired", "Renew subscription to continue");
        return;
      }

      final org = await orgCtrl.getOrganizationById(organizationId);

      if (org == null) {
        Get.snackbar("Organization", "Organization not found");
        return;
      }

      Get.off(
        () => EcommerceAdminDashboardPage(
          organizationId: organizationId,
          slug: slug,
        ),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
