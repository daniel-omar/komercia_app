import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/entities/product_variant.dart';
import 'package:komercia_app/features/sales/presentation/providers/discount_provider.dart';
import 'package:uuid/uuid.dart';

final showProductPurchaseValidationErrorsProvider =
    StateProvider<bool>((ref) => false);

final totalSaleComputedProvider = Provider<double>((ref) {
  final items = ref.watch(productsVariantsPurchaseProvider);
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

final productsVariantsPurchaseProvider = StateNotifierProvider<
    ProductsVariantsNotifier, List<ProductVariantPurchaseState>>((ref) {
  return ProductsVariantsNotifier();
});

class ProductsVariantsNotifier
    extends StateNotifier<List<ProductVariantPurchaseState>> {
  ProductsVariantsNotifier() : super([]);

  void addProductVariant(ProductVariant productoVariante) {
    final String uid = const Uuid().v4();

    final productPurchaseState = ProductVariantPurchaseState(
      uuid: uid,
      productoVariante: productoVariante,
      precioVenta: productoVariante.precioVenta ?? 0,
      precioCompra: productoVariante.precioCompra ?? 0,
      cantidad: 1,
      cantidadMaxima: productoVariante.cantidad,
    );

    state = [...state, productPurchaseState];
  }

  void updateProductVariant(String uuid,
      {double? precioVenta, int? cantidad, int? cantidadMaxima}) {
    state = [
      for (final item in state)
        if (item.uuid == uuid)
          item.copyWith(
              precioVenta: precioVenta ?? item.precioVenta,
              cantidad: cantidad ?? item.cantidad,
              cantidadMaxima: cantidadMaxima ?? item.cantidadMaxima)
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

class ProductVariantPurchaseState {
  final String uuid;
  final ProductVariant? productoVariante;
  final double? precioCompra;
  final double? precioVenta;
  final int cantidad;
  final int cantidadMaxima;
  final bool isLoading;
  final bool isSaving;

  ProductVariantPurchaseState(
      {this.uuid = "",
      this.productoVariante,
      this.isLoading = true,
      this.isSaving = false,
      this.precioCompra = 0,
      this.precioVenta = 0,
      this.cantidad = 0,
      this.cantidadMaxima = 0});

  ProductVariantPurchaseState copyWith(
          {bool? isLoading,
          bool? isSaving,
          String? uuid,
          ProductVariant? productoVariante,
          double? precioCompra,
          double? precioVenta,
          int? cantidad,
          int? cantidadMaxima}) =>
      ProductVariantPurchaseState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          productoVariante: productoVariante ?? this.productoVariante,
          uuid: uuid ?? this.uuid,
          precioCompra: precioCompra ?? this.precioCompra,
          precioVenta: precioVenta ?? this.precioVenta,
          cantidad: cantidad ?? this.cantidad,
          cantidadMaxima: cantidadMaxima ?? this.cantidadMaxima);

  double get total => (precioVenta ?? 0) * cantidad;
}
