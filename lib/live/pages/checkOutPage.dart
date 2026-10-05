import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:realstore/live/liveControllers/ecommerceCartController.dart';
import 'package:realstore/live/liveControllers/orderController.dart';
import 'package:realstore/live/liveControllers/theme_controller.dart';
import 'package:realstore/live/models/productModel.dart';
import 'package:realstore/live/pages/deliveryZoneSelector.dart';
import 'package:realstore/live/pages/ecommerce_routes.dart';
import 'package:realstore/live/pages/storeUi.dart';
import 'package:realstore/live/userAuth/authController.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// RealStore's WhatsApp number (09030323601) in international format.
  static const String _whatsappNumber = '2349030323601';

  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  final AuthController authCtrl = Get.find();
  final EcommerceCartController cartCtrl = Get.find();
  final OrderController orderCtrl = Get.find();

  // ThemeController is created at login; fall back safely on cold start.
  final ThemeController themeCtrl = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  /// "Save these details for next time" toggle.
  final RxBool remember = true.obs;

  final RxBool loadingSaved = true.obs;
  final RxBool hasSaved = false.obs;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  //==================================================
  // SAVED DETAILS
  //==================================================

  Future<void> _loadSaved() async {
    final saved = await orderCtrl.loadSavedShipping();

    if (!mounted) return;

    if (saved != null) {
      // Never overwrite something the user has already started typing.
      if (phoneCtrl.text.trim().isEmpty) phoneCtrl.text = saved['phone'] ?? '';
      if (addressCtrl.text.trim().isEmpty) {
        addressCtrl.text = saved['address'] ?? '';
      }
      hasSaved.value = true;
    }

    loadingSaved.value = false;
  }

  Future<void> _clearSaved() async {
    await orderCtrl.clearSavedShipping();

    phoneCtrl.clear();
    addressCtrl.clear();
    hasSaved.value = false;

    Get.snackbar(
      'Removed',
      'Your saved delivery details were deleted.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
    );
  }

  //==================================================
  // VALIDATION & SUBMIT
  //==================================================

  String? _validatePhone(String? value) {
    final raw = (value ?? '').replaceAll(RegExp(r'[\s\-()]'), '');

    if (raw.isEmpty) return 'Enter your phone number';

    // 0803..., +234803..., 234803...
    if (!RegExp(r'^(\+?234|0)[789][01]\d{8}$').hasMatch(raw)) {
      return 'Enter a valid Nigerian phone number';
    }

    return null;
  }

  String? _validateAddress(String? value) {
    if ((value ?? '').trim().length < 10) {
      return 'Enter a complete delivery address';
    }

    return null;
  }

  Future<void> _submit() async {
    if (orderCtrl.isPlacingOrder.value) return;

    if (cartCtrl.cartItems.isEmpty) {
      Get.snackbar('Cart empty', 'Add items to your cart first');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    await orderCtrl.placeOrder(
      phone: phoneCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      rememberShipping: remember.value,
    );
  }

  //==================================================
  // CONTACT REALSTORE (WHATSAPP)
  //==================================================

  String _buildWhatsAppMessage() {
    final items = cartCtrl.cartItems.toList();
    final b = StringBuffer()
      ..writeln('Hello RealStore, I would like to place an order:')
      ..writeln();

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      b
        ..writeln(
          '${i + 1}. ${item.product.name}'
          '${item.hasColor ? ' (${item.colorName})' : ''}',
        )
        ..writeln(
          '   ${item.quantity} x ${formatNaira(item.product.price)} '
          '= ${formatNaira(item.total)}',
        );
    }

    final fee = cartCtrl.deliveryFee;
    final address = addressCtrl.text.trim();

    b
      ..writeln()
      ..writeln('Subtotal: ${formatNaira(cartCtrl.subtotal)}')
      ..writeln(
        'Delivery (${cartCtrl.deliveryZone.value.label}): '
        '${fee > 0 ? formatNaira(fee) : 'Free'}',
      )
      ..writeln('*Total: ${formatNaira(cartCtrl.grandTotal)}*')
      ..writeln()
      ..writeln('*Delivery address:*')
      ..writeln(address)
      ..writeln()
      ..write('Please confirm availability and how I can pay. Thank you!');

    return b.toString();
  }

  Future<void> _contactRealstore() async {
    if (orderCtrl.isPlacingOrder.value) return;

    if (cartCtrl.cartItems.isEmpty) {
      Get.snackbar('Cart empty', 'Add items to your cart first');
      return;
    }

    // The store needs to know where to deliver, so the address is required.
    if (addressCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Delivery address needed',
        'Please enter your delivery address first, then tap Contact Realstore.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
      );
      return;
    }

    final message = _buildWhatsAppMessage();
    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}',
    );

    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      // Fallback: copy the order so it can be pasted into any chat.
      await Clipboard.setData(ClipboardData(text: message));
      Get.snackbar(
        'Could not open WhatsApp',
        'Your order details were copied. Send them to 09030323601.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
      );
    }
  }

  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Obx(() {
      final p = StorePalette(themeCtrl.isDarkMode.value);
      final isEmpty = cartCtrl.cartItems.isEmpty;
      final placing = orderCtrl.isPlacingOrder.value;

      // While an order is processing the user cannot leave the page.
      return PopScope(
        canPop: !placing,
        child: Stack(
          children: [
            _scaffold(p, isEmpty, isDesktop),
            if (placing) _processingOverlay(p),
          ],
        ),
      );
    });
  }

  Widget _processingOverlay(StorePalette p) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: const Color(0x66000000),
            alignment: Alignment.center,
            child: Material(
              color: p.surface,
              elevation: 8,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => Text(
                        orderCtrl.processingMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please do not close this page',
                      style: TextStyle(color: p.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _scaffold(StorePalette p, bool isEmpty, bool isDesktop) {
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: p.text),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout',
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Contact RealStore to place your order',
              style: TextStyle(color: p.muted, fontSize: 10),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (isEmpty || isDesktop) ? null : _bottomBar(p),
      body: isEmpty
          ? _emptyState(p)
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: _deliveryCard(p)),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: _summaryCard(p, withButton: true),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _deliveryCard(p),
                            const SizedBox(height: 18),
                            _summaryCard(p, withButton: false),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  //==================================================
  // EMPTY
  //==================================================

  Widget _emptyState(StorePalette p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: p.tile,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Nothing to check out',
              style: TextStyle(
                color: p.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your cart is empty.',
              style: TextStyle(color: p.muted, fontSize: 14),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(EcommerceLiveRoutes.home),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(190, 52),
                backgroundColor: p.accent,
                foregroundColor: p.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Back to store'),
            ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // DELIVERY FORM
  //==================================================

  String _feeText(double fee) => fee > 0 ? formatNaira(fee) : 'Free';

  Widget _deliveryCard(StorePalette p) {
    final email = authCtrl.currentUser?.email ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.border),
        boxShadow: p.shadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 21,
                    color: p.onAccent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Delivery details',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Text(
            //   'Where are we delivering to?',
            //   style: TextStyle(
            //     color: p.text,
            //     fontSize: 14,
            //     fontWeight: FontWeight.w800,
            //   ),
            // ),
            // const SizedBox(height: 12),
            // DeliveryZoneSelector(
            //   zone: cartCtrl.deliveryZone.value,
            //   onChanged: cartCtrl.setDeliveryZone,
            //   tile: p.tile,
            //   border: p.border,
            //   accent: p.accent,
            //   onAccent: p.onAccent,
            //   text: p.text,
            //   muted: p.muted,
            //   enuguSubtitle: _feeText(
            //     cartCtrl.deliveryFeeForZone(DeliveryZone.enugu),
            //   ),
            //   outsideSubtitle: _feeText(
            //     cartCtrl.deliveryFeeForZone(DeliveryZone.outside),
            //   ),
            // ),
            if (loadingSaved.value) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: p.text,
                  backgroundColor: p.tile,
                ),
              ),
            ],
            if (hasSaved.value) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                decoration: BoxDecoration(
                  color: StorePalette.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: StorePalette.success,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'We filled in your saved details.',
                        style: TextStyle(
                          color: StorePalette.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearSaved,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: StorePalette.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            _label('Email', p),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: p.tile,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.mail_outline_rounded, size: 20, color: p.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.lock_outline_rounded, size: 16, color: p.muted),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _label('Phone number', p),
            const SizedBox(height: 8),
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')),
              ],
              validator: _validatePhone,
              style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
              decoration: _decoration(
                p,
                hint: '0803 123 4567',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 20),
            _label('Delivery address', p),
            const SizedBox(height: 8),
            TextFormField(
              controller: addressCtrl,
              minLines: 3,
              maxLines: 4,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.newline,
              autofillHints: const [AutofillHints.fullStreetAddress],
              validator: _validateAddress,
              style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
              decoration: _decoration(
                p,
                hint: 'House number, street, area, city and state',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => remember.value = !remember.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Switch.adaptive(
                      value: remember.value,
                      activeColor: p.accent,
                      onChanged: (v) => remember.value = v,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save for next time',
                            style: TextStyle(
                              color: p.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Skip typing these details on your next order.',
                            style: TextStyle(color: p.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, StorePalette p) {
    return Text(
      text,
      style: TextStyle(
        color: p.text,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _decoration(
    StorePalette p, {
    required String hint,
    required IconData icon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: p.muted, fontWeight: FontWeight.w400),
      prefixIcon: Icon(icon, size: 20, color: p.muted),
      filled: true,
      fillColor: p.tile,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(p.text, 1.5),
      errorBorder: border(StorePalette.danger),
      focusedErrorBorder: border(StorePalette.danger, 1.5),
      errorStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  //==================================================
  // SUMMARY
  //==================================================

  Widget _summaryCard(StorePalette p, {required bool withButton}) {
    final items = cartCtrl.cartItems.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.border),
        boxShadow: p.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order summary',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(EcommerceLiveRoutes.cart),
                child: Text(
                  'Edit cart',
                  style: TextStyle(
                    color: p.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: p.tile,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Base64Image(
                    data: item.image,
                    placeholder: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: p.muted,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.quantity} × ${formatNaira(item.product.price)}'
                        '${item.hasColor ? ' · ${item.colorName}' : ''}',
                        style: TextStyle(color: p.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatNaira(item.total),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          Divider(height: 24, color: p.border),
          _row(p, 'Subtotal', formatNaira(cartCtrl.subtotal)),
          const SizedBox(height: 12),
          _row(
            p,
            'Delivery (${cartCtrl.deliveryZone.value.shortLabel})',
            cartCtrl.deliveryFee > 0
                ? formatNaira(cartCtrl.deliveryFee)
                : 'Free',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: p.border),
          ),
          _row(p, 'Total', formatNaira(cartCtrl.grandTotal), emphasized: true),
          if (withButton) ...[const SizedBox(height: 22), _checkoutActions(p)],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 10, color: p.muted),
              const SizedBox(width: 6),
              Text(
                'Your payment is secure and handled by RealStore.',
                style: TextStyle(color: p.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    StorePalette p,
    String label,
    String value, {
    bool emphasized = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? p.text : p.muted,
              fontSize: emphasized ? 16 : 14,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: p.text,
            fontSize: emphasized ? 18 : 14.5,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: emphasized ? -0.5 : 0,
          ),
        ),
      ],
    );
  }

  //==================================================
  // PAY BUTTON / BOTTOM BAR
  //==================================================

  /// Contact button, a premium "OR" divider, then the pay button.
  Widget _checkoutActions(StorePalette p) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_contactButton(p), _orDivider(p)], //_payButton(p)],
    );
  }

  Widget _contactButton(StorePalette p) {
    final placing = orderCtrl.isPlacingOrder.value;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: placing ? null : _contactRealstore,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: p.surface,
          foregroundColor: p.text,
          side: BorderSide(color: p.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_rounded,
                size: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Contact Realstore'),
          ],
        ),
      ),
    );
  }

  Widget _orDivider(StorePalette p) {
    Widget line(bool fadeLeft) => Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: fadeLeft
                ? [Colors.transparent, p.border]
                : [p.border, Colors.transparent],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          line(true),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: p.tile,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border),
            ),
            child: Text(
              //'OR',
              'We accept orders via WhatsApp',
              style: TextStyle(
                color: p.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
          ),
          line(false),
        ],
      ),
    );
  }

  // Widget _payButton(StorePalette p) {
  //   final placing = orderCtrl.isPlacingOrder.value;

  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: placing ? null : _submit,
  //       style: ElevatedButton.styleFrom(
  //         elevation: 0,
  //         minimumSize: const Size.fromHeight(56),
  //         backgroundColor: p.accent,
  //         foregroundColor: p.onAccent,
  //         disabledBackgroundColor: p.tile,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(18),
  //         ),
  //         textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
  //       ),
  //       child: placing
  //           ? SizedBox(
  //               width: 22,
  //               height: 22,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2.5,
  //                 color: p.text,
  //               ),
  //             )
  //           : Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Icon(Icons.lock_outline_rounded, size: 18),
  //                 const SizedBox(width: 10),
  //                 Text('Pay ${formatNaira(cartCtrl.grandTotal)}'),
  //               ],
  //             ),
  //     ),
  //   );
  // }

  Widget _bottomBar(StorePalette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(top: false, child: _checkoutActions(p)),
    );
  }
}
