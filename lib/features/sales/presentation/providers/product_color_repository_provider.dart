import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';

final productColorRepositoryProvider = Provider<ProductColorRepository>((ref) {
  final productColorRepository =
      ProductColorRepositoryImpl(ProductColorDatasourceImpl());
  return productColorRepository;
});
