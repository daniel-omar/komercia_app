import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';

final productsInventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<ProductVariant>>((ref) {
  return InventoryNotifier();
});

class InventoryNotifier extends StateNotifier<List<ProductVariant>> {
  InventoryNotifier() : super([]);

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

  void updateProductVariant(ProductVariant productVariant, {int? cantidad}) {
    state = [
      for (final item in state)
        if (item.idProductoVariante == productVariant.idProductoVariante) ...[
          ProductVariant(
              idProducto: productVariant.idProducto,
              nombreProducto: productVariant.nombreProducto,
              codigoProductoVariante: productVariant.codigoProductoVariante,
              idProductoVariante: productVariant.idProductoVariante,
              idTalla: productVariant.idTalla,
              talla: productVariant.talla,
              idColor: productVariant.idColor,
              color: productVariant.color,
              cantidad: cantidad ?? 1)
        ] else
          item,
    ];
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
