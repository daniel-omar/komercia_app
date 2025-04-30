import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class SaleDatasourceImpl extends SaleDatasource {
  late final dioClient = DioClient();

  SaleDatasourceImpl();

  @override
  Future<Sale> getSaleById(int idOrden) async {
    try {
      final response =
          await dioClient.dio.get('/sales/sale/get_sale_by_id/$idOrden');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final order = SaleMapper.saleJsonToEntity(responseMain.data);
      return order;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw SaleNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Sale>> getSalesByUser(int idUsuario,
      {int limit = 10, int offset = 0, List<int>? idsCategoriaProducto}) async {
    Map<String, dynamic> body = {};
    if (idsCategoriaProducto != null) {
      body["id_categoria_producto"] = idsCategoriaProducto;
    }

    final response = await dioClient.dio
        .get('/sales/sale/get_sales_by_user/$idUsuario', data: body);
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<Sale> orders = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _order in responseMain.data ?? []) {
      orders.add(SaleMapper.saleJsonToEntity(_order));
    }

    return orders;
  }

  @override
  Future<bool> sell(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap({
        'data': jsonEncode(data),
      });

      final response =
          await dioClient.dio.post('/sales/sale/sell', data: formData);
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw SaleNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }

    return true;
  }
}
