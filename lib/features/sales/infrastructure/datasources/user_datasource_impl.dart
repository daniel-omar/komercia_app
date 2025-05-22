import 'package:dio/dio.dart';
import 'package:komercia_app/features/home/infrastructure/errors/menu_errors.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class UserDatasourceImpl extends UserDatasource {
  late final dioClient = DioClient();

  UserDatasourceImpl();

  @override
  Future<List<User>> getUsersByProfile(int idProfile) async {
    try {
      final response =
          await dioClient.dio.get('/users/user/get_by_profile/$idProfile');
      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final List<User> Users = [];

      // ignore: no_leading_underscores_for_local_identifiers
      for (final _User in responseMain.data ?? []) {
        Users.add(UserMapper.userJsonToEntity(_User));
      }

      return Users;
    } catch (e) {
      throw Exception(e);
    }
  }
}
