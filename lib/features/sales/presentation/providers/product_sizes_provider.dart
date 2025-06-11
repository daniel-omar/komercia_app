import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_size_repository_provider.dart';

final productSizesProvider = StateNotifierProvider.autoDispose<
    ProductSizesNotifier,
    ProductSizesState
    //int
    >((ref) {
  final productSizeRepository = ref.watch(productSizeRepositoryProvider);

  return ProductSizesNotifier(
    productSizeRepository: productSizeRepository,
    //idProductSize: idProductSize,
  );
});

class ProductSizesNotifier extends StateNotifier<ProductSizesState> {
  final ProductSizeRepository productSizeRepository;

  ProductSizesNotifier({
    required this.productSizeRepository,
    //required int? idProductSize,
  }) : super(ProductSizesState()) {
    // loadSizes();
  }

  Future<void> loadSizes() async {
    try {
      state = state.copyWith(isLoading: true);

      Map<String, dynamic> body = {};
      // body["es_seriado"] = true;

      final productSizes = await productSizeRepository.getAll();

      state = state.copyWith(isLoading: false, productSizes: productSizes);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // 404 product not found
      print(e);
    }
  }

  Future<void> loadSizesByProduct(int idProducto) async {
    try {
      state = state.copyWith(isLoading: true);

      final productSizes = await productSizeRepository.getByProduct(idProducto);

      state = state.copyWith(isLoading: false, productSizes: productSizes);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class ProductSizesState {
  final bool isLoading;
  final bool isSaving;
  final List<ProductSize>? productSizes;

  ProductSizesState({
    this.isLoading = true,
    this.isSaving = false,
    this.productSizes,
  });

  ProductSizesState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ProductSize>? productSizes,
  }) =>
      ProductSizesState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        productSizes: productSizes ?? this.productSizes,
      );
}
