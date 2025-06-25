import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductVariantSelectionNotifier
    extends StateNotifier<List<ProductVariantSelection>> {
  ProductVariantSelectionNotifier() : super([]);

  void toggleSelection(int idProducto, int idProductoVariante) {
    final exists = state.any((e) => e.idProductoVariante == idProductoVariante);
    if (exists) {
      state = state.where((e) => e.idProductoVariante != idProductoVariante).toList();
    } else {
      state = [
        ...state,
        ProductVariantSelection(
            idProducto: idProducto, idProductoVariante: idProductoVariante, cantidad: 1)
      ];
    }
  }

  void updateCantidad(int idVariante, int nuevaCantidad) {
    state = state.map((e) {
      if (e.idProductoVariante == idVariante) {
        return e.copyWith(cantidad: nuevaCantidad);
      }
      return e;
    }).toList();
  }

  void clear() => state = [];
}

final productsVariantSelectionProvider = StateNotifierProvider<ProductVariantSelectionNotifier,
    List<ProductVariantSelection>>(
  (ref) => ProductVariantSelectionNotifier(),
);

class ProductVariantSelection {
  final int idProducto;
  final int idProductoVariante;
  final int cantidad;

  ProductVariantSelection(
      {required this.idProducto,
      required this.idProductoVariante,
      required this.cantidad});

  ProductVariantSelection copyWith({int? cantidad}) => ProductVariantSelection(
        idProducto: idProducto,
        idProductoVariante: idProductoVariante,
        cantidad: cantidad ?? this.cantidad,
      );
}
