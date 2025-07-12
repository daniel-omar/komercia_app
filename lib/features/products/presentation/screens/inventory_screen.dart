import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/home/presentation/providers/menu_provider.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/presentation/providers/products_variants_selection_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/product_categories_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/product_variants_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/products_inventory_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/products_provider.dart';
import 'package:komercia_app/features/products/presentation/providers/upload_products_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sale_submission_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sales_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/full_screen_loader.dart';

import 'package:permission_handler/permission_handler.dart';

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

  Future<bool> requestPermission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      return re.isGranted;
    } else {
      if (await permission.isGranted) return true;
      var result = await permission.request();
      return result.isGranted;
    }
  }

  void uploadFileProducts() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result == null || result.files.single.path == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe seleccionar un archivo para cargar.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      // ignore: use_build_context_synchronously
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

    final file = File(result.files.single.path!);
    ref.read(uploadProductsProvider.notifier).uploadExcel(file);
  }

  void downloadFile() async {
    final status = await requestPermission(Permission.storage);
    if (!status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No cuenta con permiso para descargar recurso.')),
      );
      return;
    }
    ref.read(uploadProductsProvider.notifier).downloadExcel();
  }

  void onSelectProduct(int idProducto) async {
    final result = await context.push("/product/$idProducto");
    if (result == true) {
      // ignore: unused_result
      ref.refresh(productsProvider(0));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Producto actualizado con éxito.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3), // Duración del SnackBar
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  void onSelectProductVariants(int idProducto, String nombre) async {
    final result = await context.pushNamed(
      'productoVariantes',
      pathParameters: {'id_product': idProducto.toString()},
      extra: {'name': nombre},
    );
    if (result == true) {
      // ignore: unused_result
      ref.refresh(productsProvider(0));
      // ignore: unused_result
      ref.refresh(productVariantsProvider(idProducto));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Guardado con éxito'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3), // Duración del SnackBar
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  bool _isSelectionMode = false;
  bool _isActive = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onViewproductsVariantSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      isScrollControlled: true,
      builder: (_) => const ViewProductsVariantSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productCategoriesState = ref.watch(productCategoriesProvider);
    final selectedCategory = productCategoriesState.productCategorySelect;
    if (selectedCategory == null) {
      return const FullScreenLoader(); // o un Container si prefieres algo vacío
    }
    final selectedCategoryId = selectedCategory.idCategoria;
    final productsState = ref.watch(productsProvider(selectedCategoryId));
    final products = productsState.products ?? [];
    final filteredProducts = products.where((product) {
      if (_searchQuery.isEmpty) return true;
      return product.nombreProducto.toLowerCase().contains(_searchQuery);
    }).toList();
    final purcharsePriceTotal = productsState.purcharsePriceTotal ?? 0;

    final productVariantsSelection =
        ref.watch(productsVariantSelectionProvider);
    final selectedCount = productVariantsSelection.length;

    ref.listen<ProductsState>(
      productsProvider(selectedCategoryId),
      (previous, next) {
        if (!mounted) return;
        if (next.success) {
        } else if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar')),
          );
        }
      },
    );

    ref.listen<UploadProductState>(
      uploadProductsProvider,
      (previous, next) {
        if (!mounted) return;
        if (next.success) {
          // Navigator.pop(context); // bottomsheet
          // ignore: unused_result
          ref.refresh(productsProvider(selectedCategoryId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Productos registrados'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3), // Duración del SnackBar
                behavior: SnackBarBehavior.floating),
          );
        } else if (next.errorMessage != '') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage)),
          );
        }
      },
    );

    ref.listen<SaleSubmissionState>(saleSubmissionProvider, (previous, next) {
      if (!next.isSaving && next.success) {
        // ignore: unused_result
        ref.refresh(productsProvider(selectedCategoryId));
      }
    });

    final uploadProductsState = ref.watch(uploadProductsProvider);

    return !productCategoriesState.isLoading
        ? Scaffold(
            // appBar: AppBar(
            //   actions: [
            //     // const SizedBox(width: 20),
            //     // ElevatedButton.icon(
            //     //   icon: const Icon(Icons.save),
            //     //   label: const Text(
            //     //     'Inventariar',
            //     //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            //     //   ),
            //     //   onPressed: () async {
            //     //     final result = await context.push("/load_inventory");
            //     //     if (result == true) {
            //     //       ref.read(productsInventoryProvider.notifier).clear();
            //     //       // ignore: unused_result
            //     //       ref.refresh(productsProvider(selectedId));
            //     //       // ignore: unused_result
            //     //       ref.refresh(productVariantsProvider(0));

            //     //       // ignore: use_build_context_synchronously
            //     //       ScaffoldMessenger.of(context).showSnackBar(
            //     //         const SnackBar(
            //     //             content: Text('Guardado con éxito'),
            //     //             backgroundColor: Colors.green,
            //     //             duration:
            //     //                 Duration(seconds: 3), // Duración del SnackBar
            //     //             behavior: SnackBarBehavior.floating),
            //     //       );
            //     //     }
            //     //   },
            //     //   style:
            //     //       ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            //     // ),
            //     const Spacer(),
            //     IconButton(
            //       icon: Icon(
            //         _isSelectionMode ? Icons.close : Icons.print,
            //         size: 30,
            //       ),
            //       onPressed: () {
            //         setState(() {
            //           _isSelectionMode = !_isSelectionMode;
            //           if (!_isSelectionMode) {
            //             // Limpiar selección cuando salgas del modo selección
            //             ref
            //                 .read(productsVariantSelectionProvider.notifier)
            //                 .clear();
            //           }
            //         });
            //       },
            //     ),
            //     const SizedBox(width: 20),
            //   ],
            // ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // <-- Desenfoca el TextField
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal, // Establece la dirección horizontal
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryCard(
                              title: 'Productos',
                              value: (products.length.toString())),
                          const SizedBox(
                            width: 10,
                          ),
                          _SummaryCard(
                              title: 'Productos disponibles',
                              value: (products
                                  .fold(
                                      0,
                                      (previousValue, producto) =>
                                          previousValue +
                                          (producto.cantidadDisponible ?? 0))
                                  .toString())),
                          const SizedBox(
                            width: 10,
                          ),
                          if (ref
                              .read(menusProvider.notifier)
                              .tienePermisoEdicion(
                                  "/products", "Modificar")) ...[
                            _SummaryCard(
                                title: 'Costo total',
                                value: 'S/ ${purcharsePriceTotal.toString()}'),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Row(children: [
                            ChoiceChip(
                              label: const Text("Activos"),
                              selected: _isActive,
                              onSelected: (_) {
                                setState(() {
                                  _isActive = !_isActive;
                                });
                                ref
                                    .read(productsProvider(selectedCategoryId)
                                        .notifier)
                                    .updateActive(_isActive);
                                ref
                                    .watch(productsProvider(selectedCategoryId)
                                        .notifier)
                                    .getByFilters(selectedCategoryId);
                              },
                              selectedColor: Colors.green.shade300,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            ChoiceChip(
                              label: const Text("Inactivos"),
                              selected: !_isActive,
                              onSelected: (_) {
                                setState(() {
                                  _isActive = !_isActive;
                                });
                                ref
                                    .read(productsProvider(selectedCategoryId)
                                        .notifier)
                                    .updateActive(_isActive);
                                ref
                                    .watch(productsProvider(selectedCategoryId)
                                        .notifier)
                                    .getByFilters(selectedCategoryId);
                              },
                              selectedColor: Colors.red.shade300,
                            )
                          ]), // Ocupa todo el espacio disponible
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child:
                              _ProductCategorySelector(), // Ocupa todo el espacio disponible
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.5),
                          child: SizedBox(
                            width: 290,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase().trim();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Buscar producto por nombre...',
                                prefixIcon: const Icon(Icons.search),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 35,
                                  minHeight: 30,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = "";
                                          });
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (ref
                            .read(menusProvider.notifier)
                            .tienePermisoEdicion("/products", "Modificar")) ...[
                          IconButton(
                            icon: Icon(
                              _isSelectionMode ? Icons.close : Icons.print,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = !_isSelectionMode;
                                if (!_isSelectionMode) {
                                  // Limpiar selección cuando salgas del modo selección
                                  ref
                                      .read(productsVariantSelectionProvider
                                          .notifier)
                                      .clear();
                                }
                              });
                            },
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (!productsState.isLoading)
                      _ProductList(
                          products: filteredProducts,
                          isSelectionMode: _isSelectionMode,
                          onSelectProduct: onSelectProduct,
                          onSelectProductVariants: onSelectProductVariants),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _isSelectionMode
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (selectedCount > 0) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 5),
                          ),
                          icon: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 5),
                            decoration: const BoxDecoration(
                              color: Colors.white, // Fondo del icono
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.upload_file,
                              color: Colors.green, // Color del ícono
                              size: 25,
                            ),
                          ),
                          label: Text(
                            'Generar etiquetas ($selectedCount)',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          onPressed: productsState.isLoading
                              ? null
                              : () async {
                                  // Lógica para imprimir
                                  List<ProductVariant> productsVariants = [];
                                  for (var i = 0;
                                      i < productVariantsSelection.length;
                                      i++) {
                                    final productVariantSelection =
                                        productVariantsSelection[i];
                                    productsVariants.add(ProductVariant(
                                        idProducto:
                                            productVariantSelection.idProducto,
                                        idProductoVariante:
                                            productVariantSelection
                                                .idProductoVariante,
                                        idTalla: 0,
                                        idColor: 0,
                                        cantidad:
                                            productVariantSelection.cantidad));
                                  }

                                  await ref
                                      .read(productsProvider(selectedCategoryId)
                                          .notifier)
                                      .downloadTags(productsVariants);

                                  await ref
                                      .read(productsProvider(selectedCategoryId)
                                          .notifier)
                                      .getByFilters(selectedCategoryId);

                                  setState(
                                    () {
                                      _isSelectionMode = !_isSelectionMode;
                                      if (!_isSelectionMode) {
                                        // Limpiar selección cuando salgas del modo selección
                                        ref
                                            .read(
                                                productsVariantSelectionProvider
                                                    .notifier)
                                            .clear();
                                      }
                                    },
                                  );
                                },
                        ),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 5),
                            ),
                            icon: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 5),
                              decoration: const BoxDecoration(
                                color: Colors.white, // Fondo del icono
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.view_agenda,
                                color: Colors.green, // Color del ícono
                                size: 25,
                              ),
                            ),
                            label: const Text('Ver seleccionados',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            onPressed: () {
                              onViewproductsVariantSelection();
                            }),
                      ]
                    ],
                  )
                : (ref
                        .read(menusProvider.notifier)
                        .tienePermisoEdicion("/products", "Modificar")
                    ? Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              decoration: const BoxDecoration(
                                color: Colors.green, // Fondo del icono
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.download,
                                color: Colors.white, // Color del ícono
                                size: 30,
                              ),
                            ),
                            onPressed: () {
                              downloadFile();
                            },
                          ),
                          ElevatedButton.icon(
                            onPressed: uploadProductsState.isLoading
                                ? null
                                : () {
                                    uploadFileProducts();
                                  },
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white, // Fondo del icono
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.upload_file,
                                color: Colors.green, // Color del ícono
                                size: 20,
                              ),
                            ),
                            label: const Text(
                              'Cargar productos',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5)),
                            child: const Text(
                              'Crear producto',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          )
                        ],
                      )
                    : null),
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
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: productCategoriesState.productCategories!.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
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
      width: 120,
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
  final bool isSelectionMode;
  final void Function(int idProduct) onSelectProduct;
  final void Function(int idProduct, String name) onSelectProductVariants;

  _ProductList(
      {required this.products,
      required this.isSelectionMode,
      required this.onSelectProduct,
      required this.onSelectProductVariants});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // aquí irían tus ventas

    if (products.isEmpty) {
      return const Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(
                Icons.image_search_rounded,
                size: 100,
              ),
              SizedBox(height: 12),
              Text('No tienes registros creados.')
            ],
          ),
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
              isSelectionMode: isSelectionMode,
              isActive: product.esActivo ?? false,
              idCategory: 0,
              onSelectProduct: onSelectProduct,
              onSelectProductVariants: onSelectProductVariants);
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
  final bool isSelectionMode;
  final bool isActive;
  final int idCategory;
  final void Function(int idProduct) onSelectProduct;
  final void Function(int idProduct, String name) onSelectProductVariants;

  const _ProductCard(
      {required this.name,
      required this.salePrice,
      required this.purcharsePrice,
      required this.stock,
      required this.idProduct,
      required this.isSelectionMode,
      required this.isActive,
      required this.idCategory,
      required this.onSelectProduct,
      required this.onSelectProductVariants});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionProvider = ref.watch(productsVariantSelectionProvider);
    final selecteds = selectionProvider.where((s) => s.idProducto == idProduct);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isSelectionMode && selecteds.isNotEmpty
                  ? Colors.green
                  : Colors.blueGrey,
              width: isSelectionMode && selecteds.isNotEmpty ? 2 : 1)),
      elevation: isSelectionMode && selecteds.isNotEmpty ? 4 : 1,
      child: Slidable(
        key: ValueKey(idProduct), // Clave única por item
        endActionPane: ref
                .read(menusProvider.notifier)
                .tienePermisoEdicion("/products", "Modificar")
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => onSelectProduct(idProduct),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          leading: Container(
            width: 25,
            height: 48,
            decoration: BoxDecoration(
              // color: Colors.purple[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: isSelectionMode
                ? Icon(
                    Icons.print,
                    color: isSelectionMode && selecteds.isNotEmpty
                        ? Colors.green
                        : Colors.blueGrey,
                    size: 35,
                  )
                : Icon(
                    Icons.toll,
                    color: isActive ? Colors.green : Colors.red,
                    size: 35,
                  ),
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
              if (isSelectionMode) ...[
                Row(
                  children: [
                    const Text('Cantidad actual: '),
                    Text(
                      stock.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: stock < 0 ? Colors.red : Colors.black,
                          fontSize: 16),
                    ),
                  ],
                ),
              ]
            ],
          ),
          trailing: SizedBox(
            width: 85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSelectionMode ? '${selecteds.length}' : '$stock',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: stock < 0 ? Colors.red : Colors.black,
                      fontSize: 12),
                ),
                if (isSelectionMode) ...[
                  const Text(
                    'Items seleccionados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 12),
                  )
                ] else ...[
                  Text(
                    'Disponibles',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: stock < 0 ? Colors.red : Colors.black,
                        fontSize: 12),
                  )
                ],
              ],
            ),
          ),
          onTap: () async {
            if (isSelectionMode) {
              context.pushNamed(
                'productoVariantesPrint',
                pathParameters: {'id_product': idProduct.toString()},
                extra: {'name': name},
              );
            } else {
              onSelectProductVariants(idProduct, name);
            }
          },
        ),
      ),
    );
  }
}

