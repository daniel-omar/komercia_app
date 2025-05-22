import 'package:dio/dio.dart';
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshing = err.requestOptions.extra["retry"] == true;

    if (isUnauthorized && !isRefreshing) {
      // navigate to the authentication screen
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'The user has been deleted or the session is expired',
        ),
      );
    }
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseData = response.data;
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
