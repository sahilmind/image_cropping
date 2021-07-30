import 'dart:typed_data';

import 'package:example/image_picker/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: MyMain(),
    ),
  );
}

class MyMain extends StatefulWidget {
  const MyMain({Key? key}) : super(key: key);

  @override
  _MyMainState createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green,
        child: Center(
          child: Center(
            child: InkWell(
              child: imageBytes == null
                  ? Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.black,
                    )
                  : Image.memory(imageBytes!),
              onTap: () {
                showImagePickerDialog();
              },
            ),
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
            Padding(
              padding: EdgeInsets.only(top: 50.0),
            ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
      barrierDismissible: false,
    );
  }

  void openImagePicker(source) async {
    showLoader();
    var pickedFile = await ImagePicker().getImage(source: source,);
    imageBytes = await pickedFile?.readAsBytes();
    hideLoader();

    ImageCropper.cropImage(context, imageBytes!, () {
      showLoader();
    }, () {
      hideLoader();
    }, (data) {
      imageBytes = data;
      setState(() {});
    });
  }

  void showLoader() {
    if(EasyLoading.isShow){
      return;
    }
    EasyLoading.show(status: 'Loading...');
  }

  void hideLoader() {
    EasyLoading.dismiss();
  }
}
