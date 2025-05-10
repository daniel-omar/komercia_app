// Estado para manejar si la huella está habilitada
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricState {
  final bool isFingerprintEnabled;
  final bool hasFingerprintRegistered;
  BiometricState({
    this.isFingerprintEnabled = false,
    this.hasFingerprintRegistered = false,
  });

  BiometricState copyWith({
    bool? isFingerprintEnabled,
    bool? hasFingerprintRegistered,
  }) =>
      BiometricState(
        isFingerprintEnabled: isFingerprintEnabled ?? this.isFingerprintEnabled,
        hasFingerprintRegistered:
            hasFingerprintRegistered ?? this.hasFingerprintRegistered,
      );
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  BiometricNotifier() : super(BiometricState());

  // Método para verificar si la huella está habilitada
  Future<void> checkFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    final huellaHabilitada = prefs.getBool('auth_biometria_activada') ?? false;

    if (huellaHabilitada) {
      state = state.copyWith(
          isFingerprintEnabled: true, hasFingerprintRegistered: true);
    } else {
      state = state.copyWith(
          isFingerprintEnabled: false, hasFingerprintRegistered: false);
    }
  }

  Future<void> saveFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_biometria_activada', true);
  }

  // Autenticar con huella
  Future<bool> authenticateWithFingerprint() async {
    final auth = LocalAuthentication();
    final available = await auth.canCheckBiometrics;

    if (!available) return false;

    try {
      final success = await auth.authenticate(
        localizedReason: 'Escanea tu huella para continuar',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return success;
    } catch (e) {
      print('Error en biometría: $e');
      return false;
    }
  }

  Future<bool> canCheckFingerprint() async {
    final auth = LocalAuthentication();
    final available = await auth.canCheckBiometrics;
    return available;
  }

  Future<bool> clearFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_biometria_activada', false);
    return true;
  }

  Future<void> changeIsFingerprintEnabled(bool enable) async {
    state = state.copyWith(isFingerprintEnabled: enable);
  }
}

// Provider para manejar el estado de la huella
final biometricProvider =
    StateNotifierProvider.autoDispose<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier();
});
