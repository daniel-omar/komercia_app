import 'package:komercia_app/features/auth/domain/entities/auth_token.dart';

class AuthTokenMapper {
  static AuthToken authTokenJsonToEntity(Map<String, dynamic> json) =>
      AuthToken(
          token: json['token'] ?? '',
          refreshToken: json['refreshToken'] ?? '');
}
