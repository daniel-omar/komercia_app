import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/presentation/providers/product_variant_provider.dart'
    show productVariantProvider;
import 'package:komercia_app/features/products/presentation/providers/product_variants_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/products_inventory_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/barcode_scanner.dart';

class LoadInventoryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoadInventoryScreen> createState() =>
      _LoadInventoryScreenState();
}

class _LoadInventoryScreenState extends ConsumerState<LoadInventoryScreen> {
  final TextEditingController _codigoController = TextEditingController();

  bool isLoading = false;

  void onScanner() async {
    String? codigoProducto = await readScanner(context);
    if (!mounted || codigoProducto == null) return;
    _codigoController.text = codigoProducto;
  }

  Future<String?> readScanner(BuildContext context_) async {
    final navigator = Navigator.of(context_, rootNavigator: true);
    final result = await navigator.push(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    return result;
  }

  Future<ProductVariant?> findProductVariant(
      String codigoProductoVariante, BuildContext context) async {
    try {
      final productVariant = await ref
          .read(productVariantProvider.notifier)
          .findProductVariant(codigoProductoVariante);

      return productVariant;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void addProduct() async {
    if (_codigoController.text == "") {
      _codigoController.text = "";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final productVariant =
        await findProductVariant(_codigoController.text, context);

    if (productVariant == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto no existe o está inactivo.')),
      );
      setState(() {
        isLoading = false;
      });
      return null;
    }

    ref
        .read(productsInventoryProvider.notifier)
        .addProductVariant(productVariant, 1);

    setState(() {
      isLoading = false;
    });
  }

  void saveIncome(List<ProductVariant> productsVariants) async {
    if (productsVariants.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar'),
        content: const Text('¿Está seguro de guardar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == false) return;

    ref.read(productVariantsProvider(0).notifier).saveIncome(productsVariants);
  }

  late final listener;
  @override
  void initState() {
    super.initState();

    listener = ref.listenManual<ProductVariantsState>(
      productVariantsProvider(0),
      (previous, next) {
        if (!mounted) return;
        if (next.success) {
          Navigator.pop(context, true);
        } else if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar')),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    listener.close(); // cerrar manualmente para evitar múltiples ejecuciones
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsVariants = ref.watch(productsInventoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Carga de Inventario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Si estamos en modo escáner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Código del Producto',
                      // border: OutlineInputBorder(),
                    ),
                    controller: _codigoController,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear QR',
                  onPressed: onScanner,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.orangeAccent),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: addProduct,
              child: const Text('Agregar'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: productsVariants.length,
                itemBuilder: (_, i) {
                  final producVariant = productsVariants[i];

                  return ProductPurcharseCard(
                    producVariant: producVariant,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: productsVariants.isEmpty
                  ? null
                  : () {
                      saveIncome(productsVariants);
                    },
              child: const Text(
                'Guardar Inventario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductPurcharseCard extends ConsumerStatefulWidget {
  final ProductVariant producVariant;

  const ProductPurcharseCard({super.key, required this.producVariant});

  @override
  ConsumerState<ProductPurcharseCard> createState() =>
      __ProductVariantCardState();
}

class __ProductVariantCardState extends ConsumerState<ProductPurcharseCard> {
  late final TextEditingController quantityController;

  @override
  void initState() {
    quantityController = TextEditingController(
      text: widget.producVariant.cantidad.toString(),
    );
    super.initState();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cantidadActual = widget.producVariant.cantidad.toString();
    if (quantityController.text != cantidadActual) {
      quantityController.text = cantidadActual;
    }

    void updateQuantity(int value) {
      ref.read(productsInventoryProvider.notifier).updateProductVariant(
            widget.producVariant,
            cantidad: value,
          );
    }

    int currentValue() => int.tryParse(quantityController.text) ?? 0;
    void onIncrement() {
      String cantidad = (currentValue() + 1).toString();
      quantityController.text = cantidad;
      updateQuantity(int.parse(cantidad));
    }

    void onDecrement() {
      if (currentValue() > 1) {
        String cantidad = (currentValue() - 1).toString();
        quantityController.text = cantidad;
        updateQuantity(int.parse(cantidad));
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blueGrey, width: 1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Botón eliminar
            SizedBox(
              width: 40,
              child: Transform.scale(
                scale: 1.5,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    ref
                        .read(productsInventoryProvider.notifier)
                        .removeProductVariant(
                          widget.producVariant.idProductoVariante!,
                        );
                  },
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('Producto: '),
                    Text(widget.producVariant.nombreProducto ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  Row(children: [
                    const Text('Codigo: '),
                    Text(widget.producVariant.codigoProductoVariante ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  Row(children: [
                    const Text('Talla:   '),
                    Text(widget.producVariant.talla!.nombreTalla,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  Row(children: [
                    const Text('Color: '),
                    Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.producVariant.color!.idColor !=
                                colorsMap["Predeterminado"]!
                            ? widget.producVariant.color!.color
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.producVariant.color!.nombreColor,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: widget.producVariant.color!.color
                                          .computeLuminance() <
                                      0.5 &&
                                  widget.producVariant.color!.idColor !=
                                      colorsMap["Predeterminado"]!
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(width: 4),

            // Botones de cantidad
            SizedBox(
              width: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    iconSize: 20,
                    onPressed: onDecrement,
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    constraints: const BoxConstraints(
                      minHeight: 30,
                      minWidth: 30,
                      maxHeight: 30,
                      maxWidth: 30,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.black),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(vertical: 0)),
                    ),
                  ),
                  SizedBox(
                    height: 28,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: TextField(
                        controller: quantityController,
                        key: ValueKey(widget.producVariant.cantidad),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                    onPressed: onIncrement,
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minHeight: 30,
                      minWidth: 30,
                      maxHeight: 30,
                      maxWidth: 30,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.black),
                      padding:
                          WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
