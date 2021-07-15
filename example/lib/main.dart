import 'dart:typed_data';

import 'package:example/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';

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
        onTap: () async {
          showImagePickerDialog();


        },
        child: Container(
          margin: EdgeInsets.all(5),
          alignment: Alignment.center,
          width: 200,
          height: 200,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
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

  void showImagePickerDialog() {
    Dialog dialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        height: 200.0,
        width: 200.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Select Image Source',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openImagePicker(ImageSource.camera);
                  },
                  child: Text(
                    'Camera',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openImagePicker(ImageSource.gallery);
                  },
                  child: Text(
                    'Gallery',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog, barrierDismissible: false, );
  }

  Future<void> openImagePicker(source) async {
    var pickedFile =
        await ImagePicker().getImage(source: source);
    final _imageBytes = await pickedFile?.readAsBytes();
    ImageCropping(
      context,
      _imageBytes!,
          (image) {
        setState(() {
          _imageData = image;
        });
      },
          () {
        // Start Loading.
        AppLoader.show(context);
      },
          () {
        // End Loading.
        AppLoader.hide();
      }
    ).cropImage();
  }

}
