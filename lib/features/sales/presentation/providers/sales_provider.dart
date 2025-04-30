import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/entities/sale.dart';
import 'package:komercia_app/features/sales/domain/repositories/sale_repository.dart';
import 'package:komercia_app/features/sales/presentation/providers/sale_repository_provider.dart';

final salesProvider = StateNotifierProvider<SalesNotifier, SalesState>((ref) {
  final salesRepository = ref.watch(saleRepositoryProvider);

  return SalesNotifier(salesRepository: salesRepository);
});

class SalesNotifier extends StateNotifier<SalesState> {
  final SaleRepository salesRepository;

  SalesNotifier({
    required this.salesRepository,
  }) : super(SalesState());

  Future getSalesByUser(int idTecnico, {int? idEstadoOrden}) async {
    // if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final sales = await salesRepository.getSalesByUser(idTecnico);

    if (sales.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        sales: sales);
  }
}

class SalesState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Sale> sales;

  SalesState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.sales = const []});

  SalesState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Sale>? sales,
  }) =>
      SalesState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        sales: sales ?? this.sales,
      );
}
