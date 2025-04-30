import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:komercia_app/features/sales/domain/entities/product_category.dart';
import 'package:komercia_app/features/sales/domain/repositories/product_category_repository.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_category_repository_provider.dart';

final productCategoryProvider = StateNotifierProvider.autoDispose<
    ProductCategoryNotifier,
    ProductCategoryState
    //int
    >((ref) {
  final productCategoryRepository =
      ref.watch(productCategoryRepositoryProvider);

  return ProductCategoryNotifier(
    productCategoryRepository: productCategoryRepository,
    //idProductCategory: idProductCategory,
  );
});

class ProductCategoryNotifier extends StateNotifier<ProductCategoryState> {
  final ProductCategoryRepository productCategoryRepository;

  ProductCategoryNotifier({
    required this.productCategoryRepository,
    //required int? idProductCategory,
  }) : super(ProductCategoryState(idProductCategory: 0));

  void onCategoryChanged(int idProductCategory) {
    state = state.copyWith(idProductCategory: idProductCategory);
  }
}

class ProductCategoryState {
  final int idProductCategory;
  final ProductCategory? productCategory;
  final bool isLoading;
  final bool isSaving;

  ProductCategoryState({
    required this.idProductCategory,
    this.productCategory,
    this.isLoading = true,
    this.isSaving = false,
  });

  ProductCategoryState copyWith({
    int? idProductCategory,
    ProductCategory? productCategory,
    bool? isLoading,
    bool? isSaving,
  }) =>
      ProductCategoryState(
        idProductCategory: idProductCategory ?? this.idProductCategory,
        productCategory: productCategory ?? this.productCategory,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );
}
