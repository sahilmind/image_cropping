import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Library;
import 'package:image_cropper/model/image_draw_details.dart';
import 'package:image_cropper/common/inverted_clipper.dart';
import 'package:image_cropper/constant/color_constant.dart';
import 'package:image_cropper/constant/enums.dart';
import 'package:image_picker/image_picker.dart';

import 'common/app_button.dart';

class ImageCropping {
  BuildContext _context;
  void Function(Uint8List) _onImagePickListener;
  void Function() _onImageStartLoading;
  void Function() _onImageEndLoading;
  double _outputImageSize;
  double _defaultCropSize = 100;
  double _minCropSize = 10;

  ImageCropping(this._context, this._onImagePickListener,
      this._onImageStartLoading, this._onImageEndLoading,
      {double outputImageSize = -1})
      : _outputImageSize = outputImageSize;

  Future<void> cropImage() async {
    final double deviceWidth = MediaQuery
        .of(_context)
        .size
        .width;
    final double deviceHeight = MediaQuery
        .of(_context)
        .size
        .height;

    late double surfaceX = -1,
        surfaceY = -1,
        cropButtonXPosition = -1,
        cropButtonYPosition = -1;
    double width, height, originalWidth, originalHeight;
    double imgWidth, imgHeight;
    Library.Image? imageFromLibrary;

    if (kIsWeb) {
      _defaultCropSize = 200;
      _minCropSize = 40;
    } else {
      _defaultCropSize = 100;
      _minCropSize = 20;
    }

    double cropSize =
    (_outputImageSize == -1) ? _defaultCropSize : _outputImageSize;
    double initCropSize =
    (_outputImageSize == -1) ? _defaultCropSize : _outputImageSize;

    var pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);
    final imgBytes = await pickedFile?.readAsBytes();
    if (imgBytes == null) {
      return;
    }
    showDialog(
        context: _context,
        builder: (BuildContext context4) {
          return Material(
                child: FutureBuilder<ui.Image>(
                    future: _bytesToImage(imgBytes),
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
                                imgBytes,
                                Library.Image(originalWidth.toInt(),
                                    originalHeight.toInt()),
                                originalWidth.toInt(),
                                originalHeight.toInt()))
                            .then((value) {
                          imageFromLibrary = value;
                        });
                        final double maxCropSize = width > height
                            ? height
                            : width;
                        double left = (width / 2) - (cropSize / 2),
                            top = (height / 2) - (cropSize / 2);
                        return StatefulBuilder(builder: (context4, setState2) {
                          final imageWidget = Image.memory(
                            imgBytes,
                            alignment: Alignment.center,
                            fit: BoxFit.fill,
                            width: imgWidth,
                            height: imgHeight,
                          );
                          return Stack(
                            children: [
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
                                          left +=
                                              data.globalPosition.dx - surfaceX;
                                          top +=
                                              data.globalPosition.dy - surfaceY;
                                          checkTopLeft();
                                          setCropState(() {});
                                        }
                                        surfaceX = data.globalPosition.dx;
                                        surfaceY = data.globalPosition.dy;
                                      }

                                      void onButtonPress(data) {
                                        cropButtonXPosition =
                                            data.globalPosition.dx;
                                        cropButtonYPosition =
                                            data.globalPosition.dy;
                                      }

                                      void buttonDrag(data,
                                          DragDirection direction) {
                                        if (data == null) {
                                          return;
                                        }
                                        if (cropButtonXPosition != -1 &&
                                            cropButtonYPosition != -1) {
                                          double tmp = 0;
                                          if (direction ==
                                              DragDirection.LEFT_TOP) {
                                            tmp = (cropButtonXPosition -
                                                data.globalPosition.dx);
                                            left -= tmp;
                                            top -= tmp;
                                          } else if (direction ==
                                              DragDirection.LEFT_BOTTOM) {
                                            tmp = (cropButtonXPosition -
                                                data.globalPosition.dx);
                                            left -= tmp;
                                          } else if (direction ==
                                              DragDirection.RIGHT_TOP) {
                                            tmp = (data.globalPosition.dx -
                                                cropButtonXPosition);
                                            top -= tmp;
                                          } else if (direction ==
                                              DragDirection.RIGHT_BOTTOM) {
                                            tmp = (data.globalPosition.dx -
                                                cropButtonXPosition);
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
                                            data.globalPosition.dx;
                                        cropButtonYPosition =
                                            data.globalPosition.dy;
                                      }

                                      return Center(
                                        child: Container(
                                          width: width,
                                          height: height,
                                          color: Colors.white,
                                          child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Center(child: imageWidget),
                                                Positioned(
                                                    left: left,
                                                    top: top,
                                                    child: GestureDetector(
                                                      child: Container(
                                                        width: cropSize,
                                                        height: cropSize,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2)),
                                                      ),
                                                      onTapDown: (data) {
                                                        surfaceX =
                                                            data.globalPosition
                                                                .dx;
                                                        surfaceY =
                                                            data.globalPosition
                                                                .dy;
                                                      },
                                                      onHorizontalDragUpdate:
                                                      touchUpdate,
                                                      onVerticalDragUpdate: touchUpdate,
                                                      onVerticalDragStart: touchUpdate,
                                                      onHorizontalDragStart:
                                                      touchUpdate,
                                                    )),
                                                IgnorePointer(
                                                  child: ClipPath(
                                                    clipper: InvertedClipper(
                                                        left, top, cropSize,
                                                        context),
                                                    child: Container(
                                                      color: const Color
                                                          .fromRGBO(
                                                          0, 0, 0, 0.4),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  // LEFT_TOP
                                                    left: left - 10,
                                                    top: top - 10,
                                                    child: GestureDetector(
                                                      child: CircleAvatar(
                                                        child: Container(),
                                                        radius: 10,
                                                        backgroundColor:
                                                        AppColors.theme,
                                                      ),
                                                      onTapDown: onButtonPress,
                                                      onHorizontalDragUpdate: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .LEFT_TOP);
                                                      },
                                                      onVerticalDragUpdate: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .LEFT_TOP);
                                                      },
                                                      onVerticalDragStart: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .LEFT_TOP);
                                                      },
                                                      onHorizontalDragStart: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .LEFT_TOP);
                                                      },
                                                    )),
                                                Positioned(
                                                  // RIGHT_TOP
                                                    left: left + cropSize - 10,
                                                    top: top - 10,
                                                    child: GestureDetector(
                                                      child: CircleAvatar(
                                                        child: Container(),
                                                        radius: 10,
                                                        backgroundColor:
                                                        AppColors.theme,
                                                      ),
                                                      onTapDown: onButtonPress,
                                                      onHorizontalDragUpdate: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .RIGHT_TOP);
                                                      },
                                                      onVerticalDragUpdate: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .RIGHT_TOP);
                                                      },
                                                      onVerticalDragStart: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .RIGHT_TOP);
                                                      },
                                                      onHorizontalDragStart: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .RIGHT_TOP);
                                                      },
                                                    )),
                                                Positioned(
                                                  // LEFT_BOTTOM
                                                    left: left - 10,
                                                    top: top + cropSize - 10,
                                                    child: GestureDetector(
                                                      child: CircleAvatar(
                                                        child: Container(),
                                                        radius: 10,
                                                        backgroundColor:
                                                        AppColors.theme,
                                                      ),
                                                      onTapDown: onButtonPress,
                                                      onHorizontalDragUpdate: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .LEFT_BOTTOM);
                                                      },
                                                      onVerticalDragUpdate: (
                                                          data) {
                                                        buttonDrag(data,
                                                            DragDirection
                                                                .LEFT_BOTTOM);
                                                      },
                                                      onVerticalDragStart: (
                                                          data) =>
                                                          buttonDrag(
                                                              data,
                                                              DragDirection
                                                                  .LEFT_BOTTOM),
                                                      onHorizontalDragStart: (
                                                          data) =>
                                                          buttonDrag(
                                                              data,
                                                              DragDirection
                                                                  .LEFT_BOTTOM),
                                                    )),
                                                Positioned(
                                                  // RIGHT_BOTTOM
                                                    left: left + cropSize - 10,
                                                    top: top + cropSize - 10,
                                                    child: GestureDetector(
                                                      child: CircleAvatar(
                                                        child: Container(),
                                                        radius: 10,
                                                        backgroundColor:
                                                        AppColors.theme,
                                                      ),
                                                      onTapDown: onButtonPress,
                                                      onHorizontalDragUpdate: (
                                                          data) =>
                                                          buttonDrag(
                                                              data,
                                                              DragDirection
                                                                  .RIGHT_BOTTOM),
                                                      onVerticalDragUpdate: (
                                                          data) =>
                                                          buttonDrag(
                                                              data,
                                                              DragDirection
                                                                  .RIGHT_BOTTOM),
                                                      onVerticalDragStart: (
                                                          data) =>
                                                          buttonDrag(
                                                              data,
                                                              DragDirection
                                                                  .RIGHT_BOTTOM),
                                                      onHorizontalDragStart: (
                                                          data) =>
                                                          buttonDrag(
                                                              data,
                                                              DragDirection
                                                                  .RIGHT_BOTTOM),
                                                    )),
                                              ]),
                                        ),
                                      );
                                    }),
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
                                                cropSize,
                                                top,
                                                left,
                                                originalWidth,
                                                originalHeight,
                                                width,
                                                height);
                                          },
                                          size: 50),
                                      appIconButton(
                                          icon: Icons.close,
                                          background: Colors.transparent,
                                          iconColor: Colors.grey.shade800,
                                          onPress: () async {
                                            Navigator.pop(context4);
                                          },
                                          size: 50),
                                    ],
                                  ))
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
  }

  void _onPressDone(Library.Image? imageFromLibrary,
      double cropSize,
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
    double wconst = (originalWidth / width),
        hconst = (originalHeight / height);
    final top2 = top * hconst;
    final left2 = left * wconst;
    cropSize = cropSize * wconst;
    imageFromLibrary = Library.copyCrop(imageFromLibrary, left2.toInt(),
        top2.toInt(), cropSize.toInt(), cropSize.toInt());
    if (_outputImageSize != -1 && cropSize != _outputImageSize) {
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

}

Library.Image drawImageInCenter(ImageDrawDetails details) {
  Library.Image src,
      dest = details.dest;
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
