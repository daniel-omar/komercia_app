import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/home/presentation/providers/menu_provider.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/sale_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sale_submission_provider.dart';
import 'package:komercia_app/features/shared/widgets/full_screen_loader.dart';

class SaleDetailScreen extends ConsumerStatefulWidget {
  final int idSale;
  const SaleDetailScreen({super.key, required this.idSale});

  @override
  // ignore: library_private_types_in_public_api
  _SaleDetailScreenState createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(saleProvider(widget.idSale).notifier)
          .loadSaleDetails(widget.idSale);
    });
  }

  void _inactive(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar registro'),
        content: const Text('¿Está seguro de eliminar la venta?'),
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
    await saleSubmissionNotifier.updateActive(widget.idSale, false);
  }

  @override
  Widget build(BuildContext context) {
    final saleState = ref.watch(saleProvider(widget.idSale));

    if (saleState.isLoading) {
      return const FullScreenLoader();
    }

    ref.listen<SaleSubmissionState>(saleSubmissionProvider, (previous, next) {
      if (next.success) {
        ref.read(saleSubmissionProvider.notifier).reset();
        Navigator.pop(context); // bottomsheet

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Venta eliminada con éxito'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3), // Duración del SnackBar
              behavior: SnackBarBehavior.floating),
        );
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage ?? 'Error al eliminar la venta')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la venta'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // RESUMEN DE VENTA
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen de la venta',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Transacción #${saleState.sale!.idVenta}',
                        style: const TextStyle(color: Colors.blue)),
                    const Divider(height: 20),
                    const Text('Concepto',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text(saleState.sale!.concepto,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    const Text('Valor',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    if (saleState.sale!.tieneDescuento) ...[
                      Row(
                        children: [
                          const Text('Valor real: ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(saleState.sale!.total.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Descuento: ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(saleState.sale!.descuento.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                    Text('S/ ${saleState.sale!.totalFinal}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fecha y hora',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        Text(
                            '${saleState.sale!.horaRegistro} | ${saleState.sale!.fechaRegistro}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Método de pago',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        Text(saleState.sale!.tipoPago!.nombreTipoPago),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Referencias totales',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        Text(saleState.saleDetails!.length.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            // LISTADO DE PRODUCTOS
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Listado de productos',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 0,
                        maxHeight:
                            250, // ajusta según espacio disponible antes del botón
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: saleState.saleDetails!.length,
                        itemBuilder: (_, i) {
                          final saleDetail = saleState.saleDetails![i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 1),
                            child: ListTile(
                              leading: const Icon(Icons.gif_box_sharp,
                                  color: Colors.green),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    saleDetail.producto.nombreProducto,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text('${saleDetail.cantidad} und',
                                      style: const TextStyle(fontSize: 16)),
                                  if (!(saleDetail.talla!.codigoTalla ==
                                          "PDT" &&
                                      saleDetail.color!.codigoColor ==
                                          "PDT")) ...[
                                    Text(
                                        '${saleDetail.talla!.nombreTalla} / ${saleDetail.color!.nombreColor}',
                                        style: const TextStyle(fontSize: 15)),
                                  ]
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'S/ ${saleDetail.subTotal}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  Text(
                                    'P.U. S/ ${saleDetail.precio}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ACCIONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (ref
                    .read(menusProvider.notifier)
                    .tienePermisoEdicion("/sale_detail", "Eliminar"))
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          _inactive(context);
                        },
                        icon: const Icon(Icons.delete,
                            size: 40, color: Colors.red),
                      ),
                      // const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
