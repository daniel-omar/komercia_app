import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komercia_app/features/sales/domain/entities/sale.dart';
import 'package:komercia_app/features/sales/domain/entities/sale_product.dart';
import 'package:komercia_app/features/sales/domain/repositories/sale_repository.dart';

import 'sale_repository_provider.dart';

final saleSubmissionProvider = StateNotifierProvider.autoDispose<
    SaleSubmissionNotifier, SaleSubmissionState>(
  (ref) =>
      SaleSubmissionNotifier(saleRepository: ref.watch(saleRepositoryProvider)),
);

class SaleSubmissionNotifier extends StateNotifier<SaleSubmissionState> {
  final SaleRepository saleRepository;

  SaleSubmissionNotifier({required this.saleRepository})
      : super(const SaleSubmissionState());

  Future<void> submitSale(List<SaleProduct> saleProducts, int idTipoPago,
      String? tipoDescuento, double? montoDescuento, String? concepto) async {
    try {
      state = state.copyWith(
          isSaving: true, hasError: false, errorMessage: null, success: false);

      final sale = {
        'id_tipo_pago': idTipoPago,
        'tipo_descuento': tipoDescuento,
        'monto_descuento': montoDescuento,
        'concepto': concepto,
        'productos': saleProducts.map((e) => e.toJson()).toList()
      };
      await saleRepository.createSale(sale);
      state = state.copyWith(isSaving: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        hasError: true,
        errorMessage: e.toString(),
        success: false,
      );
    }
  }

  Future<void> updateActive(int idVenta, bool esActivo) async {
    try {
      state = state.copyWith(
          isSaving: true, hasError: false, errorMessage: null, success: false);

      final sale = {'id_venta': idVenta, 'es_activo': esActivo};
      await saleRepository.updateActive(sale);

      state = state.copyWith(isSaving: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        hasError: true,
        errorMessage: e.toString(),
        success: false,
      );
    }
  }

  void reset() {
    state = const SaleSubmissionState();
  }
}

class SaleSubmissionState {
  final bool isSaving;
  final bool hasError;
  final String? errorMessage;
  final bool success;

  const SaleSubmissionState({
    this.isSaving = false,
    this.hasError = false,
    this.errorMessage,
    this.success = false,
  });

  SaleSubmissionState copyWith({
    bool? isSaving,
    bool? hasError,
    String? errorMessage,
    bool? success,
  }) =>
      SaleSubmissionState(
        isSaving: isSaving ?? this.isSaving,
        hasError: hasError ?? this.hasError,
        errorMessage: errorMessage ?? this.errorMessage,
        success: success ?? this.success,
      );
}
