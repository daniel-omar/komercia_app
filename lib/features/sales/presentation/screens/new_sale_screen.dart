import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/products_provider.dart';
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

    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        crossAxisCount: 1,
        mainAxisSpacing: 20,
        crossAxisSpacing: 35,
        itemCount: productsPurchaseState.length,
        itemBuilder: (context, index) {
          final productPurchaseState = productsPurchaseState[index];
          return GestureDetector(
              child: ProductPurcharseCard(
                  product: productPurchaseState.producto!));
        },
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final List<String> selectedSizes;
  final List<String> sizes = const ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  final void Function(List<String> selectedSizes) onSizesChanged;

  const _SizeSelector({
    required this.selectedSizes,
    required this.onSizesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: sizes.map((size) {
        return ButtonSegment(
            value: size,
            label: Text(size, style: const TextStyle(fontSize: 10)));
      }).toList(),
      selected: Set.from(selectedSizes),
      onSelectionChanged: (newSelection) {
        FocusScope.of(context).unfocus();
        onSizesChanged(List.from(newSelection));
      },
      multiSelectionEnabled: true,
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final void Function(String selectedGender) onGenderChanged;

  final List<String> genders = const ['men', 'women', 'kid'];
  final List<IconData> genderIcons = const [
    Icons.man,
    Icons.woman,
    Icons.boy,
  ];

  const _GenderSelector(
      {required this.selectedGender, required this.onGenderChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: genders.map((size) {
          return ButtonSegment(
              icon: Icon(genderIcons[genders.indexOf(size)]),
              value: size,
              label: Text(size, style: const TextStyle(fontSize: 12)));
        }).toList(),
        selected: {selectedGender},
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus();
          onGenderChanged(newSelection.first);
        },
      ),
    );
  }
}
