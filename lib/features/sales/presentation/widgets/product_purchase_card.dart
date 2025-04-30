import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/sales/domain/entities/product.dart';
import 'package:komercia_app/features/shared/widgets/custom_filled_button.dart';

class ProductPurcharseCard extends StatelessWidget {
  final Product product;
  const ProductPurcharseCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    const TextStyle styleField =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const TextStyle styleFieldValue = TextStyle(fontSize: 16);

    return Material(
      // color: Colors.amber,
      child: InkWell(
        onTap: () => {},
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          // margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(color: Colors.blueAccent),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x000005cc),
                    blurRadius: 20,
                    offset: Offset(10, 10))
              ]),
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
                        print("object");
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      textAlign: TextAlign.center,
                      product.nombreProducto,
                      style: styleFieldValue,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      textAlign: TextAlign.center,
                      "Precio: ",
                      style: styleField,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      textAlign: TextAlign.center,
                      "${0}",
                      style: styleFieldValue,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CustomFilledButton(
                    onPressed: () {},
                    text: "",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
