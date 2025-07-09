import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/domain/entities/product_variant.dart';
import 'package:komercia_app/features/sales/presentation/providers/products_variants_purchase_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';
import 'package:komercia_app/features/shared/widgets/custom_increment_product_field.dart';
import 'package:komercia_app/features/shared/widgets/custom_product_field.dart';

class ProductVariantPurcharseCard extends ConsumerStatefulWidget {
  final ProductVariant productVariant;
  final ProductVariantPurchaseState state;

  const ProductVariantPurcharseCard(
      {super.key, required this.productVariant, required this.state});

  @override
  ConsumerState<ProductVariantPurcharseCard> createState() =>
      _ProductVariantPurcharseCardState();
}

class _ProductVariantPurcharseCardState
    extends ConsumerState<ProductVariantPurcharseCard> {
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
      ref.read(productsVariantsPurchaseProvider.notifier).updateProductVariant(
            widget.state.uuid,
            cantidad: value,
          );
    }

    void updatePrice(String value) {
      double price = double.tryParse(value) ?? 0;
      // if (price < widget.state.precioCompra!) {
      //   price = widget.state.precioCompra!;
      //   priceController.text = price.toString();
      // }
      ref.read(productsVariantsPurchaseProvider.notifier).updateProductVariant(
            widget.state.uuid,
            precioVenta: price,
          );
    }

    // int get _currentValue => int.tryParse(quantityController.text) ?? 0;
    int currentValue() => int.tryParse(quantityController.text) ?? 0;

    void onIncrement() {
      if (currentValue() == widget.state.cantidadMaxima) {
        return;
      }

      int cantidad = currentValue() + 1;
      quantityController.text = cantidad.toString();
      updateQuantity(cantidad);
    }

    void onDecrement() {
      int cantidad = currentValue() - 1;
      if (cantidad > 0) {
        quantityController.text = cantidad.toString();
        updateQuantity(cantidad);
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
        TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

    final showErrors = ref.watch(showProductPurchaseValidationErrorsProvider);
    final isInvalid = (widget.state.precioVenta == 0);

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
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Eliminar',
                      onPressed: () async {
                        ref
                            .read(productsVariantsPurchaseProvider.notifier)
                            .removeProduct(widget.state.uuid);
                      },
                      color: Colors.white, // color del ícono
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.red),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(8)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const Text('Codigo: '),
                              SelectableText(
                                widget.productVariant.codigoProductoVariante ??
                                    "",
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                // O también puedes usar Expanded si quieres que ocupe todo el ancho disponible
                                child: Text(
                                  widget.productVariant.nombreProducto ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: styleField,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          if (!(widget.productVariant.talla!.codigoTalla ==
                                  "PDT" &&
                              widget.productVariant.color!.codigoColor ==
                                  "PDT")) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.productVariant.talla!.nombreTalla,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "::",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        widget.productVariant.color!.idColor !=
                                                colorsMap["Predeterminado"]!
                                            ? widget.productVariant.color!.color
                                            : null,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.productVariant.color!.nombreColor,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: widget.productVariant.color!.color
                                                      .computeLuminance() <
                                                  0.5 &&
                                              widget.productVariant.color!
                                                      .idColor !=
                                                  colorsMap["Predeterminado"]!
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
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
    );
  }
}
