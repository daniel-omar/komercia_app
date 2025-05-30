import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedProductsProvider =
    StateNotifierProvider<SelectedProductsNotifier, List<int>>((ref) {
  return SelectedProductsNotifier();
});

class SelectedProductsNotifier extends StateNotifier<List<int>> {
  SelectedProductsNotifier() : super([]);

  void toggleProduct(int idProduct) {
    if (state.contains(idProduct)) {
      state = state.where((p) => p != idProduct).toList();
    } else {
      state = [...state, idProduct];
    }
  }

  void clear() {
    state = [];
  }
}
