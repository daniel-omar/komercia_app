import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/presentation/providers/product_variants_provider.dart';
import 'package:komercia_app/features/sales/domain/entities/product_color.dart';
import 'package:komercia_app/features/sales/domain/entities/product_size.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_colors_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_sizes_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/full_screen_loader.dart';

class SaveProductVariantsScreen extends ConsumerStatefulWidget {
  final int idProduct;

  const SaveProductVariantsScreen({super.key, required this.idProduct});

  @override
  ConsumerState<SaveProductVariantsScreen> createState() =>
      _SaveProductVariantsScreenState();
}

class _SaveProductVariantsScreenState
    extends ConsumerState<SaveProductVariantsScreen> {
  List<ProductVariant> _variantes = [];

  void _agregarVariante(
      List<ProductColor> colors, List<ProductSize> sizes) async {
    final variante = await _mostrarDialogoVariante(colors, sizes);

    if (variante != null) {
      setState(() {
        bool existe = _variantes.any((p) =>
            p.idProducto == widget.idProduct &&
            p.idColor == variante.idColor &&
            p.idTalla == variante.idTalla);
        if (existe) return;
        _variantes.add(variante);
      });
    }
  }

  Future<ProductVariant?> _mostrarDialogoVariante(
      List<ProductColor> colors, List<ProductSize> sizes) async {
    final formKey = GlobalKey<FormState>();
    int? idTalla;
    int? idColor;
    // final TextEditingController cantidadController = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Agregar Variante'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Talla'),
                  items: sizes
                      .map((size) => DropdownMenuItem<int>(
                            value: size.idTalla,
                            child: Text(
                              size.nombreTalla,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => idTalla = val,
                  validator: (val) => val == null ? 'Requerido' : null,
                ),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Color'),
                  items: colors
                      .map((color) => DropdownMenuItem<int>(
                            value: color.idColor,
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.idColor != colorsMap["P"]!
                                    ? color.color
                                    : null,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                color.nombreColor,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: color.color.computeLuminance() < 0.5 &&
                                          color.idColor != colorsMap["P"]!
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => idColor = val,
                  validator: (val) => val == null ? 'Requerido' : null,
                ),
                // TextFormField(
                //   controller: cantidadController,
                //   keyboardType: TextInputType.number,
                //   decoration: const InputDecoration(labelText: 'Cantidad'),
                //   validator: (val) =>
                //       val == null || val.isEmpty ? 'Requerido' : null,
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ProductColor color =
                      colors.firstWhere((x) => x.idColor == idColor);
                  ProductSize talla =
                      sizes.firstWhere((x) => x.idTalla == idTalla);

                  final variante = ProductVariant(
                      idProducto: widget.idProduct,
                      idTalla: idTalla!,
                      talla: talla,
                      idColor: idColor!,
                      color: color,
                      esActivo: true,
                      cantidad: 0);
                  Navigator.pop(context, variante);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _guardarVariantes() async {
    if (_variantes.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar'),
        content: const Text('¿Está seguro de guardar cambios?'),
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

    ref
        .read(productVariantsProvider(widget.idProduct).notifier)
        .saveVariants(_variantes);
  }

  void _removerVariante(int index) {
    setState(() => _variantes.removeAt(index));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Escuchar cambios en el provider y sincronizar _variantes
      ref.listenManual<ProductsState>(
        productVariantsProvider(widget.idProduct),
        (previous, next) {
          if (next.productVariants != null) {
            setState(() {
              _variantes = next.productVariants!;
            });
          }
        },
      );

      // Disparar carga de variantes desde el backend
      ref
          .read(productVariantsProvider(widget.idProduct).notifier)
          .getVariants();

      // Cargar colores y tallas
      ref.read(productColorsProvider.notifier).loadColors();
      ref.read(productSizesProvider.notifier).loadSizes();
    });

    // Future.microtask(() {
    //   ref.read(productColorsProvider.notifier).loadColors();
    //   ref.read(productSizesProvider.notifier).loadSizes();
    //   ref
    //       .watch(productVariantsProvider(widget.idProduct).notifier)
    //       .getVariants();

    //   final state = ref.watch(productVariantsProvider(widget.idProduct));
    //   _variantes = state.productVariants ?? [];
    // });
  }

  @override
  Widget build(BuildContext context) {
    final productColorsState = ref.watch(productColorsProvider);
    final productSizesState = ref.watch(productSizesProvider);

    final hasColors = productColorsState.productColors != null &&
        productColorsState.productColors!.isNotEmpty;
    final hasSizes = productSizesState.productSizes != null &&
        productSizesState.productSizes!.isNotEmpty;

    if (!hasColors || !hasSizes) {
      return const FullScreenLoader();
    }

    final state = ref.watch(productVariantsProvider(widget.idProduct));
    ref.listen<ProductsState>(productVariantsProvider(widget.idProduct),
        (previous, next) {
      if (next.success) {
        Navigator.pop(context); // bottomsheet

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Guardado con éxito'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3), // Duración del SnackBar
              behavior: SnackBarBehavior.floating),
        );
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardar Variantes'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Variantes agregadas:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
                child: ListView.builder(
              itemCount: _variantes.length,
              itemBuilder: (_, i) {
                final variante = _variantes[i];
                return _ProductVariantCard(
                  index: i,
                  producVariant: variante,
                  onRemove: _removerVariante,
                );
              },
            )),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _agregarVariante(productColorsState.productColors!,
                        productSizesState.productSizes!);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar variante'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _guardarVariantes,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar todo'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ProductVariantCard extends ConsumerWidget {
  final ProductVariant producVariant;
  final int index;
  final void Function(int index) onRemove;

  const _ProductVariantCard(
      {required this.producVariant,
      required this.index,
      required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blueGrey, width: 1)),
      child: Slidable(
        key: ValueKey(producVariant.idColor *
            producVariant.idTalla *
            producVariant.idProducto), // Clave única por item
        child: ListTile(
          // leading: Container(
          //   width: 48,
          //   height: 48,
          //   decoration: BoxDecoration(
          //     color: Colors.purple[100],
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: const Icon(Icons.toll, color: Colors.purple),
          // ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (producVariant.codigoProductoVariante != null) ...[
                Row(
                  children: [
                    const Text('Codigo: '),
                    Text(producVariant.codigoProductoVariante!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              Row(
                children: [
                  const Text('Talla:   '),
                  Text(producVariant.talla!.nombreTalla,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Text('Color: '),
                  Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: producVariant.color!.idColor != colorsMap["P"]!
                          ? producVariant.color!.color
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      producVariant.color!.nombreColor,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: producVariant.color!.color.computeLuminance() <
                                    0.5 &&
                                producVariant.color!.idColor != colorsMap["P"]!
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (producVariant.codigoProductoVariante != null) ...[
                StatefulBuilder(
                  builder: (context, setState) {
                    return Checkbox(
                      value: producVariant.esActivo,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            producVariant.esActivo = val;
                          });
                        }
                      },
                    );
                  },
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemove(index),
                )
              ],
            ],
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
