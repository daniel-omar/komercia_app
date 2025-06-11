import 'package:komercia_app/features/products/domain/entities/product.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';

abstract class ProductRepository {
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto});
  Future<Product> getById(int idProducto);
  Future<Product> find({int? idProducto, String? codigoProducto});
  Future<List<ProductVariant>> getVariants(int idProducto);
  Future<List<ProductVariantSize>> getVariantsGroup(int idProducto);
  Future<bool> update(Map<String, dynamic> data);
  Future<void> downloadTags(List<int> idsProducto);
  Future<bool> saveVariants(Map<String, dynamic> data);
}
