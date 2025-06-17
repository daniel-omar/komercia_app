import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/domain/entities/product_variant.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_repository_provider.dart';

final productVariantProvider = StateNotifierProvider.autoDispose<
    ProductVariantNotifier, ProductVariantState>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);

  return ProductVariantNotifier(productRepository: productRepository);
});

class ProductVariantNotifier extends StateNotifier<ProductVariantState> {
  final ProductRepository productRepository;

  ProductVariantNotifier({
    required this.productRepository,
  }) : super(ProductVariantState());

  Future<ProductVariant?> findProductVariant(
      String codigoProductoVariante) async {
    try {
      // state = state.copyWith(isLoading: true, success: false, hasError: false);

      ProductVariant productVariant =
          await productRepository.findProductVariant(
              codigoProductoVariante: codigoProductoVariante,
              tieneCantidad: true,
              esActivo: true);

      // state = state.copyWith(
      //     isLoading: false,
      //     success: true,
      //     productVariant: productVariant,
      //     idProductVariant: productVariant.idProductoVariante);
      return productVariant;
    } catch (e) {
      // 404 product not found
      // state = state.copyWith(
      //     isLoading: false, hasError: true, errorMessage: e.toString());
      print(e);
      return null;
    }
  }
}

class ProductVariantState {
  final bool isLoading;
  final bool isSaving;
  final int idProductVariant;
  final ProductVariant? productVariant;
  final bool hasError;
  final String? errorMessage;
  final bool success;

  ProductVariantState(
      {this.isLoading = true,
      this.isSaving = false,
      this.idProductVariant = 0,
      this.productVariant,
      this.hasError = false,
      this.success = false,
      this.errorMessage});

  ProductVariantState copyWith(
          {bool? isLoading,
          bool? isSaving,
          int? idProductVariant,
          ProductVariant? productVariant,
          bool? hasError,
          String? errorMessage,
          bool? success}) =>
      ProductVariantState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          idProductVariant: idProductVariant ?? this.idProductVariant,
          productVariant: productVariant ?? this.productVariant,
          hasError: hasError ?? this.hasError,
          errorMessage: errorMessage ?? this.errorMessage,
          success: success ?? this.success);
}
