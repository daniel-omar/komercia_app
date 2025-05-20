import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/shared/infrastructure/services/internet_connectivity_checker.dart';

class InternetConnectionNotifier extends StateNotifier<ConnectivityState> {
  final InternetConnectivityChecker _connectivityService;

  InternetConnectionNotifier(this._connectivityService)
      : super(ConnectivityState.connected) {
    _connectivityService.connectionChange.listen((isConnected) {
      state = isConnected
          ? ConnectivityState.connected
          : ConnectivityState.disconnected;
    });
  }
}

//
final internetConnectivityCheckerProvider =
    Provider<InternetConnectivityChecker>((ref) {
  return InternetConnectivityChecker();
});

final connectionProvider =
    StateNotifierProvider<InternetConnectionNotifier, ConnectivityState>(
  (ref) {
    final connection = ref.watch(internetConnectivityCheckerProvider);
    return InternetConnectionNotifier(
      connection,
    );
  },
);

enum ConnectivityState {
  disconnected,
  connected,
}
