import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:komercia_app/features/home/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final menuRepository = MenuRepositoryImpl(MenuDatasourceImpl());

  return menuRepository;
});
