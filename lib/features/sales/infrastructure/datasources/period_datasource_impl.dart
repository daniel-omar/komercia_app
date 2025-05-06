import 'package:dio/dio.dart';
import 'package:komercia_app/features/sales/domain/datasources/period_datasource.dart';
import 'package:komercia_app/features/sales/domain/entities/period.dart';
import 'package:komercia_app/features/sales/infrastructure/mappers/period_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class PeriodDatasourceImpl extends PeriodDatasource {
  late final dioClient = DioClient();

  PeriodDatasourceImpl();

  @override
  Future<List<Period>> getAll() async {
    final response = await dioClient.dio.get('/general/payment_type/get_all');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final List<Period> periods = [];

    // ignore: no_leading_underscores_for_local_identifiers
    for (final _period in responseMain.data ?? []) {
      periods.add(PeriodMapper.periodJsonToEntity(_period));
    }

    return periods;
  }

  @override
  Future<PeriodGroup> getToFilter() async {
    final response =
        await dioClient.dio.get('/general/period/get_to_filters');
    ResponseMain responseMain =
        ResponseMainMapper.responseJsonToEntity(response.data);

    final periodGroup = PeriodMapper.periodGroupJsonToEntity(responseMain.data);

    return periodGroup;
  }
}
