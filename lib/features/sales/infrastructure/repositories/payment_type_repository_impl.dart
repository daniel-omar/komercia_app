import 'package:komercia_app/features/sales/domain/domain.dart';

class PaymentTypeRepositoryImpl extends PaymentTypeRepository {
  final PaymentTypeDatasource datasource;

  PaymentTypeRepositoryImpl(this.datasource);

  @override
  Future<PaymentType> getById(int idTipoPago) {
    return datasource.getById(idTipoPago);
  }

  @override
  Future<List<PaymentType>> getAll() {
    return datasource.getAll();
  }

  @override
  Future<List<PaymentType>> getList(Map<String, dynamic> body) {
    return datasource.getList(body);
  }
}
