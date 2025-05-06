import 'package:komercia_app/features/sales/domain/entities/period.dart';

abstract class PeriodRepository {
  Future<List<Period>> getAll();
  Future<PeriodGroup> getToFilter();
}
