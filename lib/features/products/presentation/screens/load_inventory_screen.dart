import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/entities/product.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/products_inventory_provider.dart';
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

  Future<Product?> findProduct(
      String codigoProducto, BuildContext context) async {
    try {
      final product =
          await ref.read(productProvider.notifier).findProduct(codigoProducto);
      if (!mounted) {
        return null;
      }
      return product;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void addProduct() async {
    if (codigoProducto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final product = await findProduct(codigoProducto!, context);

    if (product == null) {
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
        .agregarProducto(product.idProducto, 1, 1, 1);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(productsInventoryProvider);

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
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  return ListTile(
                    title: const Text(""),
                    trailing: Text(item.cantidad.toString()),
                    leading: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref
                            .read(productsInventoryProvider.notifier)
                            .eliminarProducto(1, 1, 1);
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: inventory.isEmpty
                  ? null
                  : () {
                      // Aquí envías la lista completa al backend para cargar inventario
                      // Ejemplo: enviarInventario(inventory);
                    },
              child: const Text('Guardar Inventario'),
            ),
          ],
        ),
      ),
    );
  }
}
