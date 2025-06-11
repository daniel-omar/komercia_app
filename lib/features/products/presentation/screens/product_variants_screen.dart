import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/presentation/providers/product_variants_provider.dart';

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
  late int idProduct = widget.idProduct;
  late String nameProduct = widget.nameProduct;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .watch(productVariantsProvider(widget.idProduct).notifier)
          .getVariantsGroup();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productVariantsState = ref.watch(productVariantsProvider(idProduct));

    return Scaffold(
      appBar: AppBar(
        title: Text(nameProduct),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: productVariantsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _VariantsList(variantes: productVariantsState.productVariantsSize!),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(
            'productoVariantesSave',
            pathParameters: {'id_product': idProduct.toString()},
            extra: {'name': nameProduct},
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Variantes'),
      ),
    );
  }
}

class _VariantsList extends StatelessWidget {
  final List<ProductVariantSize> variantes;

  const _VariantsList({required this.variantes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 5),
      itemCount: variantes.length,
      itemBuilder: (_, i) {
        final talla = variantes[i];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la talla
                Text(
                  'Talla: ${talla.nombreTalla}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      fontSize: 25),
                ),
                const SizedBox(height: 5),
                // Lista de colores
                Column(
                  children: talla.detalles.map((detalle) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        children: [
                          Text(detalle.codigoProductoVariante ?? ""),
                          Text(detalle.nombreColor)
                        ],
                      ),
                      trailing: Text(
                        '${detalle.cantidad} unidades',
                        style: TextStyle(
                            color: detalle.cantidad == 0
                                ? Colors.red
                                : Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: detalle.color,
                          border: Border.all(
                            color: Colors.deepPurple, // Color del borde
                            width: 2, // Grosor del borde
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.color_lens, color: detalle.color),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
