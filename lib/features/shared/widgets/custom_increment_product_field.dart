import 'package:flutter/material.dart';

class CustomIncrementProductField extends StatelessWidget {
  final bool isTopField; // La idea es que tenga bordes redondeados arriba
  final bool isBottomField; // La idea es que tenga bordes redondeados abajo
  final bool obscureText;
  final String initialValue;
  final Function()? onDecrement;
  final Function()? onIncrement;
  final TextEditingController? textEditingController;
  final bool? readOnly;
  final double? width;

  const CustomIncrementProductField(
      {super.key,
      this.isTopField = false,
      this.isBottomField = false,
      this.obscureText = false,
      this.initialValue = '',
      this.onDecrement,
      this.onIncrement,
      this.readOnly = false,
      this.width,
      this.textEditingController});

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(15);

    return Container(
      width: width,
      // padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isTopField ? borderRadius : Radius.zero,
          topRight: isTopField ? borderRadius : Radius.zero,
          bottomLeft: isBottomField ? borderRadius : Radius.zero,
          bottomRight: isBottomField ? borderRadius : Radius.zero,
        ),
        border: Border.all(
          color: Colors.grey, // Color del borde
          width: 1.5, // Grosor del borde
          style: BorderStyle.solid, // Estilo: solid, none
        ),
        boxShadow: [
          if (isBottomField)
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrement,
            visualDensity: VisualDensity.compact,
            color: Colors.white,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
              padding:
                  WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(1)),
            ),
            constraints: const BoxConstraints(
              minWidth: 36, // Ancho mínimo
              minHeight: 36, // Alto mínimo
            ),
          ),
          SizedBox(
            width: width != null ? width! / 2 : 50,
            child: TextField(
              controller: textEditingController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
            visualDensity: VisualDensity.compact,
            color: Colors.white,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
              padding:
                  WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(1)),
            ),
            constraints: const BoxConstraints(
              minWidth: 36, // Ancho mínimo
              minHeight: 36, // Alto mínimo
            ),
          ),
        ],
      ),
    );
  }
}
