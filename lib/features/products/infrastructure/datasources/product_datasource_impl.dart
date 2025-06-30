import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/infrastructure/errors/product_errors.dart';
import 'package:komercia_app/features/products/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/products/infrastructure/mappers/product_variant_mapper.dart';
import 'package:komercia_app/features/sales/infrastructure/errors/sale_errors.dart';
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
  Future<List<Product>> getByFilters(
      {List<int>? idsCategoriaProducto, bool? esActivo}) async {
    // Map<String, dynamic> body = {};
    // if (idsCategoriaProducto != null) {
    //   body["ids_categoria"] = idsCategoriaProducto;
    // }
    List<Map<String, dynamic>> paramsList = [];
    if (idsCategoriaProducto != null && idsCategoriaProducto.isNotEmpty) {
      paramsList.add(
          {'key': 'ids_categoria', 'value': idsCategoriaProducto.join(',')});
    }
    if (esActivo != null) {
      paramsList.add({'key': 'es_activo', 'value': esActivo.toString()});
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
  Future<List<ProductVariant>> getVariants(int idProducto) async {
    final response =
        await dioClient.dio.get('/products/product/get_variants/$idProducto');

    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductVariant> productsVariants = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _material in responseMain.data ?? []) {
      productsVariants
          .add(ProductVariantMapper.productVariantJsonToEntity(_material));
    }

    return productsVariants;
  }

  @override
  Future<List<ProductVariantSize>> getVariantsGroup(int idProducto) async {
    final response = await dioClient.dio
        .get('/products/product/get_variants_group/$idProducto');

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
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      if (e.response != null) {
        ResponseMain responseError =
            ResponseMainMapper.responseJsonToEntity(e.response!.data);
        throw Exception(responseError.message);
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> updateActive(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio
          .put('/products/product/update_active', data: data);
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);
      return true;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      if (e.response != null) {
        ResponseMain responseError =
            ResponseMainMapper.responseJsonToEntity(e.response!.data);
        throw Exception(responseError.message);
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  // @override
  // Future<void> downloadTags(List<int> idsProducto) async {
  //   try {
  //     Map<String, dynamic> body = {};
  //     body["ids_producto"] = idsProducto;

  //     final response =
  //         await dioClient.dio.post('/products/product/generate_tags',
  //             data: body,
  //             options: Options(
  //               responseType: ResponseType.bytes,
  //               headers: {'Accept': 'application/pdf'},
  //             ));

  //     // Guardar archivo
  //     final dir = await getTemporaryDirectory();
  //     final filePath = '${dir.path}/etiquetas.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(response.data as Uint8List);

  //     // Abrir PDF
  //     await OpenFile.open(filePath);
  //   } catch (e) {
  //     throw Exception(e);
  //   }
  // }

  @override
  Future<void> downloadTags(Map<String, dynamic> data) async {
    try {
      final response =
          await dioClient.dio.post('/products/product/generate_tags_variantes',
              data: data,
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
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      if (e.response != null) {
        ResponseMain responseError =
            ResponseMainMapper.responseJsonToEntity(e.response!.data);
        throw Exception(responseError.message);
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> saveVariants(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio
          .post('/products/product/save_variants', data: data);
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<ProductVariant> findProductVariant(
      {int? idProductoVariante,
      String? codigoProductoVariante,
      bool? esActivo}) async {
    try {
      List<Map<String, dynamic>> paramsList = [];
      if (idProductoVariante != null) {
        paramsList.add({
          'key': 'id_producto_variante',
          'value': idProductoVariante.toString()
        });
      }
      if (codigoProductoVariante != null) {
        paramsList.add({
          'key': 'codigo_producto_variante',
          'value': codigoProductoVariante
        });
      }
      if (esActivo != null) {
        paramsList.add({'key': 'es_activo', 'value': esActivo.toString()});
      }

      String queryString = paramsList
          .map((param) =>
              '${Uri.encodeComponent(param['key']!)}=${Uri.encodeComponent(param['value']!)}')
          .join('&');

      final response = await dioClient.dio
          .get('/products/product/find_product_variant?$queryString');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final product =
          ProductVariantMapper.productVariantJsonToEntity(responseMain.data);
      return product;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> saveIncome(Map<String, dynamic> data) async {
    try {
      final response =
          await dioClient.dio.post('/products/product/save_income', data: data);
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      return true;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      if (e.response != null) {
        ResponseMain responseError =
            ResponseMainMapper.responseJsonToEntity(e.response!.data);
        throw Exception(responseError.message);
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> saveBulk(File file) async {
    try {
      final fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dioClient.dio
          .post('/products/product/save_bulk', data: formData);
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      return responseMain.status == 1;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      if (e.response != null) {
        ResponseMain responseError =
            ResponseMainMapper.responseJsonToEntity(e.response!.data);
        throw Exception(responseError.message);
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> downloadTemplateProducts() async {
    try {
      final response = await dioClient.dio
          .get('/products/product/download_template_products',
              options: Options(responseType: ResponseType.bytes, headers: {
                'Accept':
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              }));

      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception("No se pudo acceder a carpeta de descarga.");
      }
      // final downloadsDir = Directory('/storage/emulated/0/Download');
      final filePath = '${directory.path}/plantilla.xlsx';

      final file = File(filePath);
      await file.writeAsBytes(response.data);

      await OpenFile.open(filePath);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> saveOutput(Map<String, dynamic> data) async {
    try {
      final response =
          await dioClient.dio.post('/products/product/save_output', data: data);
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      return true;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      if (e.response != null) {
        ResponseMain responseError =
            ResponseMainMapper.responseJsonToEntity(e.response!.data);
        throw Exception(responseError.message);
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
