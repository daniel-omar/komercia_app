import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/products/domain/repositories/product_repository.dart';
import 'package:komercia_app/features/products/presentation/providers/product_repository_provider.dart';

final uploadProductsProvider = StateNotifierProvider.autoDispose<
    UploadProductNotifier, UploadProductState>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);

  return UploadProductNotifier(productRepository: productRepository);
});

class UploadProductNotifier extends StateNotifier<UploadProductState> {
  final ProductRepository productRepository;

  UploadProductNotifier({required this.productRepository})
      : super(UploadProductState());

  Future<void> uploadExcel(File file) async {
    try {
      state = UploadProductState(isLoading: true, success: false);
      await productRepository.saveBulk(file);
      state = state.copyWith(isLoading: true, success: true);
    } catch (e) {
      state = state.copyWith(
          isLoading: true,
          success: false,
          errorMessage: "Error al cargar productos.");
    }
  }

  Future<void> downloadExcel() async {
    try {
      await productRepository.downloadTemplateProducts();
    } catch (e) {
      state = state.copyWith(
          isLoading: true, success: false, errorMessage: "Error al descargar");
    }
  }
}

class UploadProductState {
  final bool isLoading;
  final bool success;
  final String errorMessage;

  UploadProductState(
      {this.isLoading = true, this.success = false, this.errorMessage = ''});

  UploadProductState copyWith(
          {bool? isLoading, bool? success, String? errorMessage}) =>
      UploadProductState(
          isLoading: isLoading ?? this.isLoading,
          success: success ?? this.success,
          errorMessage: errorMessage ?? this.errorMessage);
}
