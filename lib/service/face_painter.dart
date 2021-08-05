import 'package:face_detection/common/color.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:google_ml_kit/google_ml_kit.dart';

class FacePainter extends CustomPainter{

  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces,){
    for(var i = 0; i < faces.length; i++){
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size){
    final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..color = green;

    canvas.drawImage(image, Offset.zero, Paint());
    for(var i = 0; i < faces.length; i++){
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate){
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }

}