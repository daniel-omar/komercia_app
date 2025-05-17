
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/infrastructure/infrastructure.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final productRepository = ProductRepositoryImpl(ProductDatasourceImpl());
  return productRepository;
});
