import 'package:face_detection/common/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Neumorphic(
              style: NeumorphicStyle(
                border: NeumorphicBorder(
                  color: grey.withOpacity(0.2),
                  width: 0.8,
                ),
                shape: NeumorphicShape.concave,
                intensity: 0.75,
                surfaceIntensity: 0.3,
                color: white,
                depth: 8,
                shadowLightColor: grey,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width /1.1,
                height: MediaQuery.of(context).size.height /2,
                child: Center(
                  child: SpinKitFadingCircle(
                    color: grey,
                    size: 30,
          ),
                ),
              )
      ),
    );
  }
}