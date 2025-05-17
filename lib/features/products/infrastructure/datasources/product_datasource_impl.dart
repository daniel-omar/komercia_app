import 'package:dio/dio.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/infrastructure/errors/product_errors.dart';
import 'package:komercia_app/features/products/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class ProductDatasourceImpl extends ProductDatasource {
  late final dioClient = DioClient();

  ProductDatasourceImpl();

  @override
  Future<Product> getById(int idProducto) async {
    try {
      final response =
          await dioClient.dio.get('/products/product/getById/$idProducto');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final product = ProductMapper.productJsonToEntity(responseMain.data);
      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto}) async {
    // Map<String, dynamic> body = {};
    // if (idsCategoriaProducto != null) {
    //   body["ids_categoria"] = idsCategoriaProducto;
    // }
    List<Map<String, dynamic>> paramsList = [];
    if (idsCategoriaProducto != null) {
      paramsList.add(
          {'key': 'ids_categoria', 'value': idsCategoriaProducto.join(',')});
    }
    String queryString = paramsList
        .map((param) =>
            '${Uri.encodeComponent(param['key']!)}=${Uri.encodeComponent(param['value']!)}')
        .join('&');
    final response =
        await dioClient.dio.get('/products/product/get_by_filter?$queryString');
        
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<Product> products = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _material in responseMain.data ?? []) {
      products.add(ProductMapper.productJsonToEntity(_material));
    }

    return products;
  }

  @override
  Future<Product> find({int? idProducto, String? codigoProducto}) async {
    try {
      List<Map<String, dynamic>> paramsList = [];
      if (idProducto != null) {
        paramsList.add({'key': 'id_producto', 'value': idProducto});
      }
      if (codigoProducto != null) {
        paramsList.add({'key': 'codigo_producto', 'value': codigoProducto});
      }

      String queryString = paramsList
          .map((param) =>
              '${Uri.encodeComponent(param['key']!)}=${Uri.encodeComponent(param['value']!)}')
          .join('&');

      final response =
          await dioClient.dio.get('/products/product/find?$queryString');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final product = ProductMapper.productJsonToEntity(responseMain.data);
      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
