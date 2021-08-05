import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:face_detection/common/color.dart';
import 'package:face_detection/common/loading.dart';
import 'package:face_detection/components/custom_text.dart';
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
  double _depthFloatingButton = 4;
  Color _active = grey;
  Color _noActive = black;

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
      end: redAccent.withOpacity(0.8),
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
      _depthFloatingButton = -4;
    } else {
      _animationController.reverse();
      _depthFloatingButton = 4;
    }
    isOpened = !isOpened;
  }

  Widget refresh() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          border: NeumorphicBorder(
            color: grey.withOpacity(0.2),
            width: 1,
          ),
          depth: -4,
          shadowLightColor: grey,
        ),
        onPressed: (){
          setState(() {
            _imageFile = null;
          });
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh, color: grey,),
      ),
    );
  }

  Widget imageFromCamera() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          border: NeumorphicBorder(
            color: grey.withOpacity(0.2),
            width: 1,
          ),
          depth: -4,
          shadowLightColor: grey,
        ),
        onPressed: (){
          getImage(true);
        },
        tooltip: 'Take a Photo',
        child: Icon(Icons.camera_alt, color: grey,),
      ),
    );
  }

  Widget imageFromGallery() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          border: NeumorphicBorder(
            color: grey.withOpacity(0.2),
            width: 1,
          ),
          depth: -4,
          shadowLightColor: grey,
        ),
        onPressed: (){
          getImage(false);
        },
        tooltip: 'Select Photos',
        child: Icon(Icons.image, color: grey,),
      ),
    );
  }

  Widget floatingActionButton() {
    return Container(
      child: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          border: NeumorphicBorder(
            color: grey.withOpacity(0.2),
            width: 1,
          ),
          color: _buttonColor.value,
          shape: NeumorphicShape.flat,
          depth: _depthFloatingButton,
          shadowLightColor: grey,
        ),
        onPressed: animate,
        tooltip: 'Menu',
        child: Center(
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animateIcon,
            color: isOpened ? _noActive : _active,
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
            children: <Widget>[
              SizedBox(height: 20,),
              Neumorphic(
                style: NeumorphicStyle(
                  border: NeumorphicBorder(
                    color: grey.withOpacity(0.2),
                    width: 1.5,
                  ),
                  shape: NeumorphicShape.concave,
                  intensity: 0.75,
                  surfaceIntensity: 0.3,
                  color: white,
                  depth: -4,
                  shadowLightColor: grey,
                ),
                child: Container(
                  height: 60,
                  width: 375,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      NeumorphicIcon(
                        Icons.face,
                        size: 50,
                        style: NeumorphicStyle(
                          oppositeShadowLightSource: true,
                          color: white,
                          depth: 4,
                          shadowLightColor: grey,
                        ),
                      ),
                      CustomText(text: ' Image Face Detector', color: grey, size: 25,)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50,),
              isLoading
                  ? Loading()
                  : _imageFile == null
                  ? Center(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    border: NeumorphicBorder(
                      color: grey.withOpacity(0.2),
                      width: 3,
                    ),
                    shape: NeumorphicShape.concave,
                    intensity: 0.75,
                    surfaceIntensity: 0.3,
                    color: white,
                    depth: 6,
                    shadowLightColor: grey,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Center(
                        child: CustomText(text: 'No Image Selected', color: grey, size: 23,)
                    ),
                  ),
                ),
              ) : Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      border: NeumorphicBorder(
                        color: grey.withOpacity(0.2),
                        width: 3,
                      ),
                      shape: NeumorphicShape.concave,
                      color: white,
                      intensity: 0.75,
                      surfaceIntensity: 0.3,
                      depth: 6,
                      shadowLightColor: grey,
                    ),
                    child: Container(
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
              ),
              Visibility(
                  visible: _imageFile != null ? false : true,
                  child: SizedBox(height: 120,)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: _imageFile != null ? Container()
                      : Neumorphic(
                    style: NeumorphicStyle(
                      border: NeumorphicBorder(
                        color: grey.withOpacity(0.2),
                        width: 1,
                      ),
                      intensity: 0.75,
                      surfaceIntensity: 0.3,
                      color: white,
                      depth: -4,
                      shadowLightColor: grey,
                    ),
                    child: Container(
                      height: 70,
                      width: 280,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CustomText(text: 'Copyright © 2021 Dendirzkptr', color: grey,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CustomText(text: 'Dibuat dengan ', color: grey),
                              Icon(Icons.favorite, color: redAccent, size: 20,),
                              CustomText(text: ' melalui FlutterUI, ', color: grey),
                            ],
                          ),
                          CustomText(text: 'Dart SDK, & Firebase ML Vision', color: grey)
                        ],
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
              child: refresh()),
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
