import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/presentation/providers/products_variants_selection_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/product_variants_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/full_screen_loader.dart';

class ProductVariantsScreen extends ConsumerStatefulWidget {
  final int idProduct;
  final String nameProduct;

  const ProductVariantsScreen(
      {super.key, required this.idProduct, required this.nameProduct});

  @override
  ConsumerState<ProductVariantsScreen> createState() =>
      _ProductVariantsScreenState();
}

class _ProductVariantsScreenState extends ConsumerState<ProductVariantsScreen> {
  late final listener;
  @override
  void initState() {
    super.initState();

    listener = ref.listenManual<ProductVariantsState>(
      productVariantsProvider(widget.idProduct),
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

    Future.microtask(() {
      ref.read(productsVariantSelectionProvider.notifier).clear();

      ref
          .read(productVariantsProvider(widget.idProduct).notifier)
          .getVariants();
    });
  }

  @override
  void dispose() {
    listener.close(); // cerrar manualmente para evitar múltiples ejecuciones
    super.dispose();
  }

  void saveOutput(
      List<ProductVariantSelection> productVariantsSelection) async {
    if (productVariantsSelection.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimnar'),
        content: const Text('¿Está seguro de eliminar?'),
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

    // Lógica para imprimir
    List<ProductVariant> productsVariants = [];
    for (var i = 0; i < productVariantsSelection.length; i++) {
      final productVariantSelection = productVariantsSelection[i];
      productsVariants.add(ProductVariant(
          idProducto: productVariantSelection.idProducto,
          idProductoVariante: productVariantSelection.idProductoVariante,
          idTalla: 0,
          idColor: 0,
          cantidad: productVariantSelection.cantidad));
    }

    ref
        .read(productVariantsProvider(widget.idProduct).notifier)
        .saveOutput(productsVariants);
  }

  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final productVariantsState =
        ref.watch(productVariantsProvider(widget.idProduct));
    final productVariantsSelection =
        ref.watch(productsVariantSelectionProvider);

    if (productVariantsState.isLoading) {
      return const FullScreenLoader();
    }

    final productVariants = productVariantsState.productVariants ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Etiquetas: ${widget.nameProduct}'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(widget.nameProduct.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  tooltip: "Eliminar materiales",
                  icon: Icon(
                    _isSelectionMode ? Icons.close : Icons.delete_outline,
                    size: 30,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = !_isSelectionMode;
                      if (!_isSelectionMode) {
                        // Limpiar selección cuando salgas del modo selección
                        ref
                            .read(productsVariantSelectionProvider.notifier)
                            .clear();
                      }
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: productVariants.length,
                itemBuilder: (_, i) {
                  final producVariant = productVariants[i];
                  final producVariantSelection =
                      productVariantsSelection.firstWhereOrNull((s) =>
                          s.idProductoVariante ==
                          producVariant.idProductoVariante);

                  return _ProductVariantCard(
                    producVariant: producVariant,
                    producVariantSelection: producVariantSelection,
                    isDelete: _isSelectionMode,
                  );
                },
              ),
            ),
            if (_isSelectionMode) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: productVariantsSelection.isEmpty
                    ? null
                    : () {
                        saveOutput(productVariantsSelection);
                      },
                child: const Text(
                  'Reajustar cantidades',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _ProductVariantCard extends ConsumerStatefulWidget {
  final ProductVariant producVariant;
  final ProductVariantSelection? producVariantSelection;
  final bool isDelete;

  const _ProductVariantCard(
      {super.key,
      required this.producVariant,
      required this.producVariantSelection,
      required this.isDelete});

  @override
  ConsumerState<_ProductVariantCard> createState() =>
      _ProductVariantCardState();
}

class _ProductVariantCardState extends ConsumerState<_ProductVariantCard> {
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
    final isSelected = widget.producVariantSelection == null ? false : true;
    final producVariant = widget.producVariant;
    final producVariantSelection = widget.producVariantSelection;
    final isDelete = widget.isDelete;

    final cantidadActual = producVariantSelection == null
        ? 0.toString()
        : producVariantSelection.cantidad.toString();
    if (quantityController.text != cantidadActual) {
      quantityController.text = cantidadActual;
    }

    void updateQuantity(int value) {
      ref.read(productsVariantSelectionProvider.notifier).updateCantidad(
            producVariant.idProductoVariante!,
            value,
          );
    }

    int currentValue() => int.tryParse(quantityController.text) ?? 0;
    void onIncrement() {
      int cantidad = currentValue() + 1;
      if (cantidad > producVariant.cantidad) return;
      quantityController.text = cantidad.toString();
      updateQuantity(cantidad);
    }

    void onDecrement() {
      if (currentValue() > 1) {
        int cantidad = currentValue() - 1;
        quantityController.text = cantidad.toString();
        updateQuantity(cantidad);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blueGrey, width: 1)),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 8, vertical: (isDelete ? 0 : 8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Botón eliminar
            if (isDelete) ...[
              SizedBox(
                width: 35,
                child: Transform.scale(
                  scale:
                      1.75, // aumenta o reduce el tamaño (1.0 es el tamaño por defecto)
                  child: Checkbox(
                    value: isSelected,
                    onChanged: producVariant.cantidad > 0
                        ? (_) {
                            ref
                                .read(productsVariantSelectionProvider.notifier)
                                .toggleSelection(producVariant.idProducto,
                                    producVariant.idProductoVariante!);
                          }
                        : null,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 6),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (producVariant.codigoProductoVariante != null) ...[
                    Row(
                      children: [
                        const Text('Codigo: '),
                        SelectableText(
                          producVariant.codigoProductoVariante!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    children: [
                      const Text('Talla:   '),
                      Text(producVariant.talla!.nombreTalla,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Color: '),
                      Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: producVariant.color!.idColor !=
                                  colorsMap["Predeterminado"]!
                              ? producVariant.color!.color
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          producVariant.color!.nombreColor,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color:
                                producVariant.color!.color.computeLuminance() <
                                            0.5 &&
                                        producVariant.color!.idColor !=
                                            colorsMap["Predeterminado"]!
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isDelete) ...[
                    Row(
                      children: [
                        const Text('Cantidad:   '),
                        Text(producVariant.cantidad.toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(width: 4),

            SizedBox(
              width: 45,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDelete) ...[
                    IconButton(
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                      onPressed: onDecrement,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
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
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: TextField(
                          enabled: isSelected,
                          controller: quantityController,
                          key: ValueKey(widget.producVariant.cantidad),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 1, horizontal: 0),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
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
                        padding: WidgetStateProperty.all<EdgeInsets>(
                            EdgeInsets.zero),
                      ),
                    ),
                  ] else ...[
                    Text(
                      producVariant.cantidad.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
