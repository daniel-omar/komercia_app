import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final products = [
      {'name': 'Ff', 'price': 15.0, 'stock': -37},
      {'name': 'Gf', 'price': 444.0, 'stock': 1},
    ];

    return !productCategoriesState.isLoading
        ? Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SummaryCard(title: 'Total de referencias', value: '2'),
                      // _SummaryCard(title: 'Costo total', value: 'S/ 5'),
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
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductCard(
                          name: product['name'] as String,
                          price: product['price'] as double,
                          stock: product['stock'] as int,
                        );
                      },
                    ),
                  ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

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
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _CategoryChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        label: Text(label),
        backgroundColor: selected ? Colors.yellow[700] : Colors.grey[200],
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final int stock;

  const _ProductCard(
      {required this.name, required this.price, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        subtitle: Text('S/ $price'),
        trailing: Text(
          '$stock disponibles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: stock < 0 ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }
}
