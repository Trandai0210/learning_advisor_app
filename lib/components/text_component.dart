import 'package:flutter/material.dart';

class TextComponent extends StatelessWidget {
  final String label;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const TextComponent(
    {
      Key? key,
      required this.label,
      this.fontSize = 16,
      this.color,
      this.fontWeight
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
          color: color ?? Colors.white,
        fontWeight: fontWeight ?? FontWeight.w500
      ),
    );
  }
}
