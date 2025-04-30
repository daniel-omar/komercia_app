import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/entities/product_category.dart';
import 'package:komercia_app/features/sales/domain/repositories/product_category_repository.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_category_repository_provider.dart';

final productCategorysProvider = StateNotifierProvider.autoDispose<
    ProductCategorysNotifier,
    ProductCategorysState
    //int
    >((ref) {
  final productCategoryRepository =
      ref.watch(productCategoryRepositoryProvider);

  return ProductCategorysNotifier(
    productCategoryRepository: productCategoryRepository,
    //idProductCategory: idProductCategory,
  );
});

class ProductCategorysNotifier extends StateNotifier<ProductCategorysState> {
  final ProductCategoryRepository productCategoryRepository;

  ProductCategorysNotifier({
    required this.productCategoryRepository,
    //required int? idProductCategory,
  }) : super(ProductCategorysState()) {
    loadProductCategorys();
  }

  Future<void> loadProductCategorys() async {
    try {
      state = state.copyWith(isLoading: true);

      Map<String, dynamic> body = {};
      // body["es_seriado"] = true;

      final productCategorys = await productCategoryRepository.getList(body);

      state =
          state.copyWith(isLoading: false, productCategorys: productCategorys);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class ProductCategorysState {
  final bool isLoading;
  final bool isSaving;
  final List<ProductCategory>? productCategorys;

  ProductCategorysState({
    this.isLoading = true,
    this.isSaving = false,
    this.productCategorys,
  });

  ProductCategorysState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ProductCategory>? productCategorys,
  }) =>
      ProductCategorysState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        productCategorys: productCategorys ?? this.productCategorys,
      );
}
