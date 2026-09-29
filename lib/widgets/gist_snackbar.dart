import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 🔹 Shared premium snackbar for every HotGist controller.
/// Always a white card regardless of theme, with a black/white
/// premium look — used for the "verified users only" notice and
/// any other feedback the gist controllers need to surface.
void showPremiumSnackbar({
  required String title,
  required String message,
  IconData icon = Icons.info_outline_rounded,
}) {
  if (Get.isSnackbarOpen) {
    Get.closeCurrentSnackbar();
  }

  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    borderRadius: 18,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.20),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
    titleText: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
    messageText: Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12.5, color: Colors.black87),
      ),
    ),
    duration: const Duration(seconds: 3),
  );
}
