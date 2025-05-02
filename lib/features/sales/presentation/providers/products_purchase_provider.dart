import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:uuid/uuid.dart';

final productsPurchaseProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductPurchaseState>>((ref) {
  return ProductsNotifier();
});

class ProductsNotifier extends StateNotifier<List<ProductPurchaseState>> {
  ProductsNotifier() : super([]);

  void addProduct(Product producto) {
    final String uid = const Uuid().v4();

    final productPurchaseState = ProductPurchaseState(
      uuid: uid,
      idProducto: producto.idProducto,
      producto: producto,
      idCategoria: producto.idCategoria,
      precio: producto.precio ?? 0,
      cantidad: 1,
      idTalla: 0,
      idColor: 0,
    );

    state = [...state, productPurchaseState];
  }

  void updateProduct(String uuid,
      {double? precio, int? cantidad, int? idTalla, int? idColor}) {
    state = [
      for (final item in state)
        if (item.uuid == uuid)
          item.copyWith(
              precio: precio ?? item.precio,
              cantidad: cantidad ?? item.cantidad,
              idTalla: idTalla ?? item.idTalla,
              idColor: idColor ?? item.idColor)
        else
          item,
    ];
  }

  void removeProduct(String uuid) {
    state = state.where((item) => item.uuid != uuid).toList();
  }

  void clear() {
    state = [];
  }
}

class ProductPurchaseState {
  final String uuid;
  final int idProducto;
  final Product? producto;
  final double? precio;
  final int? idCategoria;
  final int? idTalla;
  final int? idColor;
  final int cantidad;
  final bool isLoading;
  final bool isSaving;
  final double? total;

  ProductPurchaseState(
      {this.uuid = "",
      this.isLoading = true,
      this.isSaving = false,
      this.idProducto = 0,
      this.producto,
      this.precio = 0,
      this.idCategoria = 0,
      this.idTalla = 0,
      this.idColor = 0,
      this.cantidad = 0,
      this.total = 0});

  ProductPurchaseState copyWith(
          {bool? isLoading,
          bool? isSaving,
          String? uuid,
          int? idProducto,
          Product? producto,
          double? precio,
          int? idCategoria,
          int? idTalla,
          int? idColor,
          int? cantidad,
          double? total}) =>
      ProductPurchaseState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          uuid: uuid ?? this.uuid,
          idProducto: idProducto ?? this.idProducto,
          producto: producto ?? this.producto,
          precio: precio ?? this.precio,
          idCategoria: idCategoria ?? this.idCategoria,
          idTalla: idTalla ?? this.idTalla,
          idColor: idColor ?? this.idColor,
          cantidad: cantidad ?? this.cantidad,
          total: total ?? this.total);
}
