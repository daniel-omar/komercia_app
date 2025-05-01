import 'package:komercia_app/features/sales/domain/entities/product_color.dart';

abstract class ProductColorRepository {
  Future<List<ProductColor>> getAll();
  Future<List<ProductColor>> getList(Map<String, dynamic> body);
  Future<ProductColor> getById(int idColor);
}
