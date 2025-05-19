import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/home/presentation/providers/menu_provider.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/presentation/providers/product_categories_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/products_provider.dart';
import 'package:komercia_app/features/shared/widgets/full_screen_loader.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(productCategoriesProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productCategoriesState = ref.watch(productCategoriesProvider);
    final selectedCategory = productCategoriesState.productCategorySelect;
    if (selectedCategory == null) {
      return const FullScreenLoader(); // o un Container si prefieres algo vacío
    }
    final selectedId = selectedCategory.idCategoria;
    final productsState = ref.watch(productsProvider(selectedId));
    final products = productsState.products ?? [];

    return !productCategoriesState.isLoading
        ? Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!productsState.isLoading) ...[
                        _SummaryCard(
                            title: 'Total de referencias',
                            value: (productsState.products!.length.toString())),
                        _SummaryCard(
                            title: 'Costo total',
                            value:
                                'S/ ${productsState.purcharsePriceTotal!.toString()}'),
                      ]
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _ProductCategorySelector(), // Ocupa todo el espacio disponible
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!productsState.isLoading)
                    _ProductList(products: products),
                ],
              ),
            ),
          )
        : const FullScreenLoader();
  }
}

class _ProductCategorySelector extends ConsumerStatefulWidget {
  @override
  _ProductCategorySelectorState createState() =>
      _ProductCategorySelectorState();
}

class _ProductCategorySelectorState
    extends ConsumerState<_ProductCategorySelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToEnd();
    // });
  }

  // void _scrollToEnd() {
  //   if (_scrollController.hasClients) {
  //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose(); // Limpieza del controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productCategoriesState = ref.watch(productCategoriesProvider);

    // ref.listen<ProductCategorysState>(productCategoriesProvider,
    //     (previous, next) {
    //   if (next.productCategorySelect!.idCategoria !=
    //       previous?.productCategorySelect!.idCategoria) {
    //     ref.read(productsProvider(next.productCategorySelect!.idCategoria));
    //   }
    // });

    return SizedBox(
      height: 45,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: productCategoriesState.productCategories!.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final productCategory =
              productCategoriesState.productCategories![index];
          final isSelected = productCategory.idCategoria ==
              productCategoriesState
                  .productCategorySelect!.idCategoria; // ejemplo
          return ChoiceChip(
            label: Text(productCategory.nombreCategoria),
            selected: isSelected,
            onSelected: (_) {
              // actualizar estado
              ref
                  .read(productCategoriesProvider.notifier)
                  .setCategorySelected(productCategory);
              ref.watch(productsProvider(productCategory.idCategoria));
            },
            selectedColor: Colors.yellow.shade700,
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 105,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  List<Product> products = [];
  _ProductList({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // aquí irían tus ventas

    if (products.isEmpty) {
      return const Expanded(
        child: Column(
          children: [
            Icon(
              Icons.image_search_rounded,
              size: 100,
            ),
            SizedBox(height: 12),
            Text('No tienes registros creados en esta fecha.')
          ],
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final product = products[i];
          return _ProductCard(
            idProduct: product.idProducto,
            name: product.nombreProducto,
            salePrice: product.precioVenta ?? 0,
            purcharsePrice: product.precioCompra ?? 0,
            stock: product.cantidadDisponible ?? 0,
          );
        },
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final int idProduct;
  final String name;
  final double salePrice;
  final double purcharsePrice;
  final int stock;

  const _ProductCard(
      {required this.name,
      required this.salePrice,
      required this.purcharsePrice,
      required this.stock,
      required this.idProduct});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blueGrey, width: 1)),
      child: Slidable(
        key: ValueKey(idProduct), // Clave única por item
        endActionPane: ref
                .read(menusProvider.notifier)
                .tienePermisoEdicion("/products", "Modificar")
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      context.push("/product/$idProduct");
                    },
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Editar',
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              )
            : null,
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.toll, color: Colors.purple),
          ),
          title: Text(name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Compra: '),
                  Text('S/$purcharsePrice',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Text('Venta: '),
                  Text(
                    'S/$salePrice',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$stock',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: stock < 0 ? Colors.red : Colors.black,
                    fontSize: 12),
              ),
              Text(
                'Disponibles',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: stock < 0 ? Colors.red : Colors.black,
                    fontSize: 12),
              )
            ],
          ),
          onTap: () {
            context.pushNamed(
              'productoVariantes',
              pathParameters: {'id_product': idProduct.toString()},
              extra: {'name': name},
            );
          },
        ),
      ),
    );
  }
}
