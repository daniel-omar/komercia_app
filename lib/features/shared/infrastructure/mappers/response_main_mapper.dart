import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/shared/infrastructure/entities/response_main.dart';

class ResponseMainMapper {
  static ResponseMain responseJsonToEntity(Map<String, dynamic> json) =>
      ResponseMain(
          status: json["status"], data: json["data"], message: json["message"]);
}
