import 'package:komercia_app/features/sales/domain/entities/payment_type.dart';

abstract class PaymentTypeRepository {
  Future<List<PaymentType>> getAll();
  Future<List<PaymentType>> getList(Map<String, dynamic> body);
  Future<PaymentType> getById(int idtipoPago);
}
