import 'package:komercia_app/features/sales/domain/domain.dart';

class UserRepositoryImpl extends UserRepository {
  final UserDatasource datasource;

  UserRepositoryImpl(this.datasource);

  @override
  Future<List<User>> getUsersByProfile(int idProfile) {
    return datasource.getUsersByProfile(idProfile);
  }
}
