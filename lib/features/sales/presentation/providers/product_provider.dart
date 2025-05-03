import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/providers.dart';

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);

  return ProductNotifier(productRepository: productRepository);
});

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository productRepository;

  ProductNotifier({
    required this.productRepository,
  }) : super(ProductState());

  void getProduct() async {
    try {
      state = state.copyWith(isLoading: true);

      Product product = await productRepository.getById(state.idProducto!);

      state = state.copyWith(
          isLoading: false, producto: product, idProducto: product.idProducto);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }

  Future<Product?> findProduct(String codigoProducto) async {
    try {
      state = state.copyWith(isLoading: true);

      Product product =
          await productRepository.find(codigoProducto: codigoProducto);

      state = state.copyWith(
          isLoading: false, producto: product, idProducto: product.idProducto);

      return product;
    } catch (e) {
      // 404 product not found
      print(e);
      return null;
    }
  }

  void onProductChanged(int idProduct) {
    state = state.copyWith(idProducto: idProduct);
    getProduct();
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
