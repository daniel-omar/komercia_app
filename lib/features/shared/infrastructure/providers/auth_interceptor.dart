import 'package:dio/dio.dart';
import 'package:komercia_app/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:komercia_app/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:komercia_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';

class AuthInterceptor implements Interceptor {
  final KeyValueStorageService keyValueStorageService =
      KeyValueStorageServiceImpl();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    bool isAuth = options.headers['is_auth'] ?? false;
    if (isAuth == true) {
      return handler.next(options);
    }

    final token = await keyValueStorageService.getValue<String>('token');
    options.headers.addAll({'authorization': "Bearer $token"});

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshing = err.requestOptions.extra["retry"] == true;
    final isLogin = err.requestOptions.path.contains("auth/login");

    if (isUnauthorized && !isRefreshing && !isLogin) {
      try {
        final refreshToken =
            await keyValueStorageService.getValue<String>('refresh_token');

        final authRepository = AuthRepositoryImpl();
        final responseRefresh = await authRepository.refresh(refreshToken!);
        String newToken = responseRefresh.token!;
        await keyValueStorageService.setKeyValue('token', newToken);

        // 🔁 2. Reintenta la petición original con el nuevo token
        final retryOptions = err.requestOptions;
        retryOptions.headers['authorization'] = 'Bearer $newToken';
        retryOptions.extra['retry'] = true;

        final clonedResponse = await Dio().fetch(retryOptions);
        return handler.resolve(clonedResponse);
      } catch (e) {
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: 'Sesión expirada. Iniciar sesión nuevamente',
          ),
        );
      }
    }
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseData = response.data;
    if (response.realUri.path.contains("generate_tags") ||
        response.realUri.path.contains("download_template_products")) {
      return handler.next(response);
    }
    if (responseData is Map) {
      return handler.next(response);
    }
    return handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        error: 'The response is not in valid format',
      ),
    );
  }
}
