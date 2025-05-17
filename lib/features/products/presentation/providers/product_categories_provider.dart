import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/entities/product_category.dart';
import 'package:komercia_app/features/products/domain/repositories/product_category_repository.dart';
import 'package:komercia_app/features/products/presentation/providers/product_category_repository_provider.dart';

final productCategoriesProvider = StateNotifierProvider.autoDispose<
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

      final productCategories = await productCategoryRepository.getAll();
      state = state.copyWith(
          isLoading: false,
          productCategories: productCategories,
          productCategorySelect: productCategories.first);
    } catch (e) {
      // 404 product not found
      print(e);
      state = state.copyWith(isLoading: true);
    }
  }

  void setPeriod(ProductCategory productCategory) {
    state = state.copyWith(productCategorySelect: productCategory);
  }
}

class ProductCategorysState {
  final bool isLoading;
  final bool isSaving;
  final List<ProductCategory>? productCategories;
  final ProductCategory? productCategorySelect;

  ProductCategorysState(
      {this.isLoading = true,
      this.isSaving = false,
      this.productCategories,
      this.productCategorySelect});

  ProductCategorysState copyWith(
          {bool? isLoading,
          bool? isSaving,
          List<ProductCategory>? productCategories,
          ProductCategory? productCategorySelect}) =>
      ProductCategorysState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          productCategories: productCategories ?? this.productCategories,
          productCategorySelect:
              productCategorySelect ?? this.productCategorySelect);
}
