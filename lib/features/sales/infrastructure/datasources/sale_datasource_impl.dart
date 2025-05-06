import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:komercia_app/features/home/infrastructure/errors/menu_errors.dart';
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
  Future<bool> createSale(Map<String, dynamic> data) async {
    try {
      final response =
          await dioClient.dio.post('/sales/sale/create', data: data);
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

  @override
  Future<List<Sale>> getSalesByFilter(
      {int? idTipoPago,
      bool? tieneDescuento,
      String? fechaInicio,
      String? fechaFin}) async {
    List<Map<String, dynamic>> paramsList = [];

    try {
      if (idTipoPago != null) {
        paramsList.add({'key': 'id_tipo_pago', 'value': idTipoPago});
      }
      if (tieneDescuento != null) {
        paramsList.add({'key': 'tiene_descuento', 'value': tieneDescuento});
      }
      if (fechaInicio != null) {
        paramsList.add({'key': 'fecha_inicio', 'value': fechaInicio});
      }
      if (fechaFin != null) {
        paramsList.add({'key': 'fecha_fin', 'value': fechaFin});
      }

      String queryString = paramsList
          .map((param) =>
              '${Uri.encodeComponent(param['key']!)}=${Uri.encodeComponent(param['value']!)}')
          .join('&');

      final response =
          await dioClient.dio.get('/sales/sale/get_by_filter?$queryString');
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final List<Sale> sales = [];

      // ignore: no_leading_underscores_for_local_identifiers
      for (final _order in responseMain.data ?? []) {
        sales.add(SaleMapper.saleJsonToEntity(_order));
      }

      return sales;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
