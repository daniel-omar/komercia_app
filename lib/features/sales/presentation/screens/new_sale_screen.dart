import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/presentation/providers/discount_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/payment_types_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_colors_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_sizes_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/products_purchase_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/providers.dart';
import 'package:komercia_app/features/sales/presentation/widgets/payment_type_bottom_sheet.dart';
import 'package:komercia_app/features/sales/presentation/widgets/product_purchase_card.dart';
import 'package:komercia_app/features/shared/widgets/barcode_scanner.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  NewSaleScreenState createState() => NewSaleScreenState();
}

class NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Orden Actualizado')));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showProductPurchaseValidationErrorsProvider.notifier).state =
          false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  double total = 0;
  bool isLoading = false;

  // Future<String?> readScanner(BuildContext context_) async {
  //   String? res = await SimpleBarcodeScanner.scanBarcode(
  //     context_,
  //     barcodeAppBar: const BarcodeAppBar(
  //       appBarTitle: 'Test',
  //       centerTitle: false,
  //       enableBackButton: true,
  //       backButtonIcon: Icon(Icons.arrow_back_ios),
  //     ),
  //     isShowFlashIcon: true,
  //     delayMillis: 100,
  //     cameraFace: CameraFace.back,
  //     scanFormat: ScanFormat.ONLY_BARCODE,
  //   );
  //   return res;
  // }

  void onScanner() async {
    String? codigoProducto = await readScanner(context);

    if (!mounted || codigoProducto == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await findProduct(codigoProducto, context);
    });
  }

  void onClear() async {
    ref.read(productsPurchaseProvider.notifier).clear();
    ref.read(discountProvider.notifier).state = DiscountState.none();
  }

  Future<String?> readScanner(BuildContext context_) async {
    final navigator = Navigator.of(context_, rootNavigator: true);
    final result = await navigator.push(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    return result;
  }

  Future<void> findProduct(String codigoProducto, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final product =
          await ref.read(productProvider.notifier).findProduct(codigoProducto);
      if (!mounted) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      if (product == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Producto no se encuentra en inventario.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final productoState = ref.read(productProvider);

      await ref
          .read(productSizesProvider.notifier)
          .loadSizesByProduct(productoState.idProducto);
      if (!mounted) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final productSizesState = ref.watch(productSizesProvider);
      if (productSizesState.productSizes!.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cuenta con tallas disponibles.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      await ref
          .read(productColorsProvider.notifier)
          .loadColorsByProduct(productoState.idProducto);
      if (!mounted) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final productColorsState = ref.read(productColorsProvider);
      if (productColorsState.productColors!.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cuenta con colores disponibles.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      ref
          .read(productsPurchaseProvider.notifier)
          .addProduct(productoState.producto!);
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showPaymentOptionsSheet(BuildContext _context) {
    final productsPurchaseState = ref.read(productsPurchaseProvider);
    if (productsPurchaseState.isEmpty) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Debe escanear productos.')),
      );
      return;
    }

    final hasInvalid =
        productsPurchaseState.any((p) => (p.idTalla == 0 || p.idColor == 0));
    if (hasInvalid) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(
            content: Text('Todos los productos deben tener talla y color.')),
      );
      return;
    }

    FocusScope.of(_context).unfocus();
    ref.read(selectedPaymentTypeIndexProvider.notifier).state = -1;
    ref.read(selectedPaymentTypeProvider.notifier).state = null;

    showModalBottomSheet(
      context: _context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (_) => const PaymentTypeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ref.read(orderProvider.notifier).loadSale(widget.idSale);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nueva Venta'),
          backgroundColor: Colors.yellow[700],
          foregroundColor: Colors.black,
          actions: [
            SizedBox(
              child: Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.restore_from_trash_rounded),
                  tooltip: 'Limpiar',
                  onPressed: onClear,
                ),
              ),
            ),
            SizedBox(
              child: Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear QR',
                  onPressed: onScanner,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            const _ProductsPurcharseView(),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3), // fondo semitransparente
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Consumer(
          builder: (context, ref, _) {
            final discount = ref.watch(discountProvider);

            final total = ref.watch(totalSaleComputedProvider);
            final totalFinal = ref.watch(totalFinalComputedProvider);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "S/ ${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (discount.hasDiscount) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Descuento:",
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text(
                          'S/ ${(total - totalFinal).toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total final:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          'S/ ${totalFinal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showPaymentOptionsSheet(context);
                          },
                          icon: const Icon(
                            Icons.payment,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Pagar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(6), // menor radio aquí
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) =>
                                const _DiscountSelectorBottomSheet(),
                          );
                        },
                        icon: const Icon(Icons.percent),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 12),
                          backgroundColor: Colors.orange.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(6), // menor radio aquí
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductsPurcharseView extends ConsumerStatefulWidget {
  const _ProductsPurcharseView();

  @override
  __ProductsPurcharseState createState() => __ProductsPurcharseState();
}

class __ProductsPurcharseState extends ConsumerState {
  final ScrollController scrollController = ScrollController();
  int idUsuario = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsPurchaseState = ref.watch(productsPurchaseProvider);
    final productColorsState = ref.watch(productColorsProvider);
    final productSizesState = ref.watch(productSizesProvider);

    final hasColors = productColorsState.productColors != null &&
        productColorsState.productColors!.isNotEmpty;
    final hasSizes = productSizesState.productSizes != null &&
        productSizesState.productSizes!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: productsPurchaseState.length,
        itemBuilder: (context, index) {
          final productPurchaseState = productsPurchaseState[index];

          if (!hasColors || !hasSizes) {
            return const SizedBox.shrink(); // o CircularProgressIndicator()
          }

          return ProductPurcharseCard(
            product: productPurchaseState.producto!,
            state: productPurchaseState,
            productColors: productColorsState.productColors != null
                ? productColorsState.productColors!
                : [],
            productSizes: productSizesState.productSizes != null
                ? productSizesState.productSizes!
                : [],
          );
        },
      ),
    );
  }
}

