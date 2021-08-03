import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:face_detection/common/color.dart';
import 'package:face_detection/common/loading.dart';
import 'package:face_detection/service/face_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetector extends StatefulWidget {
  @override
  _FaceDetectorState createState() => _FaceDetectorState();
}

class _FaceDetectorState extends State<FaceDetector>
    with SingleTickerProviderStateMixin {

  AnimationController _animationController;
  bool isOpened = false;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 100.0;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: white,
      end: redAccent,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -5.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: -8,
          shadowLightColorEmboss: grey,
        ),
        onPressed: (){
          setState(() {
            _imageFile = null;
          });
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget imageFromCamera() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: -8,
          shadowLightColorEmboss: grey,
        ),
        onPressed: (){
          getImage(true);
        },
        tooltip: 'Image',
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Widget imageFromGallery() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: -8,
          shadowLightColorEmboss: grey,
        ),
        onPressed: (){
          getImage(false);
        },
        tooltip: 'Select a Photos',
        child: Icon(Icons.image),
      ),
    );
  }

  Widget floatingActionButton() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          color: _buttonColor.value,
          shape: NeumorphicShape.flat,
          depth: -8,
          shadowLightColorEmboss: grey,
        ),
        onPressed: animate,
        tooltip: 'Menu',
        child: Center(
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animateIcon,
          ),
        ),
      ),
    );
  }

  bool isLoading = false;
  File _imageFile;
  List<Face> _face;
  ui.Image _image;

  //GET IMAGE
  Future getImage(bool camera) async {
    File image;
    final picker = ImagePicker();
    var pickedFile;
    if (camera) {
      pickedFile = await picker.getImage(source: ImageSource.camera);
      image = File(pickedFile.path);
    } else {
      pickedFile = await picker.getImage(source: ImageSource.gallery);
      image = File(pickedFile.path);
    }
    setState(() {
      _imageFile = image;
      isLoading = true;
    });

    detectFaces(_imageFile);
  }

  detectFaces(File imageFile) async {
    final image = InputImage.fromFile(_imageFile);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);

    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _face = faces;
        _loadImage(imageFile);
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) =>
        setState(() {
          _image = value;
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            color: grey.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    NeumorphicIcon(
                      Icons.face,
                      size: 50,
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        oppositeShadowLightSource: true,
                        intensity: 0.75,
                        surfaceIntensity: 0.3,
                        color: white,
                        depth: 8,
                        shadowLightColor: grey,
                      ),
                    ),
                    NeumorphicText(
                        ' Image Face Detection',
                        style: NeumorphicStyle(
                          oppositeShadowLightSource: true,
                          shape: NeumorphicShape.flat,
                          color: white,
                          depth: 4,
                          shadowLightColor: black,
                        ),
                        textStyle: NeumorphicTextStyle(
                          fontSize: 25, //customize size here
                        )
                    )
                  ],
                ),
                SizedBox(height: 50,),
                isLoading
                    ? Loading()
                    : _imageFile == null
                    ? Center(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      border: NeumorphicBorder(
                        color: Color(0x33000000),
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
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                          child: NeumorphicText(
                        'No Image Selected',
                            style: NeumorphicStyle(
                              oppositeShadowLightSource: true,
                              shape: NeumorphicShape.flat,
                              color: white,
                              depth: 4,
                              shadowLightColor: black,
                            ),
                              textStyle: NeumorphicTextStyle(
                                fontSize: 25, //customize size here
                              )
                          )
                      ),
                    ),
                  ),
                ) : Center(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.concave,
                      intensity: 0.75,
                      surfaceIntensity: 0.3,
                      color: white,
                      depth: 8,
                      shadowLightColor: grey,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: FittedBox(
                        child: SizedBox(
                          width: _image.width.toDouble(),
                          height: _image.height.toDouble(),
                          child: CustomPaint(
                        painter: FacePainter(_image, _face),
                      ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * 3.0,
                0.0,
              ),
            child: add()),
          SizedBox(height: 8,),
          Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * 3.0,
                0.0,
              ),
              child: imageFromCamera()),
          SizedBox(height: 8,),
          Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * 3.0,
                0.0,
              ),
              child: imageFromGallery()),
          floatingActionButton()
        ],
      ),
    );
  }
}