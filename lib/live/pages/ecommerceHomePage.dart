import 'dart:convert';

import 'package:realstore/live/liveControllers/blackFridayController.dart';
import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/liveControllers/ecommerceStoreController.dart';
import 'package:realstore/live/liveControllers/status_controller.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';
import 'package:realstore/live/models/productModel.dart';
import 'package:realstore/live/pages/adminDashboard.dart';
import 'package:realstore/live/pages/flyToCart.dart';
import 'package:realstore/live/pages/profile.dart'; // ← adjust if ProfileScreen lives elsewhere
import 'package:realstore/live/userAuth/authController.dart';
import 'package:realstore/live/userAuth/authpages.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ecommerce_routes.dart';

/// Now a StatefulWidget so the search TextEditingController is owned by
/// this page's State and disposed with it. This fixes the
/// "TextEditingController was used after being disposed" error, which
/// happened because the controller lived in the store controller (which
/// GetX can dispose/recreate) while this page kept using it.
class EcommerceHomePage extends StatefulWidget {
  const EcommerceHomePage({super.key});

  @override
  State<EcommerceHomePage> createState() => _EcommerceHomePageState();
}

class _EcommerceHomePageState extends State<EcommerceHomePage> {
  late final ThemeController themeCtrl;

  /// Current light/dark palette (reading it inside an Obx makes the widget
  /// rebuild when the theme is switched from the profile page).
  _HP get p => _HP(themeCtrl.isDarkMode.value);

  late final EcommerceLiveNavController nav;
  late final AuthController authCtrl;
  late final EcommerceStoreController storeCtrl;
  late final EcommerceCartController cartCtrl;
  late final StatusController statusCtrl;

  // Support contact used by the Support sheet — change to your real details.
  static const _supportEmail = 'contact@afiasplendid.co.site';

  static const Color _bfGold = Color(0xFFF5B301);
  static const Color _bfRed = Color(0xFFE5484D);

  late final TextEditingController _searchCtrl;

  /// Target of the fly-to-cart animation (the cart icon in the app bar).
  final GlobalKey<CartFlyTargetState> _cartFlyKey =
      GlobalKey<CartFlyTargetState>();

  @override
  void initState() {
    super.initState();
    themeCtrl = Get.find<ThemeController>();
    nav = Get.put(EcommerceLiveNavController());
    authCtrl = Get.find<AuthController>();
    storeCtrl = Get.find<EcommerceStoreController>();
    cartCtrl = Get.find<EcommerceCartController>();
    statusCtrl = Get.find<StatusController>();
    statusCtrl.startProductLikesListener();

    // Listens to the Black Friday switch for this customer (permanent).
    BlackFridayController.ensure();

    // Local controller, seeded with any existing search text.
    _searchCtrl = TextEditingController(text: storeCtrl.searchText.value);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (width >= 1400) {
      crossAxisCount = 6;
    } else if (width >= 1100) {
      crossAxisCount = 5;
    } else if (width >= 800) {
      crossAxisCount = 4;
    } else if (width >= 600) {
      crossAxisCount = 3;
    }

    return Obx(() {
      final p = this.p;

      return Scaffold(
        backgroundColor: p.bg,
        appBar: _appBar(),
        body: Stack(
          children: [
            Column(
              children: [
                // STATIC: search + categories stay pinned while products scroll
                _searchAndCategories(),

                // SCROLLING: only the product cards move
                Expanded(
                  child: Obx(() {
                    final products = storeCtrl.filteredProducts;

                    // Read here so the whole grid rebuilds when the admin
                    // switches Black Friday on/off.
                    final blackFriday = BlackFridayState.active.value;
                    final maxOff = blackFriday
                        ? _maxDiscount(storeCtrl.products)
                        : 0.0;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        if (blackFriday && maxOff > 0)
                          SliverToBoxAdapter(child: _blackFridayBanner(maxOff)),
                        if (products.isEmpty)
                          SliverToBoxAdapter(child: _emptyState())
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (_, index) => _productCard(products[index]),
                                childCount: products.length,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: .72,
                                  ),
                            ),
                          ),
                        SliverToBoxAdapter(child: _poweredBy()),
                      ],
                    );
                  }),
                ),
              ],
            ),

            // FLOATING BOTTOM BAR (hidden while the keyboard is open)
            _floatingBottomBar(),
          ],
        ),
      );
    });
  }

  // ───────────────────────── APP BAR ─────────────────────────

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: p.border,
      systemOverlayStyle: p.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      toolbarHeight: 68,
      titleSpacing: 16,
      title: Row(
        children: [
          // Square logo with rounded corners
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                'assets/images/RealStore Logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.storefront, color: p.text),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "RealStore",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontSize: 18,
                    color: p.text,
                  ),
                ),
                Text(
                  "Shop Real. Shop Direct.",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: p.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          if (!authCtrl.isAuthenticated) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () =>
                    Get.to(() => EarnLogin())
                        ?.then((_) => statusCtrl.startProductLikesListener()),
                icon: const Icon(Icons.login, size: 18),
                label: const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _appBarAction(
                icon: Icons.receipt_long_outlined,
                label: "Orders",
                onTap: () => nav.goTo(EcommerceLiveRoutes.orders),
              ),
              _appBarAction(
                icon: Icons.shopping_cart_outlined,
                label: "Cart",
                badge: cartCtrl.cartCount,
                flyKey: _cartFlyKey,
                onTap: () => nav.goTo(EcommerceLiveRoutes.cart),
              ),
            ],
          );
        }),
        Obx(() {
          if (!authCtrl.isAdmin.value) return const SizedBox.shrink();

          return _appBarAction(
            icon: Icons.admin_panel_settings_outlined,
            label: "Admin",
            onTap: () => Get.to(() => EcommerceAdminDashboardPage()),
          );
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Icon with a small text label underneath so users instantly know
  /// what each button does.
  Widget _appBarAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
    GlobalKey<CartFlyTargetState>? flyKey,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              flyKey == null
                  ? _iconWithBadge(icon, badge)
                  : CartFlyTarget(
                      key: flyKey,
                      child: _iconWithBadge(icon, badge),
                    ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconWithBadge(IconData icon, int badge) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24, color: p.text),
        if (badge > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.surface, width: 1.5),
              ),
              child: Text(
                badge > 99 ? "99+" : badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Plays the Temu-style "jump into the cart" animation for [product].
  void _flyToCart(BuildContext from, ProductModel product) {
    Uint8List? bytes;
    if (product.images.isNotEmpty) {
      try {
        bytes = base64Decode(product.images.first);
      } catch (_) {}
    }

    FlyToCart.launch(
      from: from,
      to: _cartFlyKey,
      trailColor: Colors.red,
      flyer: FlyToCart.thumbnail(
        bytes: bytes,
        background: p.imageBg,
        ring: p.surface,
        iconColor: p.text,
      ),
    );
  }

  // ───────────────────────── SEARCH + CATEGORIES (merged, static) ─────────────────────────

  Widget _searchAndCategories() {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: p.shadowSoft,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              height: 46,
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  storeCtrl.searchText.value = value;
                  storeCtrl.filterProducts();
                  setState(() {}); // refresh clear button
                },
                style: TextStyle(fontSize: 14, color: p.text),
                cursorColor: p.accent,
                decoration: InputDecoration(
                  hintText: "Search by name, category or price",
                  hintStyle: TextStyle(color: p.hint, fontSize: 13.5),
                  prefixIcon: Icon(Icons.search, color: p.muted, size: 22),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close, size: 18, color: p.muted),
                          onPressed: () {
                            _searchCtrl.clear();
                            storeCtrl.searchText.value = '';
                            storeCtrl.filterProducts();
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: p.tile,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: p.accent, width: 1.2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Categories (horizontal chips, Temu-style)
          SizedBox(
            height: 34,
            child: Obx(() {
              final cats = storeCtrl.categories;
              final selected = storeCtrl.selectedCategory.value;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 16),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final category = cats[i];
                  final isSelected = category == selected;

                  return GestureDetector(
                    onTap: () {
                      storeCtrl.selectedCategory.value = category;
                      storeCtrl.filterProducts();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? p.accent : p.tile,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? p.onAccent : p.textSoft,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── FLOATING BOTTOM BAR ─────────────────────────

  Widget _floatingBottomBar() {
    final mq = MediaQuery.of(context);
    if (mq.viewInsets.bottom > 0) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 16 + mq.padding.bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: p.bar,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.barBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _barItem(Icons.policy_outlined, "Policy", _openPrivacyPolicy),
                  _barItem(Icons.info_outline_rounded, "About Us", _showAbout),
                  _barItem(
                    Icons.support_agent_rounded,
                    "Support",
                    _showSupport,
                  ),
                  _barItem(
                    Icons.person_outline_rounded,
                    "Profile",
                    _openProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _barItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProfile() {
    final uid = authCtrl.currentUser?.uid;
    if (uid == null) {
      Get.snackbar(
        'Login Required',
        'Please login first',
        backgroundColor: p.snackBg,
        colorText: p.snackText,
      );
      return;
    }
    Get.to(() => const ProfileScreen());
  }

  void _showSheet({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.handle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(icon, color: p.text),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: p.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...children,
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheetText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(fontSize: 13, height: 1.55, color: p.textSoft),
    ),
  );

  static const _privacyPolicyUrl =
      'https://docs.google.com/document/d/e/2PACX-1vRzYLA43UaBCW2Y-E96jcf7ue821JxfvyH8iH4HEumSQE9NkgSI8aBt23B2wgjZdymzZJxWDLzYzVPN/pub';

  /// Opens the Privacy Policy in the browser.
  Future<void> _openPrivacyPolicy() async {
    var opened = false;

    try {
      opened = await launchUrl(
        Uri.parse(_privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      Get.snackbar(
        'Privacy Policy',
        'Could not open the link. Please try again.',
        backgroundColor: p.snackBg,
        colorText: p.snackText,
      );
    }
  }

  void _showAbout() => _showSheet(
    title: "About Us",
    icon: Icons.info_outline_rounded,
    children: [
      _sheetText(
        "RealStore – Shop Real. Shop Direct. We connect you to quality products at honest prices, delivered with care.",
      ),
      Text(
        "Powered by AFIA SPLENDID LTD",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 12,
          color: p.muted,
        ),
      ),
    ],
  );

  void _showSupport() => _showSheet(
    title: "Support",
    icon: Icons.support_agent_rounded,
    children: [
      _sheetText(
        "Need help with an order or your account? Reach out and we'll get back to you.",
      ),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: p.accent,
            foregroundColor: p.onAccent,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () =>
              launchUrl(Uri(scheme: 'mailto', path: _supportEmail)),
          icon: const Icon(Icons.email_outlined, size: 18),
          label: Text(_supportEmail),
        ),
      ),
    ],
  );

  // ───────────────────────── POWERED BY ─────────────────────────

  Widget _poweredBy() {
    return Padding(
      // extra bottom space so the floating bar never covers it
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
      child: Center(
        child: Text(
          "Powered by AFIA SPLENDID LTD",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 11.5,
            color: p.hint,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: p.faint),
          const SizedBox(height: 12),
          Text(
            "No products found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Try a different search or category",
            style: TextStyle(color: p.muted),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── PRODUCT CARD ─────────────────────────

  String _formatPrice(num price) {
    final fixed = price.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return "₦$whole.${parts[1]}";
  }

  Widget _likeButton(ProductModel product) {
    final id = product.id.toString();

    return Obx(() {
      final liked = statusCtrl.likedProductIds.contains(id);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // if (!authCtrl.isAuthenticated) {
          //   Get.snackbar(
          //     "Login required",
          //     "Please log in to like products.",
          //     snackPosition: SnackPosition.BOTTOM,
          //     margin: const EdgeInsets.all(12),
          //   );
          //   Get.to(() => EarnLogin())
          //       ?.then((_) => statusCtrl.startProductLikesListener());
          //   return;
          // }
          final uid = authCtrl.currentUser?.uid;
          if (uid == null) {
            Get.snackbar(
              'Login Required',
              'Please login first',
              backgroundColor: p.snackBg,
              colorText: p.snackText,
            );
            return;
          }
          statusCtrl.toggleProductLike(id);
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: p.likeBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(liked),
              size: 18,
              color: liked ? const Color(0xFFE53935) : p.text,
            ),
          ),
        ),
      );
    });
  }

  // ───────────────────────── BLACK FRIDAY ─────────────────────────

  double _maxDiscount(Iterable<ProductModel> products) => products.fold(
    0.0,
    (max, p) => p.blackFridayPercent > max ? p.blackFridayPercent : max,
  );

  String _pct(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  Widget _bfBadge(ProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _bfGold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-${_pct(product.blackFridayPercent)}%',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _blackFridayBanner(double maxOff) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2005), Color(0xFF0B0B0C)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _bfGold.withOpacity(0.65)),
          boxShadow: [
            BoxShadow(
              color: _bfGold.withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _bfGold,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.black,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BLACK FRIDAY IS LIVE',
                    style: TextStyle(
                      color: _bfGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Prices shown are already reduced',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _bfGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'UP TO ${_pct(maxOff)}% OFF',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: p.isDark ? Border.all(color: p.border) : null,
        boxShadow: [
          BoxShadow(
            color: p.shadowCard,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final uid = authCtrl.currentUser?.uid;

            if (uid == null) {
              Get.snackbar(
                'Login Required',
                'Please login first',
                //snackPosition: SnackPosition.BOTTOM,
                backgroundColor: p.snackBg,
                colorText: p.snackText,
              );
              return;
            }

            storeCtrl.selectProduct(product);
            nav.goTo(EcommerceLiveRoutes.productDetails);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE — BoxFit.contain so the whole product is always visible
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: p.imageBg,
                          child: product.images.isEmpty
                              ? Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: p.faint,
                                  ),
                                )
                              : Image.memory(
                                  base64Decode(product.images.first),
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: p.faint,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _likeButton(product),
                        ),
                        if (product.isOnBlackFriday)
                          Positioned(top: 6, left: 6, child: _bfBadge(product)),
                      ],
                    ),
                  ),
                ),
              ),

              // DETAILS — smaller text, name + price share one column
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: p.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatPrice(product.price),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: product.isOnBlackFriday
                                        ? _bfRed
                                        : p.text,
                                  ),
                                ),
                                if (product.isOnBlackFriday) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatPrice(product.regularPrice),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: p.muted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: "Add to cart",
                      child: Material(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(11),
                        child: Builder(
                          builder: (btnCtx) => InkWell(
                            borderRadius: BorderRadius.circular(11),
                            onTap: () => cartCtrl.addToCart(
                              product,
                              onAdded: () => _flyToCart(btnCtx, product),
                            ),
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                                color: p.onAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==================================================
// PALETTE  (matches the profile page palette)
//==================================================

class _HP {
  const _HP(this.isDark);

  final bool isDark;

  Color get bg => isDark ? const Color(0xFF0E0E10) : const Color(0xFFF7F7F8);
  Color get surface => isDark ? const Color(0xFF1A1A1D) : Colors.white;
  Color get border =>
      isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE9E9EC);
  Color get tile => isDark ? const Color(0xFF26262A) : const Color(0xFFF3F3F5);
  Color get imageBg =>
      isDark ? const Color(0xFF26262A) : const Color(0xFFF4F4F6);
  Color get text => isDark ? Colors.white : const Color(0xFF111111);
  Color get textSoft => isDark ? const Color(0xFFD4D4DA) : Colors.black87;
  Color get muted => isDark ? const Color(0xFF9A9AA2) : Colors.black54;
  Color get hint => isDark ? const Color(0xFF6E6E76) : Colors.black45;
  Color get faint => isDark ? const Color(0xFF4A4A52) : Colors.black26;
  Color get handle => isDark ? const Color(0xFF3A3A40) : Colors.black12;

  // buttons, selected chips, add-to-cart
  Color get accent => isDark ? Colors.white : const Color(0xFF111111);
  Color get onAccent => isDark ? const Color(0xFF0B0B0C) : Colors.white;

  // floating bottom bar
  Color get bar => isDark ? const Color(0xFF232327) : const Color(0xFF111111);
  Color get barBorder => isDark ? const Color(0xFF3A3A40) : Colors.white12;

  // like button bubble on product images
  Color get likeBg =>
      isDark ? const Color(0xEB2A2A2E) : Colors.white.withOpacity(0.92);

  // snackbars
  Color get snackBg => isDark ? const Color(0xFF2A2A2E) : Colors.black;
  Color get snackText => Colors.white;

  Color get shadowSoft =>
      isDark ? const Color(0x66000000) : const Color(0x0D000000);
  Color get shadowCard =>
      isDark ? const Color(0x66000000) : const Color(0x12000000);
}
