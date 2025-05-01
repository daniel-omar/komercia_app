import 'package:komercia_app/features/sales/domain/entities/product_size.dart';

abstract class ProductSizeDatasource {
  Future<List<ProductSize>> getAll();
  Future<List<ProductSize>> getList(Map<String, dynamic> body);
  Future<ProductSize> getById(int idTalla);
}
