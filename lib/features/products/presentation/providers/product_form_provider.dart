import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/presentation/providers/product_provider.dart';
import 'package:komercia_app/features/shared/shared.dart';

//! 3 - StateNotifierProvider - consume afuera
final productFormProvider = StateNotifierProvider.autoDispose
    .family<ProductFormNotifier, ProductFormState, int>((ref, idProduct) {
  final productState = ref.watch(productProvider(idProduct));
  final product = productState.producto;

  final updateProductCallback =
      ref.watch(productProvider(idProduct).notifier).updateProduct;

  return ProductFormNotifier(
      product: product, updateProductCallback: updateProductCallback);
});

//! 2 - Como implementamos un notifier
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final Function(Product) updateProductCallback;
  ProductFormNotifier(
      {required Product? product, required this.updateProductCallback})
      : super(ProductFormState()) {
    initForm(product);
  }

  initForm(Product? product) {
    //state = state.copyWith(nombre: const Title.dirty("ddd"));
    if (product == null) return;

    state = state.copyWith(
        isLoading: false,
        idProduct: product.idProducto,
        code: product.codigoProducto,
        name: TextField.dirty(product.nombreProducto),
        description: TextField.dirty(product.descripcionProducto ?? ""),
        pursharsePrice: Price.dirty(product.precioCompra ?? 0),
        salePrice: Price.dirty(product.precioVenta ?? 0),
        idCategory: product.idCategoria,
        isActive: product.esActivo ?? false);
  }

  onNameChange(String value) {
    final newName = TextField.dirty(value);
    state = state.copyWith(
        name: newName,
        isValid: Formz.validate([
          newName,
          // state.description,
          state.salePrice,
          state.pursharsePrice
        ]));
  }

  onDescriptionChanged(String value) {
    final newDescription = TextField.dirty(value);
    state = state.copyWith(
        description: newDescription,
        isValid: Formz.validate([
          // newDescription,
          state.name,
          state.salePrice,
          state.pursharsePrice
        ]));
  }

  onPurcharsePriceChanged(String value) {
    final newPurcharsePrice = Price.dirty(double.tryParse(value) ?? 0);
    state = state.copyWith(
        pursharsePrice: newPurcharsePrice,
        isValid: Formz.validate([
          newPurcharsePrice,
          state.name,
          state.salePrice,
          // state.description
        ]));
  }

  onSalePriceChanged(String value) {
    final newSalePrice = Price.dirty(double.tryParse(value) ?? 0);
    state = state.copyWith(
        salePrice: newSalePrice,
        isValid: Formz.validate([
          newSalePrice,
          state.name,
          // state.description,
          state.pursharsePrice
        ]));
  }

  void onCategoryChanged(int? idCategoria) {
    state = state.copyWith(idCategory: idCategoria);
    _touchEveryField();
  }

  onFormUpdateSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;

    state = state.copyWith(isPosting: true);

    final product = Product(
        idProducto: state.idProduct,
        codigoProducto: state.code,
        nombreProducto: state.name.value,
        descripcionProducto: state.description.value,
        precioCompra: state.pursharsePrice.value,
        precioVenta: state.salePrice.value,
        idCategoria: state.idCategory);

    await updateProductCallback(product);

    // state = state.copyWith(isPosting: false);
  }

  _touchEveryField() {
    final name = TextField.dirty(state.name.value);
    final description = TextField.dirty(state.description.value);
    final salePrice = Price.dirty(state.salePrice.value);
    final pursharsePrice = Price.dirty(state.pursharsePrice.value);

    state = state.copyWith(
        isFormPosted: true,
        name: name,
        description: description,
        salePrice: salePrice,
        pursharsePrice: pursharsePrice,
        isValid: Formz.validate([name, salePrice, pursharsePrice]));
  }
}

//! 1 - State del provider
class ProductFormState {
  final bool isLoading;
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final int idProduct;
  final String code;
  final TextField name;
  final TextField description;
  final Price pursharsePrice;
  final Price salePrice;
  final int idCategory;
  final bool isActive;

  ProductFormState(
      {this.isLoading = true,
      this.isPosting = false,
      this.isFormPosted = false,
      this.isValid = false,
      this.idProduct = 0,
      this.code = "",
      this.name = const TextField.pure(),
      this.description = const TextField.pure(),
      this.pursharsePrice = const Price.pure(),
      this.salePrice = const Price.pure(),
      this.idCategory = 0,
      this.isActive = false});

  ProductFormState copyWith(
          {bool? isLoading,
          bool? isPosting,
          bool? isFormPosted,
          bool? isValid,
          int? idProduct,
          String? code,
          TextField? name,
          TextField? description,
          Price? pursharsePrice,
          Price? salePrice,
          int? idCategory,
          bool? isObscurePassword,
          bool? isActive}) =>
      ProductFormState(
          isLoading: isLoading ?? this.isLoading,
          isPosting: isPosting ?? this.isPosting,
          isFormPosted: isFormPosted ?? this.isFormPosted,
          isValid: isValid ?? this.isValid,
          idProduct: idProduct ?? this.idProduct,
          code: code ?? this.code,
          name: name ?? this.name,
          description: description ?? this.description,
          pursharsePrice: pursharsePrice ?? this.pursharsePrice,
          salePrice: salePrice ?? this.salePrice,
          idCategory: idCategory ?? this.idCategory,
          isActive: isActive ?? this.isActive);

  @override
  String toString() {
    return '''
  ProductFormState:
    isPosting: $isPosting
    isFormPosted: $isFormPosted
    isValid: $isValid
''';
  }
}
