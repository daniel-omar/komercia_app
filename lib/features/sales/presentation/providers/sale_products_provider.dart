import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/domain/entities/sale_product.dart';

import 'sale_repository_provider.dart';

final saleProductsSerialProvider = StateNotifierProvider.autoDispose<
    SaleProductsSerialNotifier, SaleProductsState>((ref) {
  final saleRepository = ref.watch(saleRepositoryProvider);

  return SaleProductsSerialNotifier(saleRepository: saleRepository);
});

class SaleProductsSerialNotifier extends StateNotifier<SaleProductsState> {
  final SaleRepository saleRepository;

  SaleProductsSerialNotifier({required this.saleRepository})
      : super(SaleProductsState()) {
    //loadSale();
  }

  void addSaleProduct(
      Product producto, double precio, int? idColor, int? idTalla) {
    try {
      if (producto.idProducto == 0) {
        return;
      }
      List<SaleProduct> saleProducts = state.saleProducts!;

      if (saleProducts
          .where((x) => x.idProducto == producto.idProducto)
          .isNotEmpty) {
        return;
      }

      state = state.copyWith(isLoading: true);

      state = state.copyWith(isLoading: false, saleProducts: [
        ...saleProducts,
        SaleProduct(
            idProducto: producto.idProducto,
            idColor: idColor,
            idTalla: idTalla,
            cantidad: 1,
            precio: precio)
      ]);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }

  void clearSaleProducts() {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, saleProducts: []);
  }

  void removeSaleProductAnItem(int index) {
    List<SaleProduct> saleProducts = state.saleProducts!;
    saleProducts.removeAt(index);

    state = state.copyWith(saleProducts: [...saleProducts]);
  }

  updateSaleProductAnItem(
      int index, double precio, int? idColor, int? idTalla) {
    SaleProduct saleProduct = state.saleProducts![index];
    saleProduct.precio = precio;
    saleProduct.idColor = idColor;
    saleProduct.idTalla = idTalla;

    List<SaleProduct> saleProducts = state.saleProducts!;
    saleProducts[index] = saleProduct;

    state = state.copyWith(saleProducts: [...saleProducts]);
  }

  clearData() {
    state = state.copyWith(saleProducts: []);
  }
}

class SaleProductsState {
  final int? idSale;
  final bool isLoading;
  final bool isSaving;
  final List<SaleProduct>? saleProducts;

  SaleProductsState(
      {this.idSale,
      this.isLoading = true,
      this.isSaving = false,
      this.saleProducts = const []});

  SaleProductsState copyWith({
    int? idSale,
    bool? isLoading,
    bool? isSaving,
    List<SaleProduct>? saleProducts,
  }) =>
      SaleProductsState(
          idSale: idSale ?? this.idSale,
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          saleProducts: saleProducts ?? this.saleProducts);
}
