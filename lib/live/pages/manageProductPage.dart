import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:realstore/live/liveControllers/blackFridayController.dart';
import 'package:realstore/live/liveControllers/manageProductController.dart';
import 'package:realstore/live/liveControllers/storeConfig.dart';
import 'package:realstore/live/models/productModel.dart';

const Color _gold = Color(0xFFF5B301);
const Color _red = Color(0xFFE5484D);
const Color _green = Color(0xFF16A34A);

String _naira(num value) {
  final whole = value == value.roundToDouble();
  final parts = value.toStringAsFixed(whole ? 0 : 2).split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '₦$grouped${parts.length > 1 ? '.${parts[1]}' : ''}';
}

String _trimNumber(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class ManageProductsPage extends StatelessWidget {
  ManageProductsPage({super.key});

  final ManageProductsController ctrl = Get.put(ManageProductsController());
  final BlackFridayController bf = BlackFridayController.ensure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Manage Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ctrl.listenProducts();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _blackFridayCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (value) {
                  ctrl.searchQuery.value = value;
                },
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          /// PRODUCTS
          Obx(() {
            final products = ctrl.filteredProducts;

            if (products.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text("No products found")),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, index) => _productCard(products[index]),
                  childCount: products.length,
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  //==================================================
  // BLACK FRIDAY CARD
  //==================================================

  Widget _blackFridayCard() {
    return Obx(() {
      final on = bf.isActive.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: on
                ? const [Color(0xFF2A2005), Color(0xFF0B0B0C)]
                : const [Color(0xFF1F1F23), Color(0xFF0B0B0C)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: on ? _gold.withOpacity(0.7) : Colors.white12,
          ),
          boxShadow: [
            BoxShadow(
              color: on ? _gold.withOpacity(0.28) : const Color(0x22000000),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: on ? _gold : Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: on ? Colors.black : Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'BLACK FRIDAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // AnimatedSwitcher(
                          //   duration: const Duration(milliseconds: 250),
                          //   child: on
                          //       ? Container(
                          //           key: const ValueKey('live'),
                          //           padding: const EdgeInsets.symmetric(
                          //             horizontal: 8,
                          //             vertical: 3,
                          //           ),
                          //           decoration: BoxDecoration(
                          //             color: _gold,
                          //             borderRadius: BorderRadius.circular(8),
                          //           ),
                          //           child: const Text(
                          //             'LIVE',
                          //             style: TextStyle(
                          //               color: Colors.black,
                          //               fontSize: 1,
                          //               fontWeight: FontWeight.w900,
                          //               letterSpacing: 1,
                          //             ),
                          //           ),
                          //         )
                          //       : const SizedBox.shrink(key: ValueKey('off')),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        on
                            ? 'Live now. Discounted prices are showing across the store.'
                            : 'Off. Every product shows its normal price.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _bfSwitch(on),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openBulkSheet,
                icon: const Icon(Icons.percent_rounded, size: 18),
                label: const Text('Discount all products'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Only products with a discount % are reduced. '
              'Switching off restores every normal price instantly.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _bfSwitch(bool on) {
    return GestureDetector(
      onTap: () => _confirmToggle(on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 64,
        height: 36,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: on ? _gold : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: on ? Colors.black : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              on ? Icons.bolt_rounded : Icons.power_settings_new_rounded,
              size: 16,
              color: on ? _gold : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmToggle(bool currentlyOn) {
    HapticFeedback.mediumImpact();

    final turningOn = !currentlyOn;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          turningOn ? 'Start Black Friday?' : 'End Black Friday?',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          turningOn
              ? 'Discounted prices will show to every customer immediately.'
              : 'All prices go back to normal for every customer immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              bf.setActive(turningOn);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(turningOn ? 'Turn on' : 'Turn off'),
          ),
        ],
      ),
    );
  }

  Future<void> _openBulkSheet() async {
    await Get.bottomSheet(
      _BulkSheet(bf: bf),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _openPricingSheet(ProductModel product) async {
    await Get.bottomSheet(
      _PricingSheet(product: product, bf: bf),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  //==================================================
  // PRODUCT CARD
  //==================================================

  Widget _chip(String text, Color color, {Color? background}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? color.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    // Own Obx so each card updates the moment the switch flips.
    return Obx(() {
      final onSale = product.isOnBlackFriday;
      final pct = _trimNumber(product.blackFridayPercent);

      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: onSale ? _gold.withOpacity(0.8) : Colors.black12,
            width: onSale ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(product.images.first),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_not_supported),
                      ),
                const SizedBox(width: 12),

                /// DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.category,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      if (onSale)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              _naira(product.price),
                              style: const TextStyle(
                                color: _red,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _naira(product.regularPrice),
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 12.5,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            _chip('-$pct%', Colors.black, background: _gold),
                          ],
                        )
                      else
                        Text(
                          _naira(product.regularPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        "Stock: ${product.stock}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _chip(
                            product.isActive ? "Active" : "Inactive",
                            product.isActive ? _green : _red,
                          ),
                          if (product.hasBlackFridayDiscount && !onSale)
                            _chip(
                              'Black Friday -$pct% (when live)',
                              const Color(0xFF9A6B00),
                              background: _gold.withOpacity(0.18),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            /// ACTIONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openPricingSheet(product),
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Edit price'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black26),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: "Enable / Disable",
                  icon: Icon(
                    product.isActive ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    ctrl.toggleProductStatus(product);
                  },
                ),
                IconButton(
                  tooltip: "Delete Product",
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Delete Product",
                      middleText:
                          "Are you sure you want to delete this product?",
                      textConfirm: "Delete",
                      textCancel: "Cancel",
                      confirmTextColor: Colors.white,
                      onConfirm: () async {
                        Get.back();

                        await ctrl.deleteProduct(product.id);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

//==================================================
// SHARED BITS
//==================================================

BoxDecoration _sheetDecoration() => const BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
);

Widget _sheetHandle() => Center(
  child: Container(
    width: 42,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(4),
    ),
  ),
);

/// Quick-pick discount pills (10 / 20 / 30 / 40 / 50 %).
class _PercentChips extends StatelessWidget {
  const _PercentChips({required this.selected, required this.onPick});

  final double selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in const [10, 20, 30, 40, 50])
          GestureDetector(
            onTap: () => onPick(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: selected == v ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected == v ? Colors.black : Colors.black26,
                ),
              ),
              child: Text(
                '$v%',
                style: TextStyle(
                  color: selected == v ? _gold : Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

InputDecoration _fieldDecoration(
  String label, {
  String? prefix,
  String? suffix,
}) {
  return InputDecoration(
    labelText: label,
    prefixText: prefix,
    suffixText: suffix,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );
}

//==================================================
// EDIT PRICING SHEET (normal price + Black Friday %)
//==================================================

class _PricingSheet extends StatefulWidget {
  const _PricingSheet({required this.product, required this.bf});

  final ProductModel product;
  final BlackFridayController bf;

  @override
  State<_PricingSheet> createState() => _PricingSheetState();
}

class _PricingSheetState extends State<_PricingSheet> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _percentCtrl;

  late final double _originalSeller;

  String? _error;

  @override
  void initState() {
    super.initState();

    _originalSeller = widget.bf.sellerPriceOf(widget.product);

    _priceCtrl = TextEditingController(
      text: _trimNumber(double.parse(_originalSeller.toStringAsFixed(2))),
    );
    _percentCtrl = TextEditingController(
      text: widget.product.blackFridayPercent > 0
          ? _trimNumber(widget.product.blackFridayPercent)
          : '',
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _percentCtrl.dispose();
    super.dispose();
  }

  double? get _seller => double.tryParse(_priceCtrl.text.trim());

  double get _percent => double.tryParse(_percentCtrl.text.trim()) ?? 0;

  Future<void> _save() async {
    final seller = _seller;

    if (seller == null || seller <= 0) {
      setState(() => _error = 'Enter a valid price');
      return;
    }

    if (_percent > BlackFridayController.maxPercent) {
      setState(
        () => _error =
            'Discount can be at most ${BlackFridayController.maxPercent.toInt()}%',
      );
      return;
    }

    final priceChanged = (seller - _originalSeller).abs() > 0.005;
    final percentChanged = _percent != widget.product.blackFridayPercent;

    if (!priceChanged && !percentChanged) {
      Get.back();
      return;
    }

    final ok = await widget.bf.saveProductPricing(
      widget.product,
      sellerPrice: priceChanged ? seller : null,
      percent: percentChanged ? _percent : null,
    );

    if (ok) {
      Get.back();
      Get.snackbar('Saved', 'Pricing updated for ${widget.product.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = _seller ?? 0;
    final selling = widget.bf.sellingPriceFor(seller);
    final pct = _percent.clamp(0, BlackFridayController.maxPercent).toDouble();
    final salePrice = (selling * (1 - pct / 100)).roundToDouble();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: _sheetDecoration(),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (widget.product.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(widget.product.images.first),
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (widget.product.images.isNotEmpty)
                      const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit pricing',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            widget.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ---------- normal price ----------
                const Text(
                  'Normal price',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Used all year round. Black Friday never changes this.',
                  style: TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => setState(() => _error = null),
                  decoration: _fieldDecoration('Your price', prefix: '₦ '),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customers pay ${_naira(selling)} '
                  '(includes ${_trimNumber(StoreConfig.platformFeeRate * 100)}% platform fee)',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),

                // ---------- black friday ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _gold.withOpacity(0.55)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_offer_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Black Friday discount',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _PercentChips(
                        selected: pct,
                        onPick: (v) => setState(() {
                          _percentCtrl.text = '$v';
                          _error = null;
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _percentCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => setState(() => _error = null),
                        decoration: _fieldDecoration('Discount', suffix: '%')
                            .copyWith(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Leave empty for no discount',
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (pct > 0)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              _naira(salePrice),
                              style: const TextStyle(
                                color: _red,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              _naira(selling),
                              style: const TextStyle(
                                color: Colors.black45,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'saves ${_naira(selling - salePrice)}',
                              style: const TextStyle(
                                color: _green,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'No discount on this product.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.5,
                          ),
                        ),
                      const SizedBox(height: 6),
                      const Text(
                        'Customers only see this price while Black Friday is switched on.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: _red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.bf.isSaving.value ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: widget.bf.isSaving.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save changes',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
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

//==================================================
// DISCOUNT ALL SHEET
//==================================================

class _BulkSheet extends StatefulWidget {
  const _BulkSheet({required this.bf});

  final BlackFridayController bf;

  @override
  State<_BulkSheet> createState() => _BulkSheetState();
}

class _BulkSheetState extends State<_BulkSheet> {
  final TextEditingController _percentCtrl = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _percentCtrl.dispose();
    super.dispose();
  }

  double get _percent => double.tryParse(_percentCtrl.text.trim()) ?? 0;

  Future<void> _apply(double percent) async {
    final count = await widget.bf.applyPercentToAll(percent);

    if (count > 0) {
      Get.back();
      Get.snackbar(
        'Done',
        percent > 0
            ? '${_trimNumber(percent)}% Black Friday discount set on $count products'
            : 'Discounts removed from $count products',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: _sheetDecoration(),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 18),
                const Text(
                  'Discount all products',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sets the same Black Friday % on every product. '
                  'You can still change single products afterwards.',
                  style: TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                _PercentChips(
                  selected: _percent,
                  onPick: (v) => setState(() {
                    _percentCtrl.text = '$v';
                    _error = null;
                  }),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _percentCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: (_) => setState(() => _error = null),
                  decoration: _fieldDecoration('Discount', suffix: '%'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: _red, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 16),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.bf.isSaving.value
                          ? null
                          : () {
                              final v = _percent;
                              if (v <= 0 ||
                                  v > BlackFridayController.maxPercent) {
                                setState(
                                  () => _error =
                                      'Enter a discount from 1 to ${BlackFridayController.maxPercent.toInt()}%',
                                );
                                return;
                              }
                              _apply(v);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: widget.bf.isSaving.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Apply to all products',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () => _apply(0),
                    child: const Text(
                      'Remove all discounts',
                      style: TextStyle(
                        color: _red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
