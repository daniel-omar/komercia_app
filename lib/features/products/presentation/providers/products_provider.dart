import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/presentation/providers/product_repository_provider.dart';

final productsProvider =
    StateNotifierProvider.family<ProductsNotifier, ProductsState, int>(
        (ref, idProductCategory) {
  final productRepository = ref.watch(productRepositoryProvider);

  return ProductsNotifier(
      productRepository: productRepository,
      idProductCategory: idProductCategory);
});

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository productRepository;

  ProductsNotifier({
    required this.productRepository,
    required int idProductCategory,
  }) : super(ProductsState()) {
    getByIdCategory(idProductCategory);
  }

  Future<void> getByIdCategory(int idProductCategory) async {
    try {
      state = state.copyWith(isLoading: true);
      List<int> idsCategoriaProducto = [];
      if (idProductCategory > 0) idsCategoriaProducto = [idProductCategory];
      List<Product> products = await productRepository.getByFilters(
          idsCategoriaProducto: idsCategoriaProducto);

      double purcharsePriceTotal = products.fold<double>(
        0,
        (sum, item) => sum + (item.precioCompra ?? 0),
      );
      double salePriceTotal = products.fold<double>(
        0,
        (sum, item) => sum + (item.precioCompra ?? 0),
      );

      state = state.copyWith(
          isLoading: false,
          products: products,
          purcharsePriceTotal: purcharsePriceTotal,
          salePriceTotal: salePriceTotal);
    } catch (e) {
      // 404 product not found
      state = state.copyWith(isLoading: false);
      print(e);
    }
  }
}

class ProductsState {
  final bool isLoading;
  final bool isSaving;
  final List<Product>? products;
  final double? purcharsePriceTotal;
  final double? salePriceTotal;

  ProductsState({
    this.isLoading = true,
    this.isSaving = false,
    this.products,
    this.purcharsePriceTotal = 0,
    this.salePriceTotal = 0,
  });

  ProductsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<Product>? products,
    double? purcharsePriceTotal,
    double? salePriceTotal,
  }) =>
      ProductsState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        products: products ?? this.products,
        purcharsePriceTotal: purcharsePriceTotal ?? this.purcharsePriceTotal,
        salePriceTotal: salePriceTotal ?? this.salePriceTotal,
      );
}
