import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_colors_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_sizes_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/products_purchase_provider.dart';
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

  String serie = '';
  TextEditingController textEditingController = TextEditingController();

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

  void _changeSerie(String serie) {
    print(serie);
    setState(() {
      textEditingController.text = serie;
    });
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
          body: const _ProductsPurcharseView()),
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
