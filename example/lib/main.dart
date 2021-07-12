import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropping/image_cropping.dart';

void main() {
  runApp(
    MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List? _imageData;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          ImageCropping(
            context,
                (image) {
              setState(() {
                _imageData = image;
              });
            },
                () {
              // Start Loading.
            },
                () {
              // End Loading.
            },
          ).cropImage();
        },
        child: Container(
          margin: EdgeInsets.all(5),
          alignment: Alignment.center,
          width: 200,
          height: 200,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Visibility(
                visible: _imageData != null,
                child: _imageData == null
                    ? Container()
                    : Image.memory(_imageData!),
              ),
              Visibility(
                visible: _imageData == null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isImageUploading,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
