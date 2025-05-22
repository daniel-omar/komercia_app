import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/user_repository_provider.dart';

final usersProvider = StateNotifierProvider.autoDispose
    .family<UsersNotifier, UsersState, int>((ref, idPerfil) {
  final userRepository = ref.watch(userRepositoryProvider);

  return UsersNotifier(userRepository: userRepository, idPerfil: idPerfil);
});

class UsersNotifier extends StateNotifier<UsersState> {
  final UserRepository userRepository;

  UsersNotifier({
    required this.userRepository,
    required int idPerfil,
  }) : super(UsersState()) {
    loadUsers(idPerfil);
  }

  Future<void> loadUsers(int idPerfil) async {
    try {
      state = state.copyWith(isLoading: true);

      final users = await userRepository.getUsersByProfile(idPerfil);

      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class UsersState {
  final bool isLoading;
  final bool isSaving;
  final List<User>? users;

  UsersState({
    this.isLoading = true,
    this.isSaving = false,
    this.users,
  });

  UsersState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<User>? users,
  }) =>
      UsersState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        users: users ?? this.users,
      );
}
