import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/presentation/providers/product_colors_provider.dart';
import 'package:komercia_app/features/sales/presentation/providers/products_purchase_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/custom_increment_product_field.dart';
import 'package:komercia_app/features/shared/widgets/custom_product_field.dart';

class ProductPurcharseCard extends ConsumerStatefulWidget {
  final Product product;
  final ProductPurchaseState state;
  final List<ProductColor> productColors;
  final List<ProductSize> productSizes;

  const ProductPurcharseCard(
      {super.key,
      required this.product,
      required this.state,
      required this.productColors,
      required this.productSizes});

  @override
  ConsumerState<ProductPurcharseCard> createState() =>
      _ProductPurcharseCardState();
}

class _ProductPurcharseCardState extends ConsumerState<ProductPurcharseCard> {
  late final TextEditingController quantityController;
  late final TextEditingController priceController;
  late List<ProductColor> availableProductColors = [];

  @override
  void initState() {
    super.initState();
    quantityController =
        TextEditingController(text: widget.state.cantidad.toString());
    priceController =
        TextEditingController(text: widget.state.precioVenta.toString());

    final sizeNA = widget.productSizes
        .firstWhereOrNull((x) => x.idTalla == sizesMap["P"]);

    Future.microtask(() async {
      if (sizeNA != null) {
        ref.read(productsPurchaseProvider.notifier).updateProduct(
              widget.state.uuid,
              idTalla: sizesMap["P"],
            );

        final result = await ref.read(productColorsBySizeProvider(
            (widget.product.idProducto, sizesMap["P"]!)).future);

        setState(() {
          availableProductColors = result;
        });
      } else {
        setState(() {
          availableProductColors = widget.productColors;
        });
      }
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    final total = widget.state.total.toStringAsFixed(2);

    void updateQuantity(int value) {
      print(value);
      ref.read(productsPurchaseProvider.notifier).updateProduct(
            widget.state.uuid,
            cantidad: value,
          );
    }

    void updatePrice(String value) {
      print(value);
      final price = double.tryParse(value) ?? 0;
      ref.read(productsPurchaseProvider.notifier).updateProduct(
            widget.state.uuid,
            precioVenta: price,
          );
    }

    void onSizeChanged(int idSize) async {
      ref.read(productsPurchaseProvider.notifier).updateProduct(
            widget.state.uuid,
            idTalla: idSize,
          );

      final result = await ref.read(
          productColorsBySizeProvider((widget.product.idProducto, idSize))
              .future);

      setState(() {
        availableProductColors = result;
      });

      if (idSize == colorsMap["P"]) {
        ref.read(productsPurchaseProvider.notifier).updateProduct(
              widget.state.uuid,
              idColor: colorsMap["P"],
            );
      }
    }

    void onColorChanged(int idColor) {
      ref.read(productsPurchaseProvider.notifier).updateProduct(
            widget.state.uuid,
            idColor: idColor,
          );
      print(idColor);
    }

    // int get _currentValue => int.tryParse(quantityController.text) ?? 0;
    int currentValue() => int.tryParse(quantityController.text) ?? 0;

    void onIncrement() {
      String cantidad = (currentValue() + 1).toString();
      quantityController.text = cantidad;
      updateQuantity(int.parse(cantidad));
    }

    void onDecrement() {
      if (currentValue() > 0) {
        String cantidad = (currentValue() - 1).toString();
        quantityController.text = cantidad;
        updateQuantity(int.parse(cantidad));
      }
    }

    void onChangePrice(String precio) {
      if (precio.startsWith("0")) {
        precio = precio.replaceFirst("0", "");
      }
      if (precio == "") {
        precio = "0";
      }
      // priceController.text = precio;
      updatePrice(precio);
    }

    const TextStyle styleField =
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    // const TextStyle styleFieldValue =
    //     TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    final showErrors = ref.watch(showProductPurchaseValidationErrorsProvider);
    final isInvalid = (widget.state.idTalla == 0 || widget.state.idColor == 0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        // color: Colors.amber,
        child: InkWell(
          // onTap: () => {},
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            // margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(244, 241, 241, 241),
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(color: Colors.blueAccent),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x000005cc),
                    blurRadius: 20,
                    offset: Offset(10, 10))
              ],
              border: Border.all(
                color: (showErrors && isInvalid)
                    ? Colors.red
                    : Colors.grey.shade300,
                width: (showErrors && isInvalid) ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Eliminar',
                        onPressed: () async {
                          ref
                              .read(productsPurchaseProvider.notifier)
                              .removeProduct(widget.state.uuid);
                        },
                        color: Colors.white, // color del ícono
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.black),
                          padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(8)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        textAlign: TextAlign.center,
                        widget.product.nombreProducto,
                        style: styleField,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _SizeSelector(
                          idSelectedSize: widget.state.idTalla ?? 0,
                          sizes: widget.productSizes,
                          onSizeChanged: onSizeChanged)
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: _ColorSelector(
                        idSelectedColor: widget.state.idColor ?? 0,
                        colors: availableProductColors,
                        onColorChanged: onColorChanged),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomIncrementProductField(
                        isBottomField: true,
                        isTopField: true,
                        textEditingController: quantityController,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomProductField(
                        isBottomField: true,
                        isTopField: true,
                        iconData: Icons.edit,
                        textEditingController: priceController,
                        onChanged: onChangePrice,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Total: S/ $total',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final int idSelectedSize;
  final void Function(int selectedSize) onSizeChanged;

  // final List<String> sizes = const ['XS', 'S', 'M', 'L', 'XL'];
  final List<ProductSize> sizes;

  const _SizeSelector(
      {required this.idSelectedSize,
      required this.onSizeChanged,
      required this.sizes});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      multiSelectionEnabled: false,
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: sizes.map((size) {
        return ButtonSegment(
            value: size.idTalla,
            label: Text(size.nombreTalla,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold)));
      }).toList(),
      selected: {idSelectedSize},
      onSelectionChanged: (newSelection) {
        FocusScope.of(context).unfocus();
        onSizeChanged(newSelection.first);
      },
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final int idSelectedColor;
  final void Function(int selectedColor) onColorChanged;

  final List<ProductColor> colors;

  const _ColorSelector(
      {required this.idSelectedColor,
      required this.onColorChanged,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: colors.isEmpty
            ? null
            : SegmentedButton(
                multiSelectionEnabled: false,
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                  ),
                  side: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const BorderSide(color: Colors.red, width: 4);
                    }
                    return const BorderSide(color: Colors.grey, width: 1);
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color.fromARGB(255, 79, 33, 243)
                          .withOpacity(0.12);
                    }
                    return Colors.transparent;
                  }),
                ),
                segments: colors.map((color) {
                  return ButtonSegment(
                    value: color.idColor,
                    label: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color.color.computeLuminance() < 0.5 &&
                                  color.idColor != colorsMap["P"]!
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                selected: {idSelectedColor},
                onSelectionChanged: (newSelection) {
                  FocusScope.of(context).unfocus();
                  onColorChanged(newSelection.first);
                },
              ),
      ),
    );
  }
}
