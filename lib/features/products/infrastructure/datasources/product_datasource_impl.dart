import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/infrastructure/errors/product_errors.dart';
import 'package:komercia_app/features/products/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/products/infrastructure/mappers/product_variant_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto}) async {
    // Map<String, dynamic> body = {};
    // if (idsCategoriaProducto != null) {
    //   body["ids_categoria"] = idsCategoriaProducto;
    // }
    List<Map<String, dynamic>> paramsList = [];
    if (idsCategoriaProducto != null && idsCategoriaProducto.isNotEmpty) {
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
        paramsList.add({'key': 'id_producto', 'value': idProducto.toString()});
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

  @override
  Future<List<ProductVariantSize>> getVariants(int idProducto) async {
    final response =
        await dioClient.dio.get('/products/product/get_variants/$idProducto');

    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductVariantSize> productsVariantSize = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _material in responseMain.data ?? []) {
      productsVariantSize
          .add(ProductVariantSizeMapper.productVariantJsonToEntity(_material));
    }

    return productsVariantSize;
  }

  @override
  Future<bool> update(Map<String, dynamic> data) async {
    try {
      final response =
          await dioClient.dio.put('/products/product/update', data: data);
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> downloadTags(List<int> idsProducto) async {
    try {
      
      Map<String, dynamic> body = {};
      body["ids_producto"] = idsProducto;

      final response =
          await dioClient.dio.post('/products/product/generate_tags',
              data: body,
              options: Options(
                responseType: ResponseType.bytes,
                headers: {'Accept': 'application/pdf'},
              ));

      // Guardar archivo
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/etiquetas.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.data as Uint8List);

      // Abrir PDF
      await OpenFile.open(filePath);
    } catch (e) {
      throw Exception(e);
    }
  }
}
