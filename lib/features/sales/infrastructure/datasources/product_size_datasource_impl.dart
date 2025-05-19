import 'package:dio/dio.dart';
import 'package:komercia_app/features/home/infrastructure/errors/menu_errors.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/infrastructure/mappers/product_size_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class ProductSizeDatasourceImpl extends ProductSizeDatasource {
  late final dioClient = DioClient();

  ProductSizeDatasourceImpl();

  @override
  Future<ProductSize> getById(int idTalla) async {
    try {
      final response =
          await dioClient.dio.get('/general/size/getById/$idTalla');

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);
      final productSize =
          ProductSizeMapper.productSizeJsonToEntity(responseMain.data);
      return productSize;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<ProductSize>> getAll() async {
    final response = await dioClient.dio.get('/general/size/get_all');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductSize> productSizes = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productSizes
          .add(ProductSizeMapper.productSizeJsonToEntity(_productCategory));
    }

    return productSizes;
  }

  @override
  Future<List<ProductSize>> getByProduct(int idProducto) async {
    final response = await dioClient.dio
        .get('/general/size/get_by_product?id_producto=$idProducto');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductSize> productSizes = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productSizes
          .add(ProductSizeMapper.productSizeJsonToEntity(_productCategory));
    }

    return productSizes;
  }

  @override
  Future<List<ProductSize>> getList(Map<String, dynamic> body) async {
    final response =
        await dioClient.dio.get('/general/size/get_list', data: body);
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<ProductSize> productSizes = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _productCategory in responseMain.data ?? []) {
      productSizes
          .add(ProductSizeMapper.productSizeJsonToEntity(_productCategory));
    }

    return productSizes;
  }
}
