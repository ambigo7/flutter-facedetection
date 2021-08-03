import 'package:face_detection/common/color.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final TextAlign align;
  final FontWeight weight;
  final TextDecoration decoration;

//CUNSTRUKTOR REQUIRED
  CustomText({@required this.text, this.size, this.color, this.align, this.weight, this.decoration});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(
        color: color ?? black,
        fontWeight: weight ?? FontWeight.normal,
        fontSize: size ?? 16,
        decoration: decoration ?? TextDecoration.none,
      ),
      textAlign: align ?? TextAlign.start,
    );
  }
}