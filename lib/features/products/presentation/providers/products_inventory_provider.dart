import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';

final productsInventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<ProductVariant>>((ref) {
  return InventoryNotifier();
});

class InventoryNotifier extends StateNotifier<List<ProductVariant>> {
  InventoryNotifier() : super([]);

  // void agregarProducto(int idProducto, int idTalla, int idColor, int cantidad) {
  //   final index = state.indexWhere((item) =>
  //       item.idProducto == idProducto &&
  //       item.idTalla == idTalla &&
  //       item.idColor == idColor);
  //   if (index == -1) {
  //     // Producto nuevo
  //     state = [
  //       ...state,
  //       ProductVariant(
  //           idProducto: idProducto,
  //           idTalla: idTalla,
  //           idColor: idColor,
  //           cantidad: cantidad)
  //     ];
  //   } else {
  //     // Acumular cantidad
  //     final updatedList = [...state];
  //     updatedList[index].cantidad += cantidad;
  //     state = updatedList;
  //   }
  // }

  // void eliminarProducto(int idProducto, int idTalla, int idColor) {
  //   state = state
  //       .where((item) =>
  //           item.idProducto != idProducto &&
  //           item.idTalla != idTalla &&
  //           item.idColor != idColor)
  //       .toList();
  // }

  void addProductVariant(ProductVariant productVariant, int cantidad) {
    final index = state.indexWhere(
        (item) => item.idProductoVariante == productVariant.idProductoVariante);
    if (index == -1) {
      // Producto nuevo
      state = [
        ...state,
        ProductVariant(
            idProducto: productVariant.idProducto,
            nombreProducto: productVariant.nombreProducto,
            codigoProductoVariante: productVariant.codigoProductoVariante,
            idProductoVariante: productVariant.idProductoVariante,
            idTalla: productVariant.idTalla,
            talla: productVariant.talla,
            idColor: productVariant.idColor,
            color: productVariant.color,
            cantidad: cantidad)
      ];
    } else {
      // Acumular cantidad
      final updatedList = [...state];
      updatedList[index].cantidad += cantidad;
      state = updatedList;
    }
  }

  void removeProductVariant(int idProductoVariante) {
    state = state
        .where((item) => item.idProductoVariante != idProductoVariante)
        .toList();
  }

  void clear() {
    state = [];
  }
}
