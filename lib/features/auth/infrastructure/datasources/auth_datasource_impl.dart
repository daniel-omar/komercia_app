import 'package:dio/dio.dart';
import 'package:komercia_app/config/constants/environment.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/domain/entities/auth_token.dart';
import 'package:komercia_app/features/auth/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/auth/infrastructure/mappers/auth_token_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';
import 'package:komercia_app/features/shared/infrastructure/mappers/response_main_mapper.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/dio_client.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dioClient = DioClient();
  // final Dio? dio;
  // AuthDataSourceImpl({this.dio});

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final response = await dioClient.dio.get('/auth/check-status',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError('Token incorrecto');
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dioClient.dio.post('/auth/login',
          data: {'correo': email, 'clave': password},
          options: Options(
            headers: {
              "is_auth": true,
            },
          ));

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final user = UserMapper.userLoginJsonToEntity(responseMain.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError(
            e.response?.data['message'] ?? 'Credenciales incorrectas');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<AuthToken> refresh(String refreshToken) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      ResponseMain responseMain =
          ResponseMainMapper.responseJsonToEntity(response.data);

      final authToken =
          AuthTokenMapper.authTokenJsonToEntity(responseMain.data);
      return authToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError(
            e.response?.data['message'] ?? 'Credenciales incorrectas');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> register(String email, String password, String fullName) {
    // TODO: implement register
    throw UnimplementedError();
  }
}
