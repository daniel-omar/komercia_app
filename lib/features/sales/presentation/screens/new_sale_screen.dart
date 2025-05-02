import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/payment_types_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_colors_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_sizes_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/products_purchase_provider.dart';
import 'package:komercia_app/features/sales/presentation/widgets/payment_type_card.dart';
import 'package:komercia_app/features/sales/presentation/widgets/product_purchase_card.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> readScanner() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Test',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 100,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
    );
    return res;
  }

  Future<void> findProduct(String codigoProducto) async {
    final product =
        await ref.read(productProvider.notifier).findProduct(codigoProducto);

    if (product != null) {
      final productoState = ref.read(productProvider);

      ref
          .read(productsPurchaseProvider.notifier)
          .addProduct(productoState.producto!);
    } else {
      // mostrar error
    }
  }

  void _showPaymentOptionsSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    ref.read(selectedPaymentTypeIndexProvider.notifier).state = -1;
    ref.read(selectedPaymentTypeProvider.notifier).state = null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (_) {
        // Usamos un Consumer para poder acceder a `ref.watch` dentro del BottomSheet
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(paymentTypesProvider);
            final selectedIndex = ref.watch(selectedPaymentTypeIndexProvider);

            if (state.isLoading || state.paymentTypes == null) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return FractionallySizedBox(
              widthFactor: 1.0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        const Text(
                          'Selecciona el método de pago',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: state.paymentTypes!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.8,
                      ),
                      itemBuilder: (context, index) {
                        final paymentType = state.paymentTypes![index];
                        final isSelected = selectedIndex == index;

                        return PaymentTypeCard(
                          label: paymentType.nombreTipoPago,
                          icon: paymentType.iconData,
                          onTap: () {
                            ref
                                .read(selectedPaymentTypeIndexProvider.notifier)
                                .state = index;
                            ref
                                .read(selectedPaymentTypeProvider.notifier)
                                .state = paymentType;
                          },
                          isSelected: isSelected,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handlePayment(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'CREAR VENTA',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handlePayment(BuildContext context) {
    final selectedPaymentType = ref.watch(selectedPaymentTypeProvider);
    if (selectedPaymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccioanr un método de pago')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Método seleccionado: ${selectedPaymentType.nombreTipoPago} ')),
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
          actions: [
            SizedBox(
              width: 80,
              child: Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Increase volume by 10',
                  onPressed: () async {
                    String? codigoProducto = await readScanner();
                    await findProduct(codigoProducto!);
                  },
                ),
              ),
            ),
          ],
        ),
        body: const _ProductsPurcharseView(),
        bottomNavigationBar: Consumer(
          builder: (context, ref, _) {
            final total = ref.watch(productsPurchaseProvider.select(
              (items) => items.fold(
                  0.0, (sum, item) => sum + (item.precio ?? 0) * item.cantidad),
            ));

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: S/ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showPaymentOptionsSheet(context);
                    },
                    icon: const Icon(
                      Icons.payment,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Pagar',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.blue.shade900,
                    ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        // crossAxisCount: 1,
        // mainAxisSpacing: 20,
        // crossAxisSpacing: 35,
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
