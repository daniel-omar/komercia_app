import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/repositories/product_category_repository.dart';
import 'package:komercia_app/features/products/infrastructure/infrastructure.dart';

final productCategoryRepositoryProvider =
    Provider<ProductCategoryRepository>((ref) {
  final productCategoryRepository =
      ProductCategoryRepositoryImpl(ProductCategoryDatasourceImpl());
  return productCategoryRepository;
});