class _DiscountSelectorBottomSheet extends ConsumerStatefulWidget {
  const _DiscountSelectorBottomSheet();

  @override
  ConsumerState<_DiscountSelectorBottomSheet> createState() =>
      _DiscountSelectorBottomSheetState();
}

class _DiscountSelectorBottomSheetState
    extends ConsumerState<_DiscountSelectorBottomSheet> {
  final TextEditingController _discountController = TextEditingController();
  DiscountType _selectedType = DiscountType.fixed;

  @override
  void initState() {
    super.initState();
    final discount = ref.read(discountProvider);
    _selectedType = discount.type;

    final initialValue = discount.monto;
    _discountController.text =
        initialValue > 0 ? initialValue.toStringAsFixed(2) : '';
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _applyDiscount() {
    final value = double.tryParse(_discountController.text);
    if (value == null || value <= 0) return;

    ref.read(discountProvider.notifier).state = DiscountState(
      monto: value,
      type: _selectedType,
    );
    Navigator.pop(context);
  }

  void _clearDiscount() {
    ref.read(discountProvider.notifier).state = DiscountState.none();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aplicar descuento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<DiscountType>(
                  segments: const [
                    ButtonSegment(
                        value: DiscountType.fixed, label: Text('Monto fijo')),
                    ButtonSegment(
                        value: DiscountType.percent, label: Text('Porcentaje')),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedType = newSelection.first;
                    });
                  },
                  multiSelectionEnabled: false,
                  showSelectedIcon: false,
                  style:
                      const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _selectedType == DiscountType.fixed
                    ? 'Monto fijo (S/)'
                    : 'Porcentaje (%)',
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: _applyDiscount,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(25), // menor radio aquí
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _clearDiscount,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('Quitar descuento',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
