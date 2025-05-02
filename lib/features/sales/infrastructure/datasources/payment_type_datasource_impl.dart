import 'package:dio/dio.dart';
import 'package:komercia_app/features/home/infrastructure/errors/menu_errors.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class PaymentTypeDatasourceImpl extends PaymentTypeDatasource {
  late final dioClient = DioClient();

  PaymentTypeDatasourceImpl();

  @override
  Future<PaymentType> getById(int idTipoPago) async {
    try {
      final response =
          await dioClient.dio.get('/general/payment_type/getById/$idTipoPago');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);
      final paymentType =
          PaymentTypeMapper.paymentTypeJsonToEntity(responseMain.data);
      return paymentType;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<PaymentType>> getAll() async {
    final response = await dioClient.dio.get('/general/payment_type/get_all');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<PaymentType> paymentTypes = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _paymentType in responseMain.data ?? []) {
      paymentTypes.add(PaymentTypeMapper.paymentTypeJsonToEntity(_paymentType));
    }

    return paymentTypes;
  }

  @override
  Future<List<PaymentType>> getList(Map<String, dynamic> body) async {
    final response =
        await dioClient.dio.get('/general/payment_type/get_list', data: body);
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<PaymentType> paymentTypes = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _paymentType in responseMain.data ?? []) {
      paymentTypes.add(PaymentTypeMapper.paymentTypeJsonToEntity(_paymentType));
    }

    return paymentTypes;
  }
}
