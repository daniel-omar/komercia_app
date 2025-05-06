import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';

final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  final periodRepository = PeriodRepositoryImpl(PeriodDatasourceImpl());
  return periodRepository;
});

final dateFilterProvider =
    StateNotifierProvider.autoDispose<DateFilterNotifier, DateFilterState>(
        (ref) {
  final periodRepository = ref.watch(periodRepositoryProvider);

  return DateFilterNotifier(
    periodRepository: periodRepository,
    //idProductColor: idProductColor,
  ); // sin descuento por defecto
});

class DateFilterNotifier extends StateNotifier<DateFilterState> {
  final PeriodRepository periodRepository;

  DateFilterNotifier({
    required this.periodRepository,
    //required int? idProductColor,
  }) : super(DateFilterState()) {
    getDateToFilter();
  }

  Future<void> getDateToFilter() async {
    try {
      state = state.copyWith(isLoading: true);

      // Aquí haces la solicitud a la API que retorna todos los días, semanas, meses y años
      final response = await periodRepository.getToFilter();

      // Almacenas la respuesta en el estado
      state = DateFilterState(
          isLoading: false,
          dias: response.dias,
          semanas: response.semanas,
          meses: response.meses,
          anios: response.anios);
      state = state.copyWith(periodSelect: state.rangos.last);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error fetching date filters: $e');
    }
  }

  void setDateFilterType(DateFilterType type) {
    state = state.copyWith(tipoFiltro: type);
    state = state.copyWith(periodSelect: state.rangos.last);
  }

  void setPeriod(Period period) {
    state = state.copyWith(periodSelect: period);
  }
}

// Definición de la clase de estado
class DateFilterState {
  final bool isLoading;
  final List<Period> dias;
  final List<Period> semanas;
  final List<Period> meses;
  final List<Period> anios;
  final DateFilterType tipoFiltro;
  final Period? periodSelect;

  DateFilterState(
      {this.isLoading = false,
      this.dias = const [],
      this.semanas = const [],
      this.meses = const [],
      this.anios = const [],
      this.tipoFiltro = DateFilterType.days,
      this.periodSelect});

  DateFilterState copyWith(
          {bool? isLoading,
          List<Period>? dias,
          List<Period>? semanas,
          List<Period>? meses,
          List<Period>? anios,
          Period? periodSelect,
          DateFilterType? tipoFiltro}) =>
      DateFilterState(
          isLoading: isLoading ?? this.isLoading,
          dias: dias ?? this.dias,
          semanas: semanas ?? this.semanas,
          meses: meses ?? this.meses,
          anios: anios ?? this.anios,
          periodSelect: periodSelect ?? this.periodSelect,
          tipoFiltro: tipoFiltro ?? this.tipoFiltro);

  List<Period> get rangos {
    switch (tipoFiltro) {
      case DateFilterType.days:
        return dias;
      case DateFilterType.weeks:
        return semanas;
      case DateFilterType.months:
        return meses;
      case DateFilterType.years:
        return anios;
      default:
        return [];
    }
  }
}

class DateFilter {
  DateFilterType type;
  String name;

  DateFilter({required this.type, required this.name});
}

enum DateFilterType { days, weeks, months, years, customized }
