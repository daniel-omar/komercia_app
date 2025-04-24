import 'package:dio/dio.dart';
import 'package:komercia_app/config/constants/environment.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/auth_interceptor.dart';

class DioClient {
  DioClient() {
    addInterceptor(AuthInterceptor());
  }

  final Dio dio = Dio(
    BaseOptions(baseUrl: Environment.apiUrl),
  );

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}
