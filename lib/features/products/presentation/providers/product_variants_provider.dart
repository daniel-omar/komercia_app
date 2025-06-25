import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/presentation/providers/product_repository_provider.dart';

final productVariantsProvider = StateNotifierProvider.family
    .autoDispose<ProductsNotifier, ProductVariantsState, int>((ref, idProduct) {
  final productRepository = ref.watch(productRepositoryProvider);

  return ProductsNotifier(
      productRepository: productRepository, idProduct: idProduct);
});

class ProductsNotifier extends StateNotifier<ProductVariantsState> {
  final ProductRepository productRepository;
  final int idProduct;

  ProductsNotifier({
    required this.productRepository,
    required this.idProduct,
  }) : super(ProductVariantsState()) {
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
      state = state.copyWith(isSaving: true, success: false, hasError: false);

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

  Future<void> saveIncome(List<ProductVariant> productoVariante) async {
    try {
      state = state.copyWith(isSaving: true, success: false);

      final save = {
        'productos_variantes': productoVariante.map((e) => e.toJson()).toList()
      };
      bool saveIncome = await productRepository.saveIncome(save);

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

  Future<void> saveOutput(List<ProductVariant> productoVariante) async {
    try {
      state = state.copyWith(isSaving: true, success: false);

      final save = {
        'productos_variantes': productoVariante.map((e) => e.toJson()).toList()
      };
      bool saveOutput = await productRepository.saveOutput(save);

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

class ProductVariantsState {
  final bool isLoading;
  final bool isSaving;
  final List<ProductVariantSize>? productVariantsSize;
  final List<ProductVariant>? productVariants;
  final bool hasError;
  final String? errorMessage;
  final bool success;

  ProductVariantsState(
      {this.isLoading = true,
      this.isSaving = false,
      this.productVariantsSize,
      this.productVariants,
      this.hasError = false,
      this.success = false,
      this.errorMessage});

  ProductVariantsState copyWith(
          {bool? isLoading,
          bool? isSaving,
          List<ProductVariantSize>? productVariantsSize,
          List<ProductVariant>? productVariants,
          bool? hasError,
          String? errorMessage,
          bool? success}) =>
      ProductVariantsState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          productVariantsSize: productVariantsSize ?? this.productVariantsSize,
          productVariants: productVariants ?? this.productVariants,
          hasError: hasError ?? this.hasError,
          errorMessage: errorMessage ?? this.errorMessage,
          success: success ?? this.success);
}
