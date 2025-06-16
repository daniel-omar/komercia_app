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
  String? codigoProducto;

  void onScanner() async {
    codigoProducto = await readScanner(context);
    if (!mounted || codigoProducto == null) return;
    _codigoController.text = codigoProducto!;
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
    if (codigoProducto == null) {
      _codigoController.text = "";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final productVariant = await findProductVariant(codigoProducto!, context);

    if (productVariant == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Producto no se encuentra en inventario.')),
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

    ref
        .read(productVariantsProvider(0).notifier)
        .saveVariants(productsVariants);
  }

  @override
  Widget build(BuildContext context) {
    final productsVariants = ref.watch(productsInventoryProvider);

    ref.listen<ProductVariantsState>(
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

                  return _ProductVariantCard(
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
              child: const Text('Guardar Inventario'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductVariantCard extends ConsumerWidget {
  final ProductVariant producVariant;

  const _ProductVariantCard({required this.producVariant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            width: 30,
            child: Transform.scale(
              scale:
                  1.5, // aumenta o reduce el tamaño (1.0 es el tamaño por defecto)
              child: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 0, vertical: 0),
                onPressed: () {
                  ref
                      .read(productsInventoryProvider.notifier)
                      .removeProductVariant(producVariant.idProductoVariante!);
                },
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Producto: '),
                  Text(producVariant.nombreProducto ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Text('Codigo: '),
                  Text(producVariant.codigoProductoVariante ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
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
            width: 25,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                producVariant.cantidad.toString(),
                key: ValueKey(producVariant.cantidad), // MUY importante
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
