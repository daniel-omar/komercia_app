import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/presentation/providers/product_repository_provider.dart';

final productVariantsProvider = StateNotifierProvider.family
    .autoDispose<ProductsNotifier, ProductsState, int>((ref, idProduct) {
  final productRepository = ref.watch(productRepositoryProvider);

  return ProductsNotifier(
      productRepository: productRepository, idProduct: idProduct);
});

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository productRepository;

  ProductsNotifier({
    required this.productRepository,
    required int idProduct,
  }) : super(ProductsState()) {
    getVariants(idProduct);
  }

  Future<void> getVariants(int idProduct) async {
    try {
      state = state.copyWith(isLoading: true);
      List<ProductVariantSize> productVariantsSize =
          await productRepository.getVariants(idProduct);

      state = state.copyWith(
        isLoading: false,
        productVariantsSize: productVariantsSize,
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
  final List<ProductVariantSize>? productVariantsSize;

  ProductsState({
    this.isLoading = true,
    this.isSaving = false,
    this.productVariantsSize,
  });

  ProductsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ProductVariantSize>? productVariantsSize,
  }) =>
      ProductsState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        productVariantsSize: productVariantsSize ?? this.productVariantsSize,
      );
}
