import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';

final paymentTypeRepositoryProvider = Provider<PaymentTypeRepository>((ref) {
  final paymentTypeRepository =
      PaymentTypeRepositoryImpl(PaymentTypeDatasourceImpl());
  return paymentTypeRepository;
});
