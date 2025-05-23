import 'package:komercia_app/features/auth/domain/entities/auth_token.dart';
import 'package:komercia_app/features/auth/domain/entities/permission.dart';

import '../entities/user.dart';

abstract class AuthDataSource {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String fullName);
  Future<User> checkAuthStatus(String token);
  Future<AuthToken> refresh(String refreshToken);
}
