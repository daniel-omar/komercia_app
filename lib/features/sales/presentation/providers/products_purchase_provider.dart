import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_repository_provider.dart';

final productsPurchaseProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductPurchaseState>>((ref) {
  return ProductsNotifier();
});

class ProductsNotifier extends StateNotifier<List<ProductPurchaseState>> {
  ProductsNotifier() : super([]);

  void addProduct(Product producto) {
    final productPurchaseState = ProductPurchaseState(
        idProducto: producto.idProducto,
        producto: producto,
        idCategoria: producto.idCategoria);

    state = [...state, productPurchaseState];
  }

  void updateProduct(int idProducto,
      {double? precio, int? cantidad, int? idTalla, int? idColor}) {
    state = [
      for (final item in state)
        if (item.idProducto == idProducto)
          item.copyWith(
              precio: precio ?? item.precio,
              cantidad: cantidad ?? item.cantidad,
              idTalla: idTalla ?? item.idTalla,
              idColor: cantidad ?? item.idColor)
        else
          item,
    ];
  }

  void removeProduct(int idProducto) {
    state = state.where((item) => item.idProducto != idProducto).toList();
  }

  void clear() {
    state = [];
  }
}

class ProductPurchaseState {
  final int idProducto;
  final Product? producto;
  final double? precio;
  final int? idCategoria;
  final int? idTalla;
  final int? idColor;
  final int cantidad;
  final bool isLoading;
  final bool isSaving;

  ProductPurchaseState(
      {this.isLoading = true,
      this.isSaving = false,
      this.idProducto = 0,
      this.producto,
      this.precio = 0,
      this.idCategoria = 0,
      this.idTalla = 0,
      this.idColor = 0,
      this.cantidad = 0});

  ProductPurchaseState copyWith(
          {bool? isLoading,
          bool? isSaving,
          int? idProducto,
          Product? producto,
          double? precio,
          int? idCategoria,
          int? idTalla,
          int? idColor,
          int? cantidad}) =>
      ProductPurchaseState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          idProducto: idProducto ?? this.idProducto,
          producto: producto ?? this.producto,
          precio: precio ?? this.precio,
          idCategoria: idCategoria ?? this.idCategoria,
          idTalla: idTalla ?? this.idTalla,
          idColor: idColor ?? this.idColor,
          cantidad: cantidad ?? this.cantidad);
}
