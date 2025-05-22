import 'package:flutter_riverpod/flutter_riverpod.dart';

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void toggleTipoPago(int metodo) {
    final selected = [...state.tiposPagoSeleccionados];
    if (selected.contains(metodo)) {
      selected.remove(metodo);
    } else {
      selected.add(metodo);
    }
    state = state.copyWith(tiposPagoSeleccionados: selected);
  }

  void toggleEmpleado(int idEmpleado) {
    final selected = [...state.empleadosSeleccionados];
    if (selected.contains(idEmpleado)) {
      selected.remove(idEmpleado);
    } else {
      selected.add(idEmpleado);
    }
    state = state.copyWith(empleadosSeleccionados: selected);
  }

  void clearEmpleado() {
    state = state.copyWith(empleadosSeleccionados: []);
  }

  void reset() {
    state = const FilterState();
  }
}

// Definición de la clase de estado
class FilterState {
  final List<int> tiposPagoSeleccionados;
  final List<int> empleadosSeleccionados;

  const FilterState({
    this.tiposPagoSeleccionados = const [],
    this.empleadosSeleccionados = const [],
  });

  FilterState copyWith({
    List<int>? tiposPagoSeleccionados,
    List<int>? empleadosSeleccionados,
  }) {
    return FilterState(
      tiposPagoSeleccionados:
          tiposPagoSeleccionados ?? this.tiposPagoSeleccionados,
      empleadosSeleccionados:
          empleadosSeleccionados ?? this.empleadosSeleccionados,
    );
  }
}