class ViewProductsVariantSelectionSheet extends ConsumerStatefulWidget {
  const ViewProductsVariantSelectionSheet({super.key});

  @override
  ConsumerState<ViewProductsVariantSelectionSheet> createState() =>
      _ViewProductsVariantSelectionSheetState();
}

class _ViewProductsVariantSelectionSheetState
    extends ConsumerState<ViewProductsVariantSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    final productVariantsSelection =
        ref.watch(productsVariantSelectionProvider);
    final heightList = MediaQuery.of(context).size.height * 0.6;

    return FractionallySizedBox(
      heightFactor: 0.7,
      widthFactor: 1.0,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              10, // <-- clave para mover con teclado
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                IconButton(
                  icon: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    decoration: const BoxDecoration(
                      color: Colors.red, // Fondo del icono
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white, // Color del ícono
                      size: 25,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(
              height: heightList,
              child: ListView.builder(
                itemCount: productVariantsSelection.length,
                itemBuilder: (_, i) {
                  final producVariantSelection = productVariantsSelection[i];

                  return _ProductVariantCard(
                      producVariantSelection: producVariantSelection);
                },
              ),
            ),
            const SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }
}

class _ProductVariantCard extends ConsumerStatefulWidget {
  final ProductVariantSelection producVariantSelection;

  const _ProductVariantCard({super.key, required this.producVariantSelection});

  @override
  ConsumerState<_ProductVariantCard> createState() =>
      _ProductVariantCardState();
}

class _ProductVariantCardState extends ConsumerState<_ProductVariantCard> {
  late final TextEditingController quantityController;

  @override
  void initState() {
    quantityController = TextEditingController(
      text: widget.producVariantSelection.cantidad.toString(),
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
    final producVariantSelection = widget.producVariantSelection;
    final producVariant = producVariantSelection.productVariant;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blueGrey, width: 1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 3),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar',
              onPressed: () async {
                ref
                    .read(productsVariantSelectionProvider.notifier)
                    .remove(producVariantSelection.idProductoVariante);
              },
              color: Colors.white, // color del ícono
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                padding: WidgetStateProperty.all<EdgeInsets>(
                    const EdgeInsets.all(8)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            const SizedBox(width: 3),
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
                    Row(
                      children: [
                        const Text('Nombre: '),
                        SelectableText(
                          producVariant.nombreProducto!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          producVariant.talla!.codigoTalla,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Text(
                        "::",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: producVariant.color!.idColor !=
                                  colorsMap["Predeterminado"]!
                              ? producVariant.color!.color
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          producVariant.color!.codigoColor,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
                ],
              ),
            ),

            const SizedBox(width: 2),

            SizedBox(
              width: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    producVariantSelection.cantidad.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
