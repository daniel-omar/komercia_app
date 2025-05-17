import 'package:dio/dio.dart';
import 'package:komercia_app/features/home/infrastructure/errors/menu_errors.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class ProductCategoryDatasourceImpl extends ProductCategoryDatasource {
  late final dioClient = DioClient();

  ProductCategoryDatasourceImpl();

  @override
  Future<ProductCategory> getById(int idCategoriaProducto) async {
    try {
      final response = await dioClient.dio
          .get('/products/product_category/getById/$idCategoriaProducto');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);
      final productCategory =
          ProductCategoryMapper.productCategoryJsonToEntity(responseMain.data);
      return productCategory;
      
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<ProductCategory>> getAll() async {
    final response =
        await dioClient.dio.get('/products/product_category/get_all');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductCategory> productCategorys = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productCategorys.add(
          ProductCategoryMapper.productCategoryJsonToEntity(_productCategory));
    }

    return productCategorys;
  }

  @override
  Future<List<ProductCategory>> getList(Map<String, dynamic> body) async {
    final response = await dioClient.dio
        .get('/products/product_category/get_list', data: body);
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductCategory> productCategorys = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productCategorys.add(
          ProductCategoryMapper.productCategoryJsonToEntity(_productCategory));
    }

    return productCategorys;
  }
}
