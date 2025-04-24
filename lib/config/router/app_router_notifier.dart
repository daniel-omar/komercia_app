import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';

final goRouterNotifierProvider = Provider((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return GoRouterNotifier(authNotifier);
});

class GoRouterNotifier extends ChangeNotifier {
  final AuthNotifier _authNotifier;

  AuthStatus _authStatus = AuthStatus.checking;
  User _user = User(
      nombre: "test",
      apellidoPaterno: "apellidoPaterno",
      apellidoMaterno: "apellidoMaterno",
      idTipoDocumento: 0,
      numeroDocumento: "numeroDocumento",
      correo: "correo",
      idPerfil: 1,
      esActivo: true,
      nombrePerfil: "nombrePerfil");

  GoRouterNotifier(this._authNotifier) {
    _authNotifier.addListener((state) {
      authStatus = state.authStatus;
      if (authStatus == AuthStatus.authenticated) {
        user = state.user!;
        print(user);
      }
    });
  }

  AuthStatus get authStatus => _authStatus;

  set authStatus(AuthStatus value) {
    _authStatus = value;
    notifyListeners();
  }

  User get user => _user;
  set user(User value) {
    _user = value;
    notifyListeners();
  }
}
