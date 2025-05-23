import 'package:flutter/material.dart';

class CustomProductField extends StatelessWidget {
  final bool isTopField; // La idea es que tenga bordes redondeados arriba
  final bool isBottomField; // La idea es que tenga bordes redondeados abajo
  final bool obscureText;
  final String initialValue;
  final Function(String)? onChanged;
  final bool? readOnly;
  final String? label;
  final String? hint;
  final double? width;
  final TextEditingController? textEditingController;
  final IconData? iconData;

  const CustomProductField(
      {super.key,
      this.isTopField = false,
      this.isBottomField = false,
      this.label,
      this.hint,
      this.obscureText = false,
      this.initialValue = '',
      this.onChanged,
      this.readOnly = false,
      this.width,
      this.textEditingController,
      this.iconData});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(40));

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
            icon: Icon(iconData),
            onPressed: () => {},
            visualDensity: VisualDensity.compact,
            color: Colors.black,
            style: ButtonStyle(
              // backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
              padding:
                  WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(1)),
            ),
          ),
          const SizedBox(
            width: 25,
            child: Text(
              "S/",
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: width != null ? width! / 2 : 75,
            child: TextFormField(
              controller: textEditingController,
              readOnly: readOnly!,
              onChanged: onChanged,
              obscureText: obscureText,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              // initialValue: initialValue,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: hint,
                  focusColor: colors.primary
                  // icon: Icon( Icons.supervised_user_circle_outlined, color: colors.primary, )
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
