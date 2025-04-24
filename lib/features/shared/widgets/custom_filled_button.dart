import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color? buttonColor;
  final TextStyle? textStyle;
  final Radius? radius;

  const CustomFilledButton(
      {super.key,
      this.onPressed,
      required this.text,
      this.buttonColor,
      this.textStyle,
      this.radius});

  @override
  Widget build(BuildContext context) {
    const radiusConstante = Radius.circular(10);

    return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: radius ?? radiusConstante,
              bottomRight: radius ?? radiusConstante,
              topLeft: radius ?? radiusConstante,
              topRight: radius ?? radiusConstante,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: textStyle,
        ));
  }
}
