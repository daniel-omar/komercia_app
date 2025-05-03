import 'package:flutter_riverpod/flutter_riverpod.dart';

final discountProvider = StateProvider<DiscountState>((ref) {
  return DiscountState.none(); // sin descuento por defecto
});

class DiscountState {
  final double monto; // si es monto fijo, representa el descuento
  final DiscountType type;

  DiscountState({
    required this.monto,
    required this.type,
  });

  factory DiscountState.none() =>
      DiscountState(monto: 0, type: DiscountType.none);

  bool get hasDiscount => type != DiscountType.none;

  double apply(double total) {
    switch (type) {
      case DiscountType.fixed:
        return (total - monto).clamp(0, double.infinity);
      case DiscountType.percent:
        return total - (total * (monto / 100));
      default:
        return total;
    }
  }
}

enum DiscountType { none, fixed, percent }
