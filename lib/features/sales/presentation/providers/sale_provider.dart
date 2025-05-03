import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komercia_app/features/sales/domain/entities/sale.dart';
import 'package:komercia_app/features/sales/domain/entities/sale_product.dart';
import 'package:komercia_app/features/sales/domain/repositories/sale_repository.dart';

import 'sale_repository_provider.dart';

final saleProvider =
    StateNotifierProvider.family<SaleNotifier, SaleState, int?>((ref, idSale) {
  final saleRepository = ref.watch(saleRepositoryProvider);

  return SaleNotifier(saleRepository: saleRepository, idSale: idSale ?? 0);
});

class SaleNotifier extends StateNotifier<SaleState> {
  final SaleRepository saleRepository;
  final int idSale;

  SaleNotifier({required this.saleRepository, required this.idSale})
      : super(SaleState(isLoading: true)) {
    loadSale(idSale);
  }

  Future<void> loadSale(int idSale) async {
    try {
      if (state.idSale == 0) {
        state = state.copyWith(
          isLoading: false,
          sale: null,
        );
        return;
      }
      //print("carga inciial");
      final sale = await saleRepository.getSaleById(idSale!);
      // print(sale.toJson());
      state =
          state.copyWith(isLoading: false, sale: sale, idSale: sale.idVenta);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }

  updateSale(Sale sale) {
    state = state.copyWith(sale: sale);
  }
  
  clearData() {
    state = state.copyWith(
        isLoading: false, isSaving: false, sale: null, saleProducts: []);
  }
}

class SaleState {
  final int? idSale;
  final Sale? sale;
  final bool isLoading;
  final bool isSaving;
  final List<SaleProduct>? saleProducts;

  SaleState(
      {this.idSale,
      this.sale,
      this.isLoading = true,
      this.isSaving = false,
      this.saleProducts = const []});

  SaleState copyWith(
          {int? idSale,
          Sale? sale,
          bool? isLoading,
          bool? isSaving,
          List<SaleProduct>? saleProducts}) =>
      SaleState(
          idSale: idSale ?? this.idSale,
          sale: sale ?? this.sale,
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          saleProducts: saleProducts ?? this.saleProducts);
}
