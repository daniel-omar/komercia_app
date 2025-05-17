import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/presentation/providers/product_repository_provider.dart';

final productsProvider = StateNotifierProvider.autoDispose
    .family<ProductsNotifier, ProductsState, int>((ref, idProductCategory) {
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

      List<Product> products = await productRepository
          .getByFilters(idsCategoriaProducto: [idProductCategory]);

      state = state.copyWith(
        isLoading: false,
        products: products,
      );
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

  ProductsState({
    this.isLoading = true,
    this.isSaving = false,
    this.products,
  });

  ProductsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<Product>? products,
  }) =>
      ProductsState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        products: products ?? this.products,
      );
}
