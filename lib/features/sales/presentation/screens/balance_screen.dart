import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/sales/domain/entities/sale.dart';
import 'package:komercia_app/features/sales/presentation/providers/date_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/filter_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sale_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sale_submission_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sales_provider.dart';

class BalanceScreen extends ConsumerStatefulWidget {
  const BalanceScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends ConsumerState<BalanceScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // final dateFilter = ref.watch(dateFilterProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFilter = ref.watch(dateFilterProvider);
    final sales = ref.watch(salesProvider);

    if (dateFilter.isLoading) {
      // Mostrar un loader mientras se obtienen los datos
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateSelector(), // Ocupa todo el espacio disponible
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const _DateFilterOptions(),
                  );
                },
              ),
            ],
          ),
          _BalanceCard(
            totalIncome: sales.sumTotalSales,
            sales: sales.sales,
          ),
          const SizedBox(height: 10),
          _SalesList(sales: sales.sales),
        ],
      ),
      bottomNavigationBar: const _BottomActions(),
    );
  }
}

class _DateSelector extends ConsumerStatefulWidget {
  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends ConsumerState<_DateSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();

      final dateFilter = ref.read(dateFilterProvider);

      if (dateFilter.periodSelect != null) {
        ref.read(salesProvider.notifier).getSalesByFilter(
              fechaInicio: dateFilter.periodSelect!.fechaInicio,
              fechaFin: dateFilter.periodSelect!.fechaFin,
            );
      }
    });
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Limpieza del controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFilter = ref.watch(dateFilterProvider);
    final filtros = ref.watch(filterProvider);

    ref.listen<DateFilterState>(dateFilterProvider, (previous, next) {
      if (next.periodSelect!.etiqueta != previous?.periodSelect!.etiqueta) {
        ref.read(salesProvider.notifier).getSalesByFilter(
              fechaInicio: next.periodSelect!.fechaInicio,
              fechaFin: next.periodSelect!.fechaFin,
              idsTipoPago: filtros.tiposPagoSeleccionados,
              idsUsuarioRegistro: filtros.empleadosSeleccionados,
            );
      } else if (next.tipoFiltro != previous?.tipoFiltro) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToEnd();
        });
      }
    });

    ref.listen<SaleSubmissionState>(saleSubmissionProvider, (previous, next) {
      if (!next.isSaving && next.success) {
        ref.read(salesProvider.notifier).getSalesByFilter(
            fechaInicio: dateFilter.periodSelect!.fechaInicio,
            fechaFin: dateFilter.periodSelect!.fechaFin);
      }
    });

    return SizedBox(
      height: 45,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: dateFilter.rangos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final date = dateFilter.rangos[index];
          final isSelected =
              date.etiqueta == dateFilter.periodSelect!.etiqueta; // ejemplo
          return ChoiceChip(
            label: Text(date.etiqueta),
            selected: isSelected,
            onSelected: (_) {
              // actualizar estado
              ref.read(dateFilterProvider.notifier).setPeriod(date);
            },
            selectedColor: Colors.yellow.shade700,
          );
        },
      ),
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  final double totalIncome;
  final List<Sale> sales;

  Map<String, double> getTotalesPorTipoPago(List<Sale> sales) {
    final Map<String, double> resumen = {};

    for (var sale in sales) {
      final tipo = sale.tipoPago?.nombreTipoPago ?? 'Desconocido';
      resumen[tipo] = (resumen[tipo] ?? 0) + sale.totalFinal;
    }

    return resumen;
  }

  const _BalanceCard({required this.totalIncome, required this.sales});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totales = getTotalesPorTipoPago(sales);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ingresos',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text('S/ $totalIncome',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.blueGrey)),
              ],
            ),
            if (totales.isNotEmpty) ...[
              const Divider(),
              // Mostrar totales por tipo de pago
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: totales.entries.map((e) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key),
                      Text('S/ ${e.value.toStringAsFixed(2)}'),
                    ],
                  );
                }).toList(),
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {}, child: const Text('Descargar Reportes')),
                TextButton(onPressed: () {}, child: const Text('Ver Balance')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _SalesList extends ConsumerWidget {
  List<Sale> sales = [];
  _SalesList({required this.sales});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // aquí irían tus ventas

    if (sales.isEmpty) {
      return const Expanded(
        child: Column(
          children: [
            Icon(
              Icons.image_search_rounded,
              size: 100,
            ),
            SizedBox(height: 12),
            Text('No tienes registros creados en esta fecha.')
          ],
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (_, i) {
          final sale = sales[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blueGrey, width: 1)),
            child: ListTile(
              leading: const Icon(Icons.card_giftcard, color: Colors.green),
              title: Text(sale.concepto),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${sale.tipoPago!.nombreTipoPago} • ${sale.fechaRegistro} • ${sale.horaRegistro}'),
                  Text(
                      'Vendedor: ${sale.usuarioRegistro.nombre} ${sale.usuarioRegistro.apellidoPaterno}'),
                ],
              ),
              trailing: Text(
                'S/ ${sale.totalFinal}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onTap: () {
                ref.read(saleProvider(sale.idVenta));
                ref.read(saleProvider(sale.idVenta).notifier).updateSale(sale);
                context.push("/sale_detail/${sale.idVenta}");
              },
            ),
          );
        },
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.push("/new_sale");
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 25),
              label: const Text(
                'Nueva venta',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
          // const SizedBox(width: 12),
          // Expanded(
          //   child: ElevatedButton.icon(
          //     onPressed: () {},
          //     icon: const Icon(Icons.remove, color: Colors.white),
          //     label: const Text('Nuevo gasto'),
          //     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _DateFilterOptions extends ConsumerWidget {
  const _DateFilterOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DateFilter> options = [
      DateFilter(type: DateFilterType.days, name: "Hoy"),
      DateFilter(type: DateFilterType.weeks, name: "Esta semana"),
      DateFilter(type: DateFilterType.months, name: "Este mes"),
      DateFilter(type: DateFilterType.years, name: "Este año")
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Elige el período que quieres ver:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 10),
          ...options.map((option) => ListTile(
                title: Text(option.name),
                onTap: () {
                  // Aquí puedes manejar la lógica de filtrado real
                  ref
                      .read(dateFilterProvider.notifier)
                      .setDateFilterType(option.type);

                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}
