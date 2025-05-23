import 'package:dio/dio.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/domain/entities/auth_token.dart';
import '../infrastructure.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;
  // final Dio? dio;

  AuthRepositoryImpl({
    AuthDataSource? dataSource,
    // this.dio,
  }) : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<User> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<User> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<User> register(String email, String password, String fullName) {
    return dataSource.register(email, password, fullName);
  }

  @override
  Future<AuthToken> refresh(String refreshToken) {
    return dataSource.refresh(refreshToken);
  }
}
