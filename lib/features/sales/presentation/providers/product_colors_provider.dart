import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_color_repository_provider.dart';

final productColorsProvider = StateNotifierProvider<
    ProductColorsNotifier,
    ProductColorsState
    //int
    >((ref) {
  final productColorRepository = ref.watch(productColorRepositoryProvider);

  return ProductColorsNotifier(
    productColorRepository: productColorRepository,
    //idProductColor: idProductColor,
  );
});

class ProductColorsNotifier extends StateNotifier<ProductColorsState> {
  final ProductColorRepository productColorRepository;

  ProductColorsNotifier({
    required this.productColorRepository,
    //required int? idProductColor,
  }) : super(ProductColorsState()) {
    // loadColors();
  }

  Future<void> loadColors() async {
    try {
      state = state.copyWith(isLoading: true);

      Map<String, dynamic> body = {};
      // body["es_seriado"] = true;

      final productColors = await productColorRepository.getAll();

      state = state.copyWith(isLoading: false, productColors: productColors);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }

  Future<void> loadColorsByProduct(int idProducto) async {
    try {
      state = state.copyWith(isLoading: true);

      final productColors =
          await productColorRepository.getByProduct(idProducto);

      state = state.copyWith(isLoading: false, productColors: productColors);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }

  Future<void> loadColorsByFilters(int idProducto, int idTalla) async {
    try {
      state = state.copyWith(isLoading: true);

      final productColors = await productColorRepository.getList(
          idProducto: idProducto, idTalla: idTalla);

      state = state.copyWith(isLoading: false, productColors: productColors);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class ProductColorsState {
  final bool isLoading;
  final bool isSaving;
  final List<ProductColor>? productColors;

  ProductColorsState({
    this.isLoading = true,
    this.isSaving = false,
    this.productColors,
  });

  ProductColorsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ProductColor>? productColors,
  }) =>
      ProductColorsState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        productColors: productColors ?? this.productColors,
      );
}

final productColorsBySizeProvider = FutureProvider.family
    .autoDispose<List<ProductColor>, (int idProducto, int idTalla)>(
        (ref, tuple) async {
  final repository = ref.watch(productColorRepositoryProvider);
  final (idProducto, idTalla) = tuple;

  return await repository.getList(idProducto: idProducto, idTalla: idTalla);
});
