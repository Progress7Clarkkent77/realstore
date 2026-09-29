import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:realstore/live/liveControllers/adminDashboardController.dart';
import 'package:realstore/platformControllers/domainController.dart';
import 'package:realstore/platformControllers/themeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EcommerceAdminDashboardPage extends StatelessWidget {
  final String organizationId;
  final String slug;

  EcommerceAdminDashboardPage({
    super.key,
    required this.organizationId,
    required this.slug,
  });

  final dashboardCtrl = Get.put(
    EcommerceAdminDashboardController(),
    permanent: true,
  );

  final domainCtrl = Get.find<DomainController>();

  final themeCtrl = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;

    if (width >= 1400) {
      crossAxisCount = 5;
    } else if (width >= 1000) {
      crossAxisCount = 4;
    } else if (width >= 700) {
      crossAxisCount = 3;
    }

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      if (domainCtrl.isLocked.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: const Text(
                "This organization's subscription has expired go and renew it, pay for maintenance.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                dashboardCtrl.startRealtimeListeners();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: dashboardCtrl.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _organizationHeader(isDark),
                    const SizedBox(height: 25),
                    _statsGrid(crossAxisCount, isDark),
                    const SizedBox(height: 35),
                    const Text(
                      "Management",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _adminGrid(crossAxisCount, isDark),
                  ],
                ),
              ),
      );
    });
  }

  Widget _organizationHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            backgroundImage: domainCtrl.organizationLogo.value.isNotEmpty
                ? NetworkImage(domainCtrl.organizationLogo.value)
                : null,
            child: domainCtrl.organizationLogo.value.isEmpty
                ? const Icon(Icons.store, size: 35)
                : null,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domainCtrl.organizationName.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(domainCtrl.organizationType.value),
                // const SizedBox(height: 4),
                // Text(
                //   domainCtrl.fullDomain.value,
                //   style: const TextStyle(
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(int crossAxisCount, bool isDark) {
    final stats = [
      {
        "title": "Products",
        "value": dashboardCtrl.productCount.value.toString(),
      },
      {"title": "Orders", "value": dashboardCtrl.orderCount.value.toString()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 2,
      ),
      itemBuilder: (_, index) {
        final item = stats[index];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item["title"]!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item["value"]!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _adminGrid(int crossAxisCount, bool isDark) {
    final items = [
      {
        "title": "Manage Products",
        "icon": Icons.shopping_bag_outlined,
        "route": EcommerceLiveRoutes.manageProducts,
      },
      {
        "title": "Manage Orders",
        "icon": Icons.receipt_long_outlined,
        "route": EcommerceLiveRoutes.manageOrders,
      },
      {
        "title": "Upload Products",
        "icon": Icons.upload_outlined,
        "route": EcommerceLiveRoutes.uploadProducts,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, index) {
        final item = items[index];

        return InkWell(
          onTap: () {
            Get.toNamed(
              item["route"] as String,
              arguments: {
                "organizationId": domainCtrl.organizationId.value,
                "slug": domainCtrl.currentSlug.value,
              },
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.white : Colors.black),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item["icon"] as IconData, size: 34),
                const SizedBox(height: 12),
                Text(
                  item["title"] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
