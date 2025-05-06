import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/sales/presentation/providers/date_provider.dart';

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
    if (dateFilter.isLoading) {
      // Mostrar un loader mientras se obtienen los datos
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const _FilterOptions(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _DateSelector(),
          const _BalanceCard(),
          const SizedBox(height: 10),
          const _SalesList(),
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

    if (dateFilter.periodSelect != null) {
      // Desplazar al final cuando cambia el periodo seleccionado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEnd();
      });
    }

    return SizedBox(
      height: 48,
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
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ingresos', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$0'),
              ],
            ),
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

class _SalesList extends StatelessWidget {
  const _SalesList();

  @override
  Widget build(BuildContext context) {
    final sales = <String>[]; // aquí irían tus ventas

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
        itemBuilder: (_, i) => ListTile(
          title: Text('Venta $i'),
          subtitle: Text('Detalle de la venta'),
        ),
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

class _FilterOptions extends ConsumerWidget {
  const _FilterOptions();

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
