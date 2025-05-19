import 'package:komercia_app/features/products/domain/entities/product.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';

abstract class ProductDatasource {
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto});
  Future<Product> getById(int idProducto);
  Future<Product> find({int? idProducto, String? codigoProducto});
  Future<List<ProductVariantSize>> getVariants(int idProducto);
  Future<bool> update(Map<String, dynamic> data);
}
