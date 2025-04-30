import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/repositories/sale_repository.dart';
import 'package:komercia_app/features/sales/infrastructure/datasources/sale_datasource_impl.dart';
import 'package:komercia_app/features/sales/infrastructure/repositories/sale_repository_impl.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final saleRepository = SaleRepositoryImpl(SaleDatasourceImpl());
  return saleRepository;
});
