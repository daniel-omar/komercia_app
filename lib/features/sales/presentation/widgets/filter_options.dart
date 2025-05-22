import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/sales/presentation/providers/date_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/filter_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/payment_types_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/sales_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/users_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/custom_filled_button.dart';
import 'package:komercia_app/features/shared/widgets/full_screen_loader.dart';

// ignore: unused_element
class FilterOptions extends ConsumerWidget {
  FilterOptions({super.key});

  final int idPerfil = perfilesMap["Vendedor"] ?? 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentTypesState = ref.watch(paymentTypesProvider);

    if (paymentTypesState.isLoading || paymentTypesState.paymentTypes == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: FullScreenLoader()),
      );
    }

    final filtros = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Filtro'),
          backgroundColor: Colors.yellow[700],
          foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Métodos de pago',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: paymentTypesState.paymentTypes!.map((metodoPago) {
                final selected = filtros.tiposPagoSeleccionados
                    .contains(metodoPago.idTipoPago);
                return FilterChip(
                  label: Text(metodoPago.nombreTipoPago),
                  selected: selected,
                  onSelected: (_) {
                    ref
                        .read(filterProvider.notifier)
                        .toggleTipoPago(metodoPago.idTipoPago);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Empleados'),
              subtitle: const Text('Todos los empleados'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _EmpleadoSelectorSheet(idPerfil),
                );
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(filterProvider.notifier).reset();
                    // Navigator.pop(context);
                  },
                  child: const Text(
                    'Limpiar filtros',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final fecha = ref.read(dateFilterProvider).periodSelect!;
                    final filtros = ref.read(filterProvider);

                    ref.read(salesProvider.notifier).getSalesByFilter(
                          fechaInicio: fecha.fechaInicio,
                          fechaFin: fecha.fechaFin,
                          idsTipoPago: filtros.tiposPagoSeleccionados,
                          idsUsuarioRegistro: filtros.empleadosSeleccionados,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Filtrar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _EmpleadoSelectorSheet extends ConsumerWidget {
  final int idPerfil;
  const _EmpleadoSelectorSheet(this.idPerfil);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersProvider(idPerfil));
    if (usersState.isLoading || usersState.users == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: FullScreenLoader()),
      );
    }
    final empleados = usersState.users!;
    final seleccionados = ref.watch(filterProvider).empleadosSeleccionados;

    return SizedBox(
        height:
            MediaQuery.of(context).size.height * 0.5, // Altura fija del sheet
        child: Container(
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Todos los empleados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: empleados.length,
                  itemBuilder: (_, index) {
                    final empleado = empleados[index];
                    final seleccionado =
                        seleccionados.contains(empleado.idUsuario);
                    return CheckboxListTile(
                        value: seleccionado,
                        title: Text(
                            '${empleado.nombre} ${empleado.apellidoPaterno}'),
                        onChanged: (_) {
                          ref
                              .read(filterProvider.notifier)
                              .toggleEmpleado(empleado.idUsuario);
                        },
                        controlAffinity: ListTileControlAffinity.leading);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text('Limpiar'),
                      onPressed: () =>
                          ref.read(filterProvider.notifier).clearEmpleado(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      child: const Text('Volver'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
