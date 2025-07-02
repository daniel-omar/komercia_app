import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
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

  ProductsNotifier(
      {required this.productRepository, required int idProductCategory})
      : super(ProductsState()) {
    getByFilters(idProductCategory);
  }

  void updateActive(bool esActivo) {
    state = state.copyWith(esActivo: esActivo);
  }

  Future<void> getByFilters(int idProductCategory) async {
    try {
      state = state.copyWith(isLoading: true);
      List<int> idsCategoriaProducto = [];
      if (idProductCategory > 0) idsCategoriaProducto = [idProductCategory];
      List<Product> products = await productRepository.getByFilters(
          idsCategoriaProducto: idsCategoriaProducto, esActivo: state.esActivo);

      double purcharsePriceTotal = products.fold<double>(
        0,
        (sum, item) =>
            sum + (item.precioCompra ?? 0) * (item.cantidadDisponible ?? 0),
      );
      double salePriceTotal = products.fold<double>(
        0,
        (sum, item) =>
            sum + (item.precioVenta ?? 0) * (item.cantidadDisponible ?? 0),
      );

      state = state.copyWith(
          isLoading: false,
          products: products,
          purcharsePriceTotal: purcharsePriceTotal,
          salePriceTotal: salePriceTotal);
    } catch (e) {
      // 404 product not found
      state = state.copyWith(isLoading: false, products: []);
      print(e);
    }
  }

  Future<void> downloadTags(List<ProductVariant> productosVariantes) async {
    try {
      state = state.copyWith(isLoading: true, success: false, hasError: false);

      final productosVariantesJson = {
        'productos_variantes':
            productosVariantes.map((e) => e.toJson()).toList()
      };

      await productRepository.downloadTags(productosVariantesJson);

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      // 404 product not found
      state = state.copyWith(
          isLoading: false,
          success: false,
          hasError: true,
          errorMessage: e.toString());
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
  final bool hasError;
  final String? errorMessage;
  final bool success;
  final bool esActivo;

  ProductsState(
      {this.isLoading = true,
      this.isSaving = false,
      this.products,
      this.purcharsePriceTotal = 0,
      this.salePriceTotal = 0,
      this.hasError = false,
      this.success = false,
      this.errorMessage,
      this.esActivo = true});

  ProductsState copyWith(
          {bool? isLoading,
          bool? isSaving,
          List<Product>? products,
          double? purcharsePriceTotal,
          double? salePriceTotal,
          bool? hasError,
          String? errorMessage,
          bool? success,
          bool? esActivo}) =>
      ProductsState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          products: products ?? this.products,
          purcharsePriceTotal: purcharsePriceTotal ?? this.purcharsePriceTotal,
          salePriceTotal: salePriceTotal ?? this.salePriceTotal,
          hasError: hasError ?? this.hasError,
          errorMessage: errorMessage ?? this.errorMessage,
          success: success ?? this.success,
          esActivo: esActivo ?? this.esActivo);
}
