import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Library;
import 'package:image_cropping/common/inverted_clipper.dart';
import 'package:image_cropping/constant/color_constant.dart';
import 'package:image_cropping/constant/enums.dart';
import 'package:image_cropping/model/image_draw_details.dart';

// import 'package:image_picker/image_cropper.dart';

import 'common/app_button.dart';

class ImageCropping {
  BuildContext _context;
  Uint8List _imageBytes;
  void Function(Uint8List) _onImagePickListener;
  void Function() _onImageStartLoading;
  void Function() _onImageEndLoading;
  double _outputImageSize;
  double _defaultCropSize = 100;
  double _minCropSize = 10;

  var _currentRotationValue = 0;
  var _currentRotationDegreeValue = 0;

  var _currentRatio = ImageRatio.RATIO_1_1;
  var _currentRatioWidthValue = 1;
  var _currentRatioHeightValue = 1;

  double cropSize = -1;

  double initCropSize = -1;

  ImageCropping(this._context, this._imageBytes, this._onImagePickListener,
      this._onImageStartLoading, this._onImageEndLoading,
      {double outputImageSize = -1})
      : _outputImageSize = outputImageSize;


  Future<void> cropImage() async {
    final double deviceWidth = MediaQuery.of(_context).size.width;
    final double deviceHeight = MediaQuery.of(_context).size.height;

    late double surfaceX = -1,
        surfaceY = -1,
        cropButtonXPosition = -1,
        cropButtonYPosition = -1;
    double width, height, originalWidth, originalHeight;
    double imgWidth, imgHeight;
    Library.Image? imageFromLibrary;

    if (kIsWeb) {
      _defaultCropSize = 100;
      _minCropSize = 40;
    } else {
      _defaultCropSize = 50;
      _minCropSize = 20;
    }

    cropSize =
        (_outputImageSize == -1) ? _defaultCropSize : _outputImageSize;
    initCropSize =
        (_outputImageSize == -1) ? _defaultCropSize : _outputImageSize;

    showDialog(
        context: _context,
        builder: (BuildContext context4) {
          return StatefulBuilder(builder: (rootContext, rootState) {
            return Material(
              child: FutureBuilder<ui.Image>(
                  future: _bytesToImage(_imageBytes),
                  builder: (context3, data) {
                    if (data.hasData && data.data != null) {
                      _onImageEndLoading();
                      ui.Image image = data.data!;

                      imgWidth = image.width.toDouble();
                      imgHeight = image.height.toDouble();
                      if (imgWidth > imgHeight) {
                        originalWidth = imgWidth;
                        originalHeight = imgWidth;
                      } else {
                        originalWidth = imgHeight;
                        originalHeight = imgHeight;
                      }
                      if (deviceWidth > deviceHeight) {
                        width = deviceHeight;
                        height = deviceHeight;
                      } else {
                        width = deviceWidth;
                        height = deviceWidth;
                      }

                      if (imgWidth > imgHeight) {
                        imgHeight = imgHeight * (width / imgWidth);
                        cropSize = cropSize * (width / imgWidth);
                        initCropSize = cropSize;
                        imgWidth = width;
                      } else {
                        imgWidth = imgWidth * (width / imgHeight);
                        cropSize = cropSize * (width / imgHeight);
                        initCropSize = cropSize;
                        imgHeight = width;
                      }
                      compute(
                              drawImageInCenter,
                              ImageDrawDetails(
                                  _imageBytes,
                                  Library.Image(originalWidth.toInt(),
                                      originalHeight.toInt()),
                                  originalWidth.toInt(),
                                  originalHeight.toInt()))
                          .then((value) {
                        imageFromLibrary = value;
                      });
                      final double maxCropSize =
                          width > height ? height : width;
                      double left = (width / 2) - (cropSize / 2),
                          top = (height / 2) - (cropSize / 2),
                          rightCenter = 0,
                          leftCentre = 0;
                      return StatefulBuilder(builder: (context4, setState2) {
                        final imageWidget = Image.memory(
                          _imageBytes,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          width: imgWidth,
                          height: imgHeight,
                        );
                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                  (kIsWeb) ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        changeRatio(setState2, ImageRatio.RATIO_1_1, 1, 1);
                                      },
                                      child: Text("1:1"),
                                    ),
                                    SizedBox(width: (kIsWeb) ? 20 : 0,),
                                    InkWell(
                                      onTap: () {
                                        changeRatio(setState2, ImageRatio.RATIO_1_2, 1, 2);
                                      },
                                      child: Text("1:2"),
                                    ),
                                    SizedBox(width: (kIsWeb) ? 20 : 0,),
                                    InkWell(
                                      onTap: () {
                                        changeRatio(setState2, ImageRatio.RATIO_3_2, 3, 2);
                                      },
                                      child: Text("3:2"),
                                    ),
                                    SizedBox(width: (kIsWeb) ? 20 : 0,),
                                    InkWell(
                                      onTap: () {
                                        changeRatio(setState2, ImageRatio.RATIO_4_3, 4, 3);
                                      },
                                      child: Text("4:3"),
                                    ),
                                    SizedBox(width: (kIsWeb) ? 20 : 0,),
                                    InkWell(
                                      onTap: () {
                                        changeRatio(setState2, ImageRatio.RATIO_16_9, 16, 9);
                                      },
                                      child: Text("16:9"),
                                    ),
                                    SizedBox(width: (kIsWeb) ? 50 : 0, height: (kIsWeb) ? 50 : 0,),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: StatefulBuilder(
                                builder: (context, setCropState) {
                                  void checkTopLeft() {
                                    if (left < 0) {
                                      left = 0;
                                    }
                                    if (left + cropSize > width) {
                                      left = width - cropSize;
                                    }
                                    if (top + cropSize > height) {
                                      top = height - cropSize;
                                    }
                                    if (top < 0) {
                                      top = 0;
                                    }
                                  }

                                  void touchUpdate(data) {
                                    if (surfaceX != -1) {
                                      left += data.globalPosition._dx - surfaceX;
                                      top += data.globalPosition._dy - surfaceY;
                                      checkTopLeft();
                                      setCropState(() {});
                                    }
                                    surfaceX = data.globalPosition._dx;
                                    surfaceY = data.globalPosition._dy;
                                  }

                                  void onButtonPress(data) {
                                    cropButtonXPosition =
                                        data.globalPosition._dx;
                                    cropButtonYPosition =
                                        data.globalPosition._dy;
                                  }

                                  void buttonDrag(
                                      data, DragDirection direction) {
                                    if (data == null) {
                                      return;
                                    }
                                    if (cropButtonXPosition != -1 &&
                                        cropButtonYPosition != -1) {
                                      double tmp = 0;
                                      if (direction == DragDirection.LEFT_TOP) {
                                        tmp = (cropButtonXPosition -
                                            data.globalPosition._dx) * ((kIsWeb) ? 1 : 0.5);
                                        left -= tmp;
                                        top -= tmp;
                                      } else if (direction ==
                                          DragDirection.LEFT_BOTTOM) {
                                        tmp = (cropButtonXPosition -
                                            data.globalPosition._dx) * ((kIsWeb) ? 1 : 0.5);
                                        left -= tmp;
                                      } else if (direction ==
                                          DragDirection.RIGHT_TOP) {
                                        tmp = (data.globalPosition._dx -
                                            cropButtonXPosition) * ((kIsWeb) ? 1 : 0.5);
                                        top -= tmp;
                                      } else if (direction ==
                                          DragDirection.RIGHT_BOTTOM) {
                                        tmp = (data.globalPosition._dx -
                                            cropButtonXPosition) * ((kIsWeb) ? 1 : 0.5);
                                      } else if(direction == DragDirection.RIGHT_CENTRE){
                                        rightCenter = (data.globalPosition._dy - cropButtonXPosition) * 0.5;
                                        print("dy: ${data.globalPosition._dy} rightCenter: $rightCenter");
                                      } else if(direction == DragDirection.LEFT_CENTRE){
                                        // leftCentre = data.globalPosition.dx * 0.5;
                                        // print(leftCentre);
                                      }
                                      cropSize += tmp;
                                      if (_outputImageSize != -1 &&
                                          cropSize < initCropSize) {
                                        cropSize = initCropSize;
                                      }
                                      if (cropSize < _minCropSize) {
                                        cropSize = _minCropSize;
                                      }
                                      if (cropSize > maxCropSize) {
                                        cropSize = maxCropSize;
                                      }
                                      checkTopLeft();
                                      setCropState(() {});
                                    }
                                    cropButtonXPosition =
                                        data.globalPosition._dx;
                                    cropButtonYPosition =
                                        data.globalPosition._dy;
                                  }

                                  return Center(
                                    child: Container(
                                      width: width,
                                      height: height,
                                      color: Colors.white,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          RotatedBox(
                                              quarterTurns:
                                                  _currentRotationValue,
                                              child:
                                                  Center(child: imageWidget)),
                                          Positioned(
                                              left: left,
                                              top: top,
                                              child: GestureDetector(
                                                child: Container(
                                                  width: (cropSize * _currentRatioWidthValue) + rightCenter ,
                                                  height: cropSize * _currentRatioHeightValue,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                ),
                                                onTapDown: (data) {
                                                  surfaceX = -1;
                                                  // data.globalPosition.dx;
                                                  surfaceY = -1;
                                                  // data.globalPosition.dy;
                                                },
                                                onHorizontalDragUpdate:
                                                    touchUpdate,
                                                onVerticalDragUpdate:
                                                    touchUpdate,
                                                onVerticalDragStart:
                                                    touchUpdate,
                                                onHorizontalDragStart:
                                                    touchUpdate,
                                              )),
                                          IgnorePointer(
                                            child: ClipPath(
                                              clipper: InvertedClipper(
                                                  left, top, cropSize * _currentRatioWidthValue + rightCenter, cropSize * _currentRatioHeightValue, context),
                                              child: Container(
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 0.4),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              // LEFT_TOP
                                              left: left - leftCentre - 10,
                                              top: top - 10,
                                              child: GestureDetector(
                                                child: CircleAvatar(
                                                  child: Container(),
                                                  radius: 10,
                                                  backgroundColor:
                                                      AppColors.theme,
                                                ),
                                                onTapDown: onButtonPress,
                                                onHorizontalDragUpdate: (data) {
                                                  buttonDrag(data,
                                                      DragDirection.LEFT_TOP);
                                                },
                                                onVerticalDragUpdate: (data) {
                                                  buttonDrag(data,
                                                      DragDirection.LEFT_TOP);
                                                },
                                                onVerticalDragStart: (data) {
                                                  buttonDrag(data,
                                                      DragDirection.LEFT_TOP);
                                                },
                                                onHorizontalDragStart: (data) {
                                                  buttonDrag(data,
                                                      DragDirection.LEFT_TOP);
                                                },
                                              )),
                                          Positioned(
                                            // RIGHT_TOP
                                            left: left + rightCenter + cropSize * _currentRatioWidthValue - 10,
                                            top: top - 10,
                                            child: GestureDetector(
                                              child: CircleAvatar(
                                                child: Container(),
                                                radius: 10,
                                                backgroundColor:
                                                    AppColors.theme,
                                              ),
                                              onTapDown: onButtonPress,
                                              onHorizontalDragUpdate: (data) {
                                                buttonDrag(data,
                                                    DragDirection.RIGHT_TOP);
                                              },
                                              onVerticalDragUpdate: (data) {
                                                buttonDrag(data,
                                                    DragDirection.RIGHT_TOP);
                                              },
                                              onVerticalDragStart: (data) {
                                                buttonDrag(data,
                                                    DragDirection.RIGHT_TOP);
                                              },
                                              onHorizontalDragStart: (data) {
                                                buttonDrag(data,
                                                    DragDirection.RIGHT_TOP);
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            // LEFT_BOTTOM
                                            left: left - 10,
                                            top: top + cropSize * _currentRatioHeightValue - 10,
                                            child: GestureDetector(
                                              child: CircleAvatar(
                                                child: Container(),
                                                radius: 10,
                                                backgroundColor:
                                                    AppColors.theme,
                                              ),
                                              onTapDown: onButtonPress,
                                              onHorizontalDragUpdate: (data) {
                                                buttonDrag(data,
                                                    DragDirection.LEFT_BOTTOM);
                                              },
                                              onVerticalDragUpdate: (data) {
                                                buttonDrag(data,
                                                    DragDirection.LEFT_BOTTOM);
                                              },
                                              onVerticalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .LEFT_BOTTOM),
                                              onHorizontalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .LEFT_BOTTOM),
                                            ),
                                          ),
                                          Positioned(
                                            // RIGHT_BOTTOM
                                            left: left + rightCenter + cropSize * _currentRatioWidthValue - 10,
                                            top: top + cropSize * _currentRatioHeightValue - 10,
                                            child: GestureDetector(
                                              child: CircleAvatar(
                                                child: Container(),
                                                radius: 10,
                                                backgroundColor:
                                                    AppColors.theme,
                                              ),
                                              onTapDown: onButtonPress,
                                              onHorizontalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_BOTTOM),
                                              onVerticalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_BOTTOM),
                                              onVerticalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_BOTTOM),
                                              onHorizontalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_BOTTOM),
                                            ),
                                          ),
                                          Positioned(
                                            // LEFT_CENTRE
                                            left: left - 10,
                                            top: top + cropSize  / 2 * _currentRatioHeightValue - 10,
                                            child: GestureDetector(
                                              child: CircleAvatar(
                                                child: Container(),
                                                radius: 10,
                                                backgroundColor:
                                                AppColors.theme,
                                              ),
                                              onTapDown: onButtonPress,
                                              onHorizontalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .LEFT_CENTRE),
                                              onVerticalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .LEFT_CENTRE),
                                              onVerticalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .LEFT_CENTRE),
                                              onHorizontalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .LEFT_CENTRE),
                                            ),
                                          ),
                                          Positioned(
                                            // TOP_CENTRE
                                            left: left + cropSize / 2 * _currentRatioWidthValue - 10,
                                            top: top - 10,
                                            child: GestureDetector(
                                              child: CircleAvatar(
                                                child: Container(),
                                                radius: 10,
                                                backgroundColor:
                                                AppColors.theme,
                                              ),
                                              onTapDown: onButtonPress,
                                              onHorizontalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .TOP_CENTRE),
                                              onVerticalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .TOP_CENTRE),
                                              onVerticalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .TOP_CENTRE),
                                              onHorizontalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .TOP_CENTRE),
                                            ),
                                          ),
                                          Positioned(
                                            // BOTTOM_CENTRE
                                            left: left + cropSize / 2 * _currentRatioWidthValue - 10,
                                            top: top + cropSize  * _currentRatioHeightValue - 10,
                                            child: GestureDetector(
                                              child: CircleAvatar(
                                                child: Container(),
                                                radius: 10,
                                                backgroundColor:
                                                AppColors.theme,
                                              ),
                                              onTapDown: onButtonPress,
                                              onHorizontalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .BOTTOM_CENTRE),
                                              onVerticalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .BOTTOM_CENTRE),
                                              onVerticalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .BOTTOM_CENTRE),
                                              onHorizontalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .BOTTOM_CENTRE),
                                            ),
                                          ),
                                          Positioned(
                                            // RIGHT_CENTRE
                                            left: left + rightCenter + cropSize * _currentRatioWidthValue - 10,
                                            top: top + cropSize  / 2 * _currentRatioHeightValue - 10,
                                            child: GestureDetector(
                                              child: CircleAvatar(
                                                child: Container(),
                                                radius: 10,
                                                backgroundColor:
                                                AppColors.theme,
                                              ),
                                              onTapDown: onButtonPress,
                                              onHorizontalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_CENTRE),
                                              onVerticalDragUpdate: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_CENTRE),
                                              onVerticalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_CENTRE),
                                              onHorizontalDragStart: (data) =>
                                                  buttonDrag(
                                                      data,
                                                      DragDirection
                                                          .RIGHT_CENTRE),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 30,
                              top: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  appIconButton(
                                      icon: Icons.done,
                                      iconColor: Colors.green,
                                      background: Colors.transparent,
                                      onPress: () async {
                                        _onPressDone(
                                            imageFromLibrary,
                                            cropSize * _currentRatioWidthValue,
                                            cropSize * _currentRatioHeightValue,
                                            top,
                                            left,
                                            originalWidth,
                                            originalHeight,
                                            width ,
                                            height);
                                      },
                                      size: (kIsWeb) ? 50 : 30),
                                  appIconButton(
                                      icon: Icons.close,
                                      background: Colors.transparent,
                                      iconColor: Colors.grey.shade800,
                                      onPress: () async {
                                        Navigator.pop(context4);
                                      },
                                      size: (kIsWeb) ? 50 : 30),
                                  appIconButton(
                                      icon: Icons.rotate_left,
                                      background: Colors.transparent,
                                      iconColor: Colors.grey.shade800,
                                      onPress: () async {
                                        _currentRotationValue -= 1;
                                        if (_currentRotationValue > 3 ||
                                            _currentRotationValue < -3) {
                                          _currentRotationValue = 0;
                                        }
                                        if (_currentRotationDegreeValue != 0) {
                                          _currentRotationDegreeValue -= 90;
                                        } else {
                                          _currentRotationDegreeValue = 270;
                                        }
                                        setState2(() {});
                                      },
                                      size: (kIsWeb) ? 50 : 30),
                                  appIconButton(
                                      icon: Icons.rotate_right,
                                      background: Colors.transparent,
                                      iconColor: Colors.grey.shade800,
                                      onPress: () async {
                                        _currentRotationValue += 1;
                                        if (_currentRotationValue > 3 ||
                                            _currentRotationValue < -3) {
                                          _currentRotationValue = 0;
                                        }
                                        if (_currentRotationDegreeValue != 0) {
                                          _currentRotationDegreeValue += 90;
                                        } else {
                                          _currentRotationDegreeValue = 90;
                                        }
                                        setState2(() {});
                                      },
                                      size: (kIsWeb) ? 50 : 30),
                                ],
                              ),
                            ),
                          ],
                        );
                      });
                    } else if (data.hasError) {
                      _onImageEndLoading();
                      print("Error: ${data.error}");
                      // Navigator.pop(context);
                      // CustomAlert.showAlert('Something went Wrong',
                      //     handler: (msg) {});
                    } else {
                      _onImageStartLoading();
                      return CircularProgressIndicator(
                        backgroundColor: AppColors.theme,
                        strokeWidth: 3,
                      );
                    }
                    return Container();
                  }),
            );
          });
        });
  }

  void _onPressDone(
      Library.Image? imageFromLibrary,
      double cropSizeWidth,
      double cropSizeHeight,
      double top,
      double left,
      double originalWidth,
      double originalHeight,
      double width,
      double height) {
    if (imageFromLibrary == null) {
      print('IMAGE LIB DOES NOT ENCODED');
      return;
    }
    double wconst = (originalWidth / width), hconst = (originalHeight / height);
    final top2 = top * hconst;
    final left2 = left * wconst;
    // cropSize = cropSize * wconst;
    imageFromLibrary =
        Library.copyRotate(imageFromLibrary, _currentRotationDegreeValue);

    imageFromLibrary = Library.copyCrop(imageFromLibrary, left2.toInt(),
        top2.toInt(), (cropSizeWidth * wconst).toInt(), (cropSizeHeight * hconst).toInt());

    if (_outputImageSize != -1 && cropSizeWidth != _outputImageSize) {
      imageFromLibrary = Library.copyResize(imageFromLibrary,
          width: _outputImageSize.toInt(),
          interpolation: Library.Interpolation.average);
    }
    Uint8List byteInJpg =
        Uint8List.fromList(Library.encodeJpg(imageFromLibrary, quality: 100));
    _onImagePickListener(byteInJpg);
    Navigator.pop(_context);
  }

  Future<ui.Image> _bytesToImage(Uint8List imgBytes) async {
    ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  void changeRatio(setState2, ImageRatio ratio, int width, int height) {
    if(ratio==ImageRatio.RATIO_16_9){
      _minCropSize = 5;
    } else {
      _minCropSize = 20;
    }
    cropSize =
    (_outputImageSize == -1) ? _defaultCropSize / ((ratio==ImageRatio.RATIO_16_9) ? 5 : 2) : _outputImageSize;
    initCropSize =
    (_outputImageSize == -1) ? _defaultCropSize / ((ratio==ImageRatio.RATIO_16_9) ? 5 : 2) : _outputImageSize;

    _currentRatio = ratio;
    _currentRatioWidthValue = width;
    _currentRatioHeightValue = height;
    setState2((){});
  }

}

Library.Image drawImageInCenter(ImageDrawDetails details) {
  Library.Image src, dest = details.dest;
  src = Library.decodeImage(details.bytes)!;
  int xStart = ((details.width / 2) - (src.width / 2)).toInt();
  int xEnd = xStart + src.width;
  int yStart = ((details.height / 2) - (src.height / 2)).toInt();
  int yEnd = yStart + src.height;
  for (int x = 0; x < details.width; x++) {
    for (int y = 0; y < details.height; y++) {
      if (x >= xStart && x < xEnd && y >= yStart && y < yEnd) {
        int p = src.getPixel(x - xStart, y - yStart);
        if (Color(p).alpha == 0) {
          dest.setPixel(x, y, 0xffffff);
        } else {
          dest.setPixel(x, y, p);
        }
      } else {
        dest.setPixel(x, y, 0xffffff);
      }
    }
  }
  return dest;
}
