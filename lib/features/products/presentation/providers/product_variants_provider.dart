import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
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
  final int idProduct;

  ProductsNotifier({
    required this.productRepository,
    required this.idProduct,
  }) : super(ProductsState()) {
    //getVariantsGroup(idProduct);
  }

  Future<void> getVariantsGroup() async {
    try {
      state = state.copyWith(isLoading: true);
      List<ProductVariantSize> productVariantsSize =
          await productRepository.getVariantsGroup(idProduct);

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

  Future<void> getVariants() async {
    try {
      state = state.copyWith(isLoading: true);
      List<ProductVariant> productVariants =
          await productRepository.getVariants(idProduct);

      state = state.copyWith(
        isLoading: false,
        productVariants: productVariants,
      );
    } catch (e) {
      // 404 product not found
      state = state.copyWith(isLoading: false);
      print(e);
    }
  }

  // Future<void> addVariant(ProductVariant productoVariante) async {
  //   try {
  //     state = state.copyWith(isLoading: true);

  //     List<ProductVariantSize> productVariantsSize =
  //         await productRepository.getVariantsGroup(1);

  //     state = state.copyWith(
  //       isLoading: false,
  //       productVariantsSize: productVariantsSize,
  //     );
  //   } catch (e) {
  //     // 404 product not found
  //     state = state.copyWith(isLoading: false);
  //     print(e);
  //   }
  // }

  Future<void> saveVariants(List<ProductVariant> productoVariante) async {
    try {
      state = state.copyWith(isSaving: true);

      final save = {
        'variantes': productoVariante.map((e) => e.toJson()).toList()
      };
      bool saveVariants = await productRepository.saveVariants(save);

      state = state.copyWith(isSaving: false, success: true);
    } catch (e) {
      // 404 product not found
      state = state.copyWith(
          isSaving: false,
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
  final List<ProductVariantSize>? productVariantsSize;
  final List<ProductVariant>? productVariants;
  final bool hasError;
  final String? errorMessage;
  final bool success;

  ProductsState(
      {this.isLoading = true,
      this.isSaving = false,
      this.productVariantsSize,
      this.productVariants,
      this.hasError = false,
      this.success = false,
      this.errorMessage});

  ProductsState copyWith(
          {bool? isLoading,
          bool? isSaving,
          List<ProductVariantSize>? productVariantsSize,
          List<ProductVariant>? productVariants,
          bool? hasError,
          String? errorMessage,
          bool? success}) =>
      ProductsState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          productVariantsSize: productVariantsSize ?? this.productVariantsSize,
          productVariants: productVariants ?? this.productVariants,
          hasError: hasError ?? this.hasError,
          errorMessage: errorMessage ?? this.errorMessage,
          success: success ?? this.success);
}
