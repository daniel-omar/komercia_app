import 'package:dio/dio.dart';
import 'package:komercia_app/features/home/infrastructure/errors/menu_errors.dart';
import 'package:komercia_app/features/sales/domain/datasources/product_color_datasource.dart';
import 'package:komercia_app/features/sales/domain/entities/product_color.dart';
import 'package:komercia_app/features/sales/infrastructure/mappers/product_color_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class ProductColorDatasourceImpl extends ProductColorDatasource {
  late final dioClient = DioClient();

  ProductColorDatasourceImpl();

  @override
  Future<ProductColor> getById(int idColor) async {
    try {
      final response =
          await dioClient.dio.get('/general/color/getById/$idColor');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);
      final productColor =
          ProductColorMapper.productColorJsonToEntity(responseMain.data);
      return productColor;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<ProductColor>> getAll() async {
    final response = await dioClient.dio.get('/general/color/get_all');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductColor> productColors = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productColors
          .add(ProductColorMapper.productColorJsonToEntity(_productCategory));
    }

    return productColors;
  }

  @override
  Future<List<ProductColor>> getByProduct(int idProducto) async {
    final response = await dioClient.dio
        .get('/general/color/get_by_product?id_producto=$idProducto');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductColor> productColors = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productColors
          .add(ProductColorMapper.productColorJsonToEntity(_productCategory));
    }

    return productColors;
  }

  @override
  Future<List<ProductColor>> getList({int? idProducto, int? idTalla}) async {
    List<Map<String, dynamic>> paramsList = [];
    if (idProducto != null) {
      paramsList.add({'key': 'id_producto', 'value': idProducto.toString()});
    }
    if (idTalla != null) {
      paramsList.add({'key': 'id_talla', 'value': idTalla.toString()});
    }

    String queryString = paramsList
        .map((param) =>
            '${Uri.encodeComponent(param['key']!)}=${Uri.encodeComponent(param['value'])}')
        .join('&');

    final response = await dioClient.dio
        .get('/general/color/get_product_color_by_filter?$queryString');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductColor> productColors = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productColors
          .add(ProductColorMapper.productColorJsonToEntity(_productCategory));
    }

    return productColors;
  }
}
