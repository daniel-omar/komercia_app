import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:komercia_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
      authRepository: authRepository,
      keyValueStorageService: keyValueStorageService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = await authRepository.login(email, password);
      _setPreferencesLoginUser(email, password);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logout(e.message);
    } catch (e) {
      logout('Error no controlado');
    }

    // final user = await authRepository.login(email, password);
    // state =state.copyWith(user: user, authStatus: AuthStatus.authenticated)
  }

  void registerUser(String email, String password) async {}

  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if (token == null) return logout();

    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    await keyValueStorageService.setKeyValue<String>('token', user.token!);
    await keyValueStorageService.setKeyValue<String>(
        'refresh_token', user.refreshToken!);
    await keyValueStorageService.setKeyValue<String>(
        'user', jsonEncode(user.toJson()));

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
    );
  }

  void _setPreferencesLoginUser(String correo, String clave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('correo', correo);
    await prefs.setString('clave', clave);
  }

  void _clearPreferencesLoginUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('correo', '');
    await prefs.setString('clave', '');
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorageService.removeKey('token');
    await keyValueStorageService.removeKey('user');

    state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: errorMessage);
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState(
      {this.authStatus = AuthStatus.checking,
      this.user,
      this.errorMessage = ''});

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
          authStatus: authStatus ?? this.authStatus,
          user: user ?? this.user,
          errorMessage: errorMessage ?? this.errorMessage);
}
