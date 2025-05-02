import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/payment_type_repository_provider.dart';

final selectedPaymentTypeIndexProvider = StateProvider<int?>((ref) => null);
final selectedPaymentTypeProvider = StateProvider<PaymentType?>((ref) => null);

final paymentTypesProvider = StateNotifierProvider.autoDispose<
    PaymentTypesNotifier,
    PaymentTypesState
    //int
    >((ref) {
  final paymentTypeRepository = ref.watch(paymentTypeRepositoryProvider);

  return PaymentTypesNotifier(
    paymentTypeRepository: paymentTypeRepository,
    //idPaymentType: idPaymentType,
  );
});

class PaymentTypesNotifier extends StateNotifier<PaymentTypesState> {
  final PaymentTypeRepository paymentTypeRepository;

  PaymentTypesNotifier({
    required this.paymentTypeRepository,
    //required int? idPaymentType,
  }) : super(PaymentTypesState()) {
    loadPaymentTypes();
  }

  Future<void> loadPaymentTypes() async {
    try {
      state = state.copyWith(isLoading: true);

      Map<String, dynamic> body = {};

      final paymentTypes = await paymentTypeRepository.getAll();

      state = state.copyWith(isLoading: false, paymentTypes: paymentTypes);
    } catch (e) {
      // 404 product not found
      print(e);
    }
  }
}

class PaymentTypesState {
  final bool isLoading;
  final bool isSaving;
  final List<PaymentType>? paymentTypes;

  PaymentTypesState({
    this.isLoading = true,
    this.isSaving = false,
    this.paymentTypes,
  });

  PaymentTypesState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<PaymentType>? paymentTypes,
  }) =>
      PaymentTypesState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        paymentTypes: paymentTypes ?? this.paymentTypes,
      );
}
