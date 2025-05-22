import 'package:komercia_app/features/sales/domain/entities/user.dart';

abstract class UserDatasource {
  Future<List<User>> getUsersByProfile(int idProfile);
}
