import 'package:flutter/material.dart';

class CustomElevatedIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final Color? buttonColor;
  final IconData? icon;
  final TextStyle? textStyle;
  final Color? colorIcon;
  final Radius? radius;

  const CustomElevatedIconButton(
      {super.key,
      this.onPressed,
      this.text,
      required this.icon,
      this.buttonColor,
      this.textStyle,
      this.colorIcon,
      this.radius});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    const _radius = Radius.circular(10);

    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: colorIcon,
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomLeft: radius == null ? _radius : radius!,
            bottomRight: radius == null ? _radius : radius!,
            topLeft: radius == null ? _radius : radius!,
            topRight: radius == null ? _radius : radius!,
          ))),
      onPressed: onPressed,
      label: Text(
        text!,
        style: textStyle,
      ),
    );
  }
}
