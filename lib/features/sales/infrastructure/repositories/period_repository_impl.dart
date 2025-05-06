import 'package:komercia_app/features/sales/domain/domain.dart';

class PeriodRepositoryImpl extends PeriodRepository {
  final PeriodDatasource datasource;

  PeriodRepositoryImpl(this.datasource);
  @override
  Future<List<Period>> getAll() {
    return datasource.getAll();
  }

  @override
  Future<PeriodGroup> getToFilter() {
    return datasource.getToFilter();
  }
}
