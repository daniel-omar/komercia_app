import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final UserRepository =
      UserRepositoryImpl(UserDatasourceImpl());
  return UserRepository;
});
