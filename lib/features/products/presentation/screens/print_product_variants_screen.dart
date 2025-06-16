import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/presentation/providers/print_products_variants_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/product_variants_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/full_screen_loader.dart';

class PrintProductVariantsScreen extends ConsumerStatefulWidget {
  final int idProduct;
  final String name;

  const PrintProductVariantsScreen(
      {super.key, required this.idProduct, required this.name});

  @override
  ConsumerState<PrintProductVariantsScreen> createState() =>
      _PrintProductVariantsScreen();
}

class _PrintProductVariantsScreen
    extends ConsumerState<PrintProductVariantsScreen> {
  @override
  void initState() {
    super.initState();

    // Llamar getVariants cuando se monte el modal
    Future.microtask(() {
      ref
          .read(productVariantsProvider(widget.idProduct).notifier)
          .getVariants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productVariantsState =
        ref.watch(productVariantsProvider(widget.idProduct));
    final productVariantsSelection = ref.watch(printSelectionProvider);

    if (productVariantsState.isLoading) {
      return const FullScreenLoader();
    }

    final productVariants = productVariantsState.productVariants ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Etiquetas: ${widget.name}'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleccionar para imprimir:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _ProductVariantCard extends ConsumerWidget {
  final ProductVariant producVariant;
  final ProductVariantSelection? producVariantSelection;

  const _ProductVariantCard(
      {required this.producVariant, required this.producVariantSelection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = producVariantSelection == null ? false : true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blueGrey, width: 1)),
      child: Slidable(
        key: ValueKey(producVariant.idColor *
            producVariant.idTalla *
            producVariant.idProducto), // Clave única por item
        child: ListTile(
          leading: SizedBox(
            width: 15,
            child: Transform.scale(
              scale:
                  1.75, // aumenta o reduce el tamaño (1.0 es el tamaño por defecto)
              child: Checkbox(
                value: isSelected,
                onChanged: (_) {
                  ref.read(printSelectionProvider.notifier).toggleSelection(
                      producVariant.idProducto,
                      producVariant.idProductoVariante!);
                },
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (producVariant.codigoProductoVariante != null) ...[
                Row(
                  children: [
                    const Text('Codigo: '),
                    Text(producVariant.codigoProductoVariante!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        color: producVariant.color!.color.computeLuminance() <
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
            ],
          ),
          trailing: SizedBox(
            width: 40,
            child: TextFormField(
              textAlign: TextAlign.center,
              enabled: isSelected,
              initialValue: (isSelected ? producVariantSelection!.cantidad : 1)
                  .toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16)),
              onChanged: (val) {
                final cantidad = int.tryParse(val) ?? 1;
                ref.read(printSelectionProvider.notifier).updateCantidad(
                    producVariant.idProductoVariante!, cantidad);
              },
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
