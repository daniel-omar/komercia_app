import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<Product> getById(int idProducto) {
    return datasource.getById(idProducto);
  }

  @override
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto}) {
    return datasource.getByFilters(idsCategoriaProducto: idsCategoriaProducto);
  }

  @override
  Future<Product> find({int? idProducto, String? codigoProducto}) {
    return datasource.find(
        idProducto: idProducto, codigoProducto: codigoProducto);
  }

  @override
  Future<List<ProductVariant>> getVariants(int idProducto) {
    return datasource.getVariants(idProducto);
  }

  @override
  Future<List<ProductVariantSize>> getVariantsGroup(int idProducto) {
    return datasource.getVariantsGroup(idProducto);
  }

  @override
  Future<bool> update(Map<String, dynamic> data) {
    return datasource.update(data);
  }

  @override
  Future<void> downloadTags(List<int> idsProducto) {
    return datasource.downloadTags(idsProducto);
  }

  @override
  Future<bool> saveVariants(Map<String, dynamic> data) {
    return datasource.saveVariants(data);
  }
}
