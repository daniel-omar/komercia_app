import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/entities/sale_product.dart';
import 'package:komercia_app/features/sales/presentation/providers/discount_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/payment_types_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/products_purchase_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sale_submission_provider.dart';
import 'package:komercia_app/features/sales/presentation/widgets/payment_type_card.dart';

class PaymentTypeBottomSheet extends ConsumerWidget {
  const PaymentTypeBottomSheet({super.key});

  void _handlePayment(BuildContext context, WidgetRef ref) async {
    final selectedPaymentType = ref.read(selectedPaymentTypeProvider);

    // Activa el modo de validación visual
    ref.read(showProductPurchaseValidationErrorsProvider.notifier).state = true;

    if (selectedPaymentType == null) {
      Navigator.pop(context); // bottomsheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un método de pago')),
      );
      return;
    }

    final productsPurchaseState = ref.read(productsPurchaseProvider);

    final hasInvalid =
        productsPurchaseState.any((p) => (p.idTalla == 0 || p.idColor == 0));

    if (hasInvalid) {
      Navigator.pop(context); // bottomsheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Todos los productos deben tener talla y color.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar registro'),
        content: const Text('¿Está seguro de registrar la venta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == false) return;

    final saleSubmissionNotifier = ref.read(saleSubmissionProvider.notifier);
    final saleProducts = productsPurchaseState
        .map((e) => SaleProduct(
              idProducto: e.idProducto,
              cantidad: e.cantidad,
              precio: e.precio!,
              idColor: e.idColor,
              idTalla: e.idTalla,
              sub_total: e.total,
            ))
        .toList();

    final discount = ref.read(discountProvider);
    double amountDiscount = discount.monto;
    String discountType = discount.type.name;

    await saleSubmissionNotifier.submitSale(saleProducts,
        selectedPaymentType.idTipoPago, discountType, amountDiscount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentTypesProvider);
    final selectedIndex = ref.watch(selectedPaymentTypeIndexProvider);
    final saleSubmissionState = ref.watch(saleSubmissionProvider);

    ref.listen<SaleSubmissionState>(saleSubmissionProvider, (previous, next) {
      if (next.success) {
        ref.read(saleSubmissionProvider.notifier).reset();
        ref.read(productsPurchaseProvider.notifier).clear();
        ref.read(discountProvider.notifier).state = DiscountState.none();

        Navigator.pop(context); // bottomsheet
        Navigator.pop(context); // volver a la pantalla de venta

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada con éxito')),
        );
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage ?? 'Error al registrar venta')),
        );
      }
    });

    if (state.isLoading || state.paymentTypes == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FractionallySizedBox(
      widthFactor: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                const Text(
                  'Selecciona el método de pago',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              itemCount: state.paymentTypes!.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final paymentType = state.paymentTypes![index];
                final isSelected = selectedIndex == index;

                return PaymentTypeCard(
                  label: paymentType.nombreTipoPago,
                  icon: paymentType.iconData,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedPaymentTypeIndexProvider.notifier).state =
                        index;
                    ref.read(selectedPaymentTypeProvider.notifier).state =
                        paymentType;
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saleSubmissionState.isSaving
                    ? null
                    : () => _handlePayment(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: saleSubmissionState.isSaving
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'REGISTRAR VENTA',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
