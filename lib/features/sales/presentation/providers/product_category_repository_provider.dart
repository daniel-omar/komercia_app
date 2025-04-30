import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/repositories/product_category_repository.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';

final productCategoryRepositoryProvider =
    Provider<ProductCategoryRepository>((ref) {
  final productCategoryRepository =
      ProductCategoryRepositoryImpl(ProductCategoryDatasourceImpl());
  return productCategoryRepository;
});
