import 'package:komercia_app/features/sales/domain/entities/product.dart';
import 'package:komercia_app/features/sales/domain/entities/product_category.dart';
import 'package:komercia_app/features/sales/domain/entities/product_variant.dart';

abstract class ProductDatasource {
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto});
  Future<Product> getById(int idProducto);
  Future<List<ProductCategory>> getListGroupByFilters(
      {List<int>? idsCategoriaProducto});
  Future<Product> find({int? idProducto, String? codigoProducto});
  Future<ProductVariant> findProductVariant(
      {int? idProductoVariante,
      String? codigoProductoVariante,
      bool? esActivo,
      bool? tieneCantidad});
}
