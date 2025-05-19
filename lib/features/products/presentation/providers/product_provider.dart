import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/presentation/providers/product_repository_provider.dart';

final productProvider =
    StateNotifierProvider.family<ProductNotifier, ProductState, int>(
        (ref, idProduct) {
  final productRepository = ref.watch(productRepositoryProvider);

  return ProductNotifier(
      productRepository: productRepository, idProduct: idProduct);
});

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository productRepository;

  ProductNotifier({required this.productRepository, required int idProduct})
      : super(ProductState()) {
    findProduct(idProduct);
  }

  Future<Product?> findProduct(int idProducto) async {
    try {
      state = ProductState(isLoading: true);

      Product product = await productRepository.find(idProducto: idProducto);

      state = state.copyWith(
          isLoading: false, producto: product, idProducto: product.idProducto);

      return product;
    } catch (e) {
      // 404 product not found
      state = state.copyWith(isLoading: false);
      print(e);
      return null;
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    try {
      state = state.copyWith(isSaving: true);

      // await productRepository.update(updatedProduct);

      // Actualizar el producto local
      state = state.copyWith(
        isSaving: false,
        producto: updatedProduct,
      );
    } catch (e) {
      print("Error al actualizar producto: $e");
      state = state.copyWith(isSaving: false);
    }
  }
}

class ProductState {
  final int idProducto;
  final Product? producto;
  final bool isLoading;
  final bool isSaving;

  ProductState(
      {this.idProducto = 0,
      this.producto,
      this.isLoading = true,
      this.isSaving = false});

  ProductState copyWith({
    int? idProducto,
    Product? producto,
    bool? isLoading,
    bool? isSaving,
  }) =>
      ProductState(
        idProducto: idProducto ?? this.idProducto,
        producto: producto ?? this.producto,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}
