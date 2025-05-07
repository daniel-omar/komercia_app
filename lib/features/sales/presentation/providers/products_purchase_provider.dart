import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/discount_provider.dart';
import 'package:uuid/uuid.dart';

final showProductPurchaseValidationErrorsProvider =
    StateProvider<bool>((ref) => false);

final totalSaleComputedProvider = Provider<double>((ref) {
  final items = ref.watch(productsPurchaseProvider);
  return items.fold(
    0.0,
    (sum, item) => sum + (item.precioVenta ?? 0) * item.cantidad,
  );
});

final totalFinalComputedProvider = Provider<double>((ref) {
  final total = ref.watch(totalSaleComputedProvider);
  final discount = ref.watch(discountProvider);
  return discount.apply(total); // asumiendo que Discount tiene .apply()
});

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
      precioVenta: producto.precioVenta ?? 0,
      cantidad: 1,
      idTalla: 0,
      idColor: 0,
    );

    state = [...state, productPurchaseState];
  }

  void updateProduct(String uuid,
      {double? precioVenta, int? cantidad, int? idTalla, int? idColor}) {
    state = [
      for (final item in state)
        if (item.uuid == uuid)
          item.copyWith(
              precio: precioVenta ?? item.precioVenta,
              precioVenta: precioVenta ?? item.precioVenta,
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
  final double? precioCompra;
  final double? precioVenta;
  final int? idCategoria;
  final int? idTalla;
  final int? idColor;
  final int cantidad;
  final bool isLoading;
  final bool isSaving;

  ProductPurchaseState(
      {this.uuid = "",
      this.isLoading = true,
      this.isSaving = false,
      this.idProducto = 0,
      this.producto,
      this.precio = 0,
      this.precioCompra = 0,
      this.precioVenta = 0,
      this.idCategoria = 0,
      this.idTalla = 0,
      this.idColor = 0,
      this.cantidad = 0});

  ProductPurchaseState copyWith(
          {bool? isLoading,
          bool? isSaving,
          String? uuid,
          int? idProducto,
          Product? producto,
          double? precio,
          double? precioCompra,
          double? precioVenta,
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
          precioCompra: precioCompra ?? this.precioCompra,
          precioVenta: precioVenta ?? this.precioVenta,
          idCategoria: idCategoria ?? this.idCategoria,
          idTalla: idTalla ?? this.idTalla,
          idColor: idColor ?? this.idColor,
          cantidad: cantidad ?? this.cantidad);

  double get total => (precioVenta ?? 0) * cantidad;
}
