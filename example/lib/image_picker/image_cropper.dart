import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:example/image_picker/common/app_button.dart';
import 'package:example/image_picker/constant/color_constant.dart';
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Library;

import 'constant/enums.dart';
import 'util/image_converter.dart';
import 'util/widget_bound.dart';

class ImageCropper {
  BuildContext _context;
  Uint8List _imageBytes;
  ImageRatio selectedImageRatio = ImageRatio.FREE;
  bool visibleOtherAspectRatios = true;

  void Function() _onImageStartLoading;
  void Function() _onImageEndLoading;
  void Function(dynamic) _onImageDoneListener;

  double _leftTopDX = 0;
  double _leftTopDY = 0;

  double _leftBottomDX = 0;
  double _leftBottomDY = 0;

  double _rightTopDX = 0;
  double _rightTopDY = 0;

  double _rightBottomDX = 0;
  double _rightBottomDY = 0;

  double _imageWidth = 0;
  double _imageHeight = 0;
  double _deviceWidth = 0;
  double _deviceHeight = 0;

  double _defaultCropSize = 100;
  double _cropSizeWidth = 100;
  double _cropSizeHeight = 100;
  double _minCropSizeWidth = 20;
  double _minCropSizeHeight = 20;

  double _currentRatioWidth = 0;
  double _currentRatioHeight = 0;

  double squareBorderWidth;
  Color squareCircleColor;
  double squareCircleSize = 30;

  var _currentRotationValue = 0;
  var _currentRotationDegreeValue = 0;

  var _stackGlobalKey = GlobalKey();
  GlobalKey _imageGlobalKey = GlobalKey();
  GlobalKey _leftTopGlobalKey = GlobalKey();
  GlobalKey _leftBottomGlobalKey = GlobalKey();
  GlobalKey _rightTopGlobalKey = GlobalKey();
  GlobalKey _rightBottomGlobalKey = GlobalKey();
  GlobalKey _cropMenuGlobalKey = GlobalKey();

  late Library.Image _libraryImage;

  double _imageViewMaxWidth = 0;
  double _imageViewMaxHeight = 0;
  ui.Image? _image;

  ui.Image? uiImage = null;

  ImageCropper(
    this._context,
    this._imageBytes,
    this._onImageStartLoading,
    this._onImageEndLoading,
    this._onImageDoneListener, {
    this.selectedImageRatio = ImageRatio.FREE,
    this.visibleOtherAspectRatios = true,
    this.squareBorderWidth = 2,
    this.squareCircleColor = AppColors.theme,
    this.squareCircleSize = 30,
  });

  void showImageCroppingDialog() {
    _imageLoadingStarted();
    _generateLibraryImage();
    _setDeviceHeightWidth();
    _setDefaultButtonPosition();
    _pushScreen();
  }

  void _setDefaultButtonPosition() {
    _setLeftTopCropButtonPosition();
    _setLeftBottomCropButtonPosition();
    _setRightTopCropButtonPosition();
    _setRightBottomCropButtonPosition();
  }

  void _generateLibraryImage() {
    _libraryImage = Library.decodeImage(_imageBytes)!;
  }

  void _pushScreen() {
    Navigator.of(_context).push(PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) => manageStack()));
  }

  Widget manageStack() {
    return StatefulBuilder(
      builder: (BuildContext context, state) {
        return FutureBuilder<ui.Image>(
          future: bytesToImage(_imageBytes),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _imageLoadingFinished();
              uiImage = snapshot.data!;
              // set Image width and height.
              // if (_imageWidth == 0 && _imageHeight == 0) {
              _setImageHeightWidth(uiImage!);
              // changeImage(state);
              // }
              // show data.ggssv
              return SafeArea(
                child: Material(
                  child: Container(
                    width: _deviceWidth,
                    child: Column(
                      children: [
                        _showCroppingButtons(state),
                        _showCropImageView(state),
                        _showCropImageRatios(state),
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // show error
              _onImageDoneListener(snapshot.error.toString());
              return Container();
            } else {
              // show laoder
              return Container();
            }
          },
        );
      },
    );
  }

  Widget _showCropImageView(state) {
    return Expanded(
      child: getStackWidget(state),
    );
  }

  Widget getStackWidget(state) {
    return Stack(
      key: _stackGlobalKey,
      children: [
        loadImage(),
        showImageCropButtonsBorder(state),
        showImageCropLeftTopButton(state),
        showImageCropLeftBottomButton(state),
        showImageCropRightTopButton(state),
        showImageCropRightBottomButton(state),
      ],
    );
  }

  void changeImageRatio(state, ImageRatio imageRatio) {
    switch (imageRatio) {
      case ImageRatio.RATIO_1_2:
        _currentRatioWidth = 1;
        _currentRatioHeight = 2;
        break;
      case ImageRatio.RATIO_3_2:
        _currentRatioWidth = 3;
        _currentRatioHeight = 2;
        break;
      case ImageRatio.RATIO_4_3:
        _currentRatioWidth = 4;
        _currentRatioHeight = 3;
        break;
      case ImageRatio.RATIO_16_9:
        _currentRatioWidth = 16;
        _currentRatioHeight = 9;
        break;
      default:
        _currentRatioWidth = 1;
        _currentRatioHeight = 1;
    }
    _cropSizeWidth = _defaultCropSize;
    _cropSizeHeight = (_defaultCropSize * _currentRatioHeight) / _currentRatioWidth;
    selectedImageRatio = imageRatio;
    _setDefaultButtonPosition();
    state(() {});
  }

  Widget _showCropImageRatios(state) {
    return Visibility(
      visible: visibleOtherAspectRatios,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment:
              (kIsWeb) ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.FREE);
              },
              child: Text(
                "Free",
                style: TextStyle(
                  color: (selectedImageRatio == ImageRatio.FREE)
                      ? AppColors.theme
                      : AppColors.black,
                ),
              ),
            ),
            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_1_1);
              },
              child: Text(
                "1:1",
                style: TextStyle(
                  color: (selectedImageRatio == ImageRatio.RATIO_1_1)
                      ? AppColors.theme
                      : AppColors.black,
                ),
              ),
            ),
            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_1_2);
              },
              child: Text(
                "1:2",
                style: TextStyle(
                  color: (selectedImageRatio == ImageRatio.RATIO_1_2)
                      ? AppColors.theme
                      : AppColors.black,
                ),
              ),
            ),
            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_3_2);
              },
              child: Text(
                "3:2",
                style: TextStyle(
                  color: (selectedImageRatio == ImageRatio.RATIO_3_2)
                      ? AppColors.theme
                      : AppColors.black,
                ),
              ),
            ),
            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_4_3);
              },
              child: Text(
                "4:3",
                style: TextStyle(
                  color: (selectedImageRatio == ImageRatio.RATIO_4_3)
                      ? AppColors.theme
                      : AppColors.black,
                ),
              ),
            ),
            SizedBox(
              width: (kIsWeb) ? 20 : 0,
            ),
            InkWell(
              onTap: () {
                changeImageRatio(state, ImageRatio.RATIO_16_9);
              },
              child: Text(
                "16:9",
                style: TextStyle(
                  color: (selectedImageRatio == ImageRatio.RATIO_16_9)
                      ? AppColors.theme
                      : AppColors.black,
                ),
              ),
            ),
            SizedBox(
              width: (kIsWeb) ? 50 : 0,
              height: (kIsWeb) ? 50 : 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget loadImage() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _imageViewMaxWidth = constraints.maxWidth;
        _imageViewMaxHeight = constraints.maxHeight;
        return Center(
          child: Image.memory(
            _imageBytes,
            key: _imageGlobalKey,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _showCroppingButtons(state) {
    return Row(
      key: _cropMenuGlobalKey,
      mainAxisAlignment:
          (kIsWeb) ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
      children: [
        appIconButton(
          icon: Icons.rotate_left,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            _imageGlobalKey = GlobalKey();
            changeImageRotation(ImageRotation.LEFT, state);
          },
          size: squareCircleSize,
        ),
        appIconButton(
          icon: Icons.rotate_right,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            _imageGlobalKey = GlobalKey();
            changeImageRotation(ImageRotation.RIGHT, state);
          },
          size: squareCircleSize,
        ),
        appIconButton(
          icon: Icons.close,
          background: Colors.transparent,
          iconColor: Colors.grey.shade800,
          onPress: () async {
            Navigator.pop(_context);
          },
          size: squareCircleSize,
        ),
        appIconButton(
          icon: Icons.done,
          background: Colors.transparent,
          iconColor: Colors.green,
          onPress: () async {
            // _imageBytes = Uint8List.fromList(Library.encodeJpg(_libraryImage, quality: 100));
            _onPressDone(_context, _libraryImage, _leftTopDX, _leftTopDY,
                _cropSizeWidth, _cropSizeHeight, state);
          },
          size: squareCircleSize,
        ),
      ],
    );
  }

  void changeImageRotation(ImageRotation imageRotation, state) {
    _imageLoadingStarted();
    if (imageRotation == ImageRotation.LEFT) {
      _currentRotationValue -= 1;
      checkRotationValue();
      if (_currentRotationDegreeValue != 0) {
        _currentRotationDegreeValue -= 90;
      } else {
        _currentRotationDegreeValue = 270;
      }
    } else {
      _currentRotationValue += 1;
      checkRotationValue();
      if (_currentRotationDegreeValue != 0) {
        _currentRotationDegreeValue += 90;
      } else {
        _currentRotationDegreeValue = 90;
      }
    }
    _libraryImage =
        Library.copyRotate(_libraryImage, _currentRotationDegreeValue);
    _imageBytes =
        Uint8List.fromList(Library.encodeJpg(_libraryImage, quality: 100));
    _imageLoadingFinished();
    state(() {});
  }

  void checkRotationValue() {
    if (_currentRotationValue > 3 || _currentRotationValue < -3) {
      _currentRotationValue = 0;
    }
  }

  Widget showImageCropButtonsBorder(state) {
    return Positioned(
      left: _leftTopDX + 8,
      top: _leftTopDY + 8,
      child: GestureDetector(
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.ALL);
        },
        child: Container(
          width: _cropSizeWidth,
          height: _cropSizeHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: squareBorderWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget showImageCropLeftTopButton(state) {
    return Positioned(
      left: _leftTopDX,
      top: _leftTopDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _leftTopGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.LEFT_TOP);
        },
      ),
    );
  }

  Widget showImageCropLeftBottomButton(state) {
    return Positioned(
      left: _leftBottomDX,
      top: _leftBottomDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _leftBottomGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.LEFT_BOTTOM);
        },
      ),
    );
  }

  Widget showImageCropRightTopButton(state) {
    return Positioned(
      left: _rightTopDX,
      top: _rightTopDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _rightTopGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.RIGHT_TOP);
        },
      ),
    );
  }

  Widget showImageCropRightBottomButton(state) {
    return Positioned(
      left: _rightBottomDX,
      top: _rightBottomDY,
      child: GestureDetector(
        child: CircleAvatar(
          key: _rightBottomGlobalKey,
          radius: 10,
          child: Container(),
          backgroundColor: squareCircleColor,
        ),
        onPanUpdate: (details) {
          _buttonDrag(state, details, DragDirection.RIGHT_BOTTOM);
        },
      ),
    );
  }

  void _setDeviceHeightWidth() {
    _deviceWidth = MediaQuery.of(_context).size.width;
    _deviceHeight = MediaQuery.of(_context).size.height;
    print("_deviceWidth: ${_deviceWidth} _deviceHeight: ${_deviceHeight}");
  }

  void _setLeftTopCropButtonPosition({leftTopDx = -1, leftTopDy = -1}) {
    _leftTopDX = (leftTopDx == -1)
        ? ((_deviceWidth > _deviceHeight)
                ? _deviceHeight / 2
                : _deviceWidth / 2) -
            (_cropSizeWidth / 2)
        : leftTopDx;
    _leftTopDY = (leftTopDy == -1)
        ? ((_deviceWidth > _deviceHeight)
                ? _deviceHeight / 2
                : _deviceWidth / 2) -
            (_cropSizeWidth / 2)
        : leftTopDy;

    _leftTopDX;
    _leftTopDY;
    // print("_leftTopDX: ${_leftTopDX} _leftTopDY: ${_leftTopDY}");
  }

  void _setLeftBottomCropButtonPosition(
      {leftBottomDx = -1, leftBottomDy = -1}) {
    _leftBottomDX = (leftBottomDx == -1) ? _leftTopDX : leftBottomDx;
    _leftBottomDY =
        (leftBottomDy == -1) ? _leftTopDY + _cropSizeHeight : leftBottomDy;
    print("_leftTopDX: ${_leftTopDX} _leftTopDY: ${_leftTopDY}");
  }

  void _setRightTopCropButtonPosition({rightTopDx = -1, rightTopDy = -1}) {
    _rightTopDX = (rightTopDx == -1) ? _leftTopDX + _cropSizeWidth : rightTopDx;
    _rightTopDY = (rightTopDy == -1) ? _leftTopDY : rightTopDy;
    print("_rightTopDX: ${_rightTopDX} _rightTopDY: ${_rightTopDY}");
  }

  void _setRightBottomCropButtonPosition(
      {rightBottomDx = -1, rightBottomDy = -1}) {
    _rightBottomDX =
        (rightBottomDx == -1) ? _leftTopDX + _cropSizeWidth : rightBottomDx;
    _rightBottomDY =
        (rightBottomDy == -1) ? _rightTopDY + _cropSizeHeight : rightBottomDy;
    print("_rightTopDX: ${_rightTopDX} _rightTopDY: ${_rightTopDY}");
  }

  void _setImageHeightWidth(ui.Image image) {
    _imageWidth = image.width.toDouble();
    _imageHeight = image.height.toDouble();
    // print("_imageWidth: ${_imageWidth} _imageHeight: ${_imageHeight}");
  }

  void _buttonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    if (dragDirection == DragDirection.LEFT_TOP) {
      _manageLeftTopButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.LEFT_BOTTOM) {
      _manageLeftBottomButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.RIGHT_TOP) {
      _manageRightTopButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.RIGHT_BOTTOM) {
      _manageRightBottomButtonDrag(state, details, dragDirection);
    } else if (dragDirection == DragDirection.ALL) {
      _manageSquareDrag(state, details, dragDirection);
    }
    state(() {});
  }

  void _manageLeftTopButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX = details.globalPosition.dx - 10;
    var globalPositionDY = details.globalPosition.dy - 70;

    if (globalPositionDY < 1) {
      return;
    }

    var _previousLeftTopDX = _leftTopDX;
    var _previousLeftTopDY = _leftTopDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    print(
        "buttonDrag - _previousLeftTopDX: ${_previousLeftTopDX} _previousLeftTopDY: ${_previousLeftTopDY}");
    print(
        "_cropSizeWidth: ${_cropSizeWidth} _cropSizeHeight: ${_cropSizeHeight}");

    _leftTopDX = globalPositionDX;
    _leftTopDY = globalPositionDY;

    // this logic is for Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousLeftTopDX > _leftTopDX) {
        // moving to left side
        _cropSizeWidth += _previousLeftTopDX - _leftTopDX;
      } else {
        // moving to right side
        _cropSizeWidth -= _leftTopDX - _previousLeftTopDX;
      }

      // set crop size height
      if (_previousLeftTopDY > _leftTopDY) {
        // moving to top side
        _cropSizeHeight += _previousLeftTopDY - _leftTopDY;
      } else {
        // moving to bottom side
        _cropSizeHeight -= _leftTopDY - _previousLeftTopDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _leftTopDX = _previousLeftTopDX;
      } else if (_leftTopDX != _leftBottomDX) {
        // set left bottom when moving left top.
        _setLeftBottomCropButtonPosition(
            leftBottomDx: _leftTopDX, leftBottomDy: _leftBottomDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _leftTopDY = _previousLeftTopDY;
      } else if (_leftTopDY != _rightTopDY) {
        // set right top when moving left top.
        _setRightTopCropButtonPosition(
            rightTopDx: _rightTopDX, rightTopDy: _leftTopDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousLeftTopDX > _leftTopDX) {
        // moving to left side
        _cropSizeWidth +=
            (_previousLeftTopDX - _leftTopDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_previousLeftTopDX - _leftTopDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth -=
            (_leftTopDX - _previousLeftTopDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_leftTopDX - _previousLeftTopDX) * _currentRatioHeight;
      }

      if (_cropSizeWidth < _minCropSizeWidth ||
          _cropSizeHeight < _minCropSizeHeight ||
          _leftTopDX + _cropSizeWidth + squareCircleSize > _stackGlobalKey.globalPaintBounds!.width // this condition checks the right top crop button is outside the screen.
      ) {
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _leftTopDX = _previousLeftTopDX;
        _leftTopDY = _previousLeftTopDY;
        return;
      }
      _setLeftBottomCropButtonPosition(
          leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
      _setRightTopCropButtonPosition(
          rightTopDx: _leftTopDX + _cropSizeWidth, rightTopDy: _leftTopDY);
      _setRightBottomCropButtonPosition(
          rightBottomDx: _leftTopDX + _cropSizeWidth,
          rightBottomDy: _leftTopDY + _cropSizeHeight);

      print("buttonDrag - _leftTopDX: ${_leftTopDX} _leftTopDY: ${_leftTopDY}");
    }
  }

  void _manageLeftBottomButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX = details.globalPosition.dx - 10;
    var globalPositionDY = details.globalPosition.dy - 70;

    if ((globalPositionDY + squareCircleSize) >
        _stackGlobalKey.globalPaintBounds!.height) {
      return;
    }

    var _previousLeftBottomDX = _leftBottomDX;
    var _previousLeftBottomDY = _leftBottomDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    print(
        "buttonDrag - _previousLeftBottomDX: ${_previousLeftBottomDX} _previousLeftBottomDY: ${_previousLeftBottomDY}");

    _leftBottomDX = globalPositionDX;
    _leftBottomDY = globalPositionDY;

    // this logic is for Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousLeftBottomDX > _leftBottomDX) {
        // moving to left side
        _cropSizeWidth += _previousLeftBottomDX - _leftBottomDX;
      } else {
        // moving to right side
        _cropSizeWidth -= _leftBottomDX - _previousLeftBottomDX;
      }

      // set crop size height
      if (_previousLeftBottomDY > _leftBottomDY) {
        // moving to top side
        _cropSizeHeight -= _previousLeftBottomDY - _leftBottomDY;
      } else {
        // moving to bottom side
        _cropSizeHeight += _leftBottomDY - _previousLeftBottomDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _leftBottomDX = _previousLeftBottomDX;
      } else if (_leftBottomDX != _leftTopDX) {
        // set left top when moving left bottom.
        _setLeftTopCropButtonPosition(
            leftTopDx: _leftBottomDX, leftTopDy: _leftTopDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _leftBottomDY = _previousLeftBottomDY;
      } else if (_rightBottomDY != _leftBottomDY) {
        // set right bottom when moving left bottom.
        _setRightBottomCropButtonPosition(
            rightBottomDx: _rightBottomDX, rightBottomDy: _leftBottomDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousLeftBottomDX > _leftBottomDX) {
        // moving to left side
        _cropSizeWidth +=
            (_previousLeftBottomDX - _leftBottomDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_previousLeftBottomDX - _leftBottomDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth -=
            (_leftBottomDX - _previousLeftBottomDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_leftBottomDX - _previousLeftBottomDX) * _currentRatioHeight;
      }
      if (_cropSizeWidth < _minCropSizeWidth ||
          _cropSizeHeight < _minCropSizeHeight||
          _leftTopDX + _cropSizeWidth + squareCircleSize > _stackGlobalKey.globalPaintBounds!.width // this condition checks the right top crop button is outside the screen.
       ) {
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _leftBottomDX = _previousLeftBottomDX;
        _leftBottomDY = _previousLeftBottomDY;
        return;
      }
      _setLeftTopCropButtonPosition(
          leftTopDx: _leftBottomDX, leftTopDy: _leftBottomDY - _cropSizeHeight);
      _setRightTopCropButtonPosition(
          rightTopDx: _leftBottomDX + _cropSizeWidth, rightTopDy: _leftTopDY);
      _setRightBottomCropButtonPosition(
          rightBottomDx: _leftBottomDX + _cropSizeWidth,
          rightBottomDy: _leftBottomDY);
    }

    print(
        "buttonDrag - _leftBottomDX: ${_leftBottomDX} _leftBottomDY: ${_leftBottomDY}");
  }

  void _manageRightTopButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX = details.globalPosition.dx - 10;
    var globalPositionDY = details.globalPosition.dy - 70;

    if (globalPositionDY < 1) {
      return;
    }

    var _previousRightTopDX = _rightTopDX;
    var _previousRightTopDY = _rightTopDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    print(
        "previous->buttonDrag - _previousRightTopDX: ${_previousRightTopDX} _previousRightTopDY: ${_previousRightTopDY}");

    _rightTopDX = globalPositionDX;
    _rightTopDY = globalPositionDY;

    // this logic is Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      // set crop size width
      if (_previousRightTopDX > _rightTopDX) {
        // moving to left side
        _cropSizeWidth -= _previousRightTopDX - _rightTopDX;
      } else {
        // moving to right side
        _cropSizeWidth += _rightTopDX - _previousRightTopDX;
      }

      // set crop size height
      if (_previousRightTopDY > _rightTopDY) {
        // moving to top side
        _cropSizeHeight += _previousRightTopDY - _rightTopDY;
      } else {
        // moving to bottom side
        _cropSizeHeight -= _rightTopDY - _previousRightTopDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _rightTopDX = _previousRightTopDX;
      } else if (_rightTopDX != _rightBottomDX) {
        // set right bottom when moving right top.
        _setRightBottomCropButtonPosition(
            rightBottomDx: _rightTopDX, rightBottomDy: _rightBottomDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _rightTopDY = _previousRightTopDY;
      } else if (_rightTopDY != _leftTopDY) {
        // set right bottom when moving right top.
        _setLeftTopCropButtonPosition(
            leftTopDx: _leftTopDX, leftTopDy: _rightTopDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousRightTopDX > _rightTopDX) {
        // moving to left side
        _cropSizeWidth -=
            (_previousRightTopDX - _rightTopDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_previousRightTopDX - _rightTopDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth +=
            (_rightTopDX - _previousRightTopDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_rightTopDX - _previousRightTopDX) * _currentRatioHeight;
      }

      // check crop size less than declared min crop size. then set to previous size.
      if (_cropSizeWidth < _minCropSizeWidth ||
          _cropSizeHeight < _minCropSizeHeight
          ||
          (_rightTopDX - _cropSizeWidth) < 1 // this condition checks the left top crop button is outside the screen.
      ) {
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _rightTopDX = _previousRightTopDX;
        _rightTopDY = _previousRightTopDY;
        return;
      }

      _setLeftTopCropButtonPosition(
          leftTopDx: _rightTopDX - _cropSizeWidth, leftTopDy: _rightTopDY);
      _setLeftBottomCropButtonPosition(
          leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
      _setRightBottomCropButtonPosition(
          rightBottomDx: _rightTopDX,
          rightBottomDy: _rightTopDY + _cropSizeHeight);
    }

    print(
        "buttonDrag - _rightBottomDX: ${_rightBottomDX} _rightBottomDY: ${_rightBottomDY}");
  }

  void _manageRightBottomButtonDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {
    var globalPositionDX = details.globalPosition.dx - 10;
    var globalPositionDY = details.globalPosition.dy - 70;

    /*print("stack: ${}");
    print("stack bottom: ${_stackGlobalKey.globalPaintBounds!.bottom}");
*/
    if ((globalPositionDY + squareCircleSize) >
        _stackGlobalKey.globalPaintBounds!.height) {
      return;
    }

    var _previousRightBottomDX = _rightBottomDX;
    var _previousRightBottomDY = _rightBottomDY;
    var _previousCropWidth = _cropSizeWidth;
    var _previousCropHeight = _cropSizeHeight;

    print(
        "previous->buttonDrag - _rightBottomDX: ${_rightBottomDX} _rightBottomDY: ${_rightBottomDY}");

    _rightBottomDX = globalPositionDX;
    _rightBottomDY = globalPositionDY;

    // this logic is Free ratio
    if (selectedImageRatio == ImageRatio.FREE) {
      print(
          "_cropSizeWidth: ${_cropSizeWidth} _minCropSizeWidth: ${_minCropSizeWidth}");

      // set crop size width
      if (_previousRightBottomDX > _rightBottomDX) {
        // moving to left side
        _cropSizeWidth -= _previousRightBottomDX - _rightBottomDX;
      } else {
        // moving to right side
        _cropSizeWidth += _rightBottomDX - _previousRightBottomDX;
      }

      // set crop size height
      if (_previousRightBottomDY > _rightBottomDY) {
        // moving to top side
        _cropSizeHeight -= _previousRightBottomDY - _rightBottomDY;
      } else {
        // moving to bottom side
        _cropSizeHeight += _rightBottomDY - _previousRightBottomDY;
      }

      if (_cropSizeWidth < _minCropSizeWidth) {
        _cropSizeWidth = _previousCropWidth;
        _rightBottomDX = _previousRightBottomDX;
      } else if (_rightBottomDX != _rightTopDX) {
        // set right top when moving right bottom.
        _setRightTopCropButtonPosition(
            rightTopDx: _rightBottomDX, rightTopDy: _rightTopDY);
      }

      if (_cropSizeHeight < _minCropSizeHeight) {
        _cropSizeHeight = _previousCropHeight;
        _rightBottomDY = _previousRightBottomDY;
      } else if (_rightBottomDY != _leftBottomDY) {
        // set left bottom when moving right bottom.
        _setLeftBottomCropButtonPosition(
            leftBottomDx: _leftBottomDX, leftBottomDy: _rightBottomDY);
      }
    } else {
      // this will executes whenever any ratio is selected.
      // set crop size width
      if (_previousRightBottomDX > _rightBottomDX) {
        // moving to left side
        _cropSizeWidth -=
            (_previousRightBottomDX - _rightBottomDX) * _currentRatioWidth;
        _cropSizeHeight -=
            (_previousRightBottomDX - _rightBottomDX) * _currentRatioHeight;
      } else {
        // moving to right side
        _cropSizeWidth +=
            (_rightBottomDX - _previousRightBottomDX) * _currentRatioWidth;
        _cropSizeHeight +=
            (_rightBottomDX - _previousRightBottomDX) * _currentRatioHeight;
      }

      // check crop size less than declared min crop size. then set to previous size.
      if (_cropSizeWidth < _minCropSizeWidth ||
          _cropSizeHeight < _minCropSizeHeight ||
          (_rightTopDX - _cropSizeWidth) < 1 // this condition checks the left top crop button is outside the screen.
      ) {
        _cropSizeWidth = _previousCropWidth;
        _cropSizeHeight = _previousCropHeight;
        _rightBottomDX = _previousRightBottomDX;
        _rightBottomDY = _previousRightBottomDY;
        return;
      }

      _setRightTopCropButtonPosition(
          rightTopDx: _rightBottomDX,
          rightTopDy: _rightBottomDY - _cropSizeHeight);
      _setLeftTopCropButtonPosition(
          leftTopDx: _rightTopDX - _cropSizeWidth, leftTopDy: _rightTopDY);
      _setLeftBottomCropButtonPosition(
          leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
    }
    print(
        "buttonDrag - _rightBottomDX: ${_rightBottomDX} _rightBottomDY: ${_rightBottomDY}");
  }

  void _manageSquareDrag(
      state, DragUpdateDetails details, DragDirection dragDirection) {

    var globalPositionDX = details.globalPosition.dx - 70;
    var globalPositionDY = details.globalPosition.dy - 70;


    if (globalPositionDX < 1 ||
        (globalPositionDX + _cropSizeWidth + (squareCircleSize / 2)) >
            _deviceWidth){
      globalPositionDX = _leftTopDX;
    }

    if (globalPositionDY < 1 ||
        (globalPositionDY + _cropSizeHeight + (squareCircleSize / 2)) >
            _imageViewMaxHeight){
      globalPositionDY = _leftTopDY;
    }
    _setLeftTopCropButtonPosition(
        leftTopDx: globalPositionDX, leftTopDy: globalPositionDY);
    _setLeftBottomCropButtonPosition(
        leftBottomDx: _leftTopDX, leftBottomDy: _leftTopDY + _cropSizeHeight);
    _setRightTopCropButtonPosition(
        rightTopDx: _leftTopDX + _cropSizeWidth, rightTopDy: _leftTopDY);
    _setRightBottomCropButtonPosition(
        rightBottomDx: _rightTopDX,
        rightBottomDy: _rightTopDY + _cropSizeHeight);
  }

  bool isPointerOutside(double globalPositionDX, double globalPositionDY) {
    if (globalPositionDX < 1 ||
        globalPositionDY < 1 ||
        (globalPositionDX + _cropSizeWidth + (squareCircleSize / 2)) >
            _deviceWidth ||
        (globalPositionDY + _cropSizeHeight + (squareCircleSize / 2)) >
            _imageViewMaxHeight) {
      print(
          "isPointerOutside: globalPositionDX: $globalPositionDX  globalPositionDY:$globalPositionDY");
      print(
          "isPointerOutside: globalPositionDX: $globalPositionDX  globalPositionDY:$globalPositionDY");
      return true;
    }
    return false;
  }

  void _onPressDone(BuildContext context, Library.Image sourceImage, double x,
      double y, double width, double height, state) {
    // image view width / height
    var imageViewWidth = _imageGlobalKey.globalPaintBounds!.width;
    var imageViewHeight = _imageGlobalKey.globalPaintBounds!.height;

    var stackWidth = _stackGlobalKey.globalPaintBounds!.width;
    var stackHeight = _stackGlobalKey.globalPaintBounds!.height;

    _libraryImage = setWhiteColorInImage(_libraryImage, _imageWidth,
        _imageHeight, imageViewWidth, imageViewHeight, stackWidth, stackHeight);

    /*_imageBytes =
        Uint8List.fromList(Library.encodeJpg(_libraryImage, quality: 100));
    state(() {});

    return;*/
    _imageWidth = _libraryImage.width.toDouble();
    _imageHeight = _libraryImage.height.toDouble();

    print("_imageWidth: $_imageWidth");
    print("_imageHeight: $_imageHeight");

    print("imageViewWidth: $imageViewWidth");
    print("imageViewHeight: $imageViewHeight");

    var leftX = _leftTopDX;
    var leftY = _leftTopDY;

    var imageCropX = (_imageWidth * leftX) / stackWidth;
    var imageCropY = (_imageHeight * leftY) / stackHeight;
    var imageCropWidth = (_imageWidth * _cropSizeWidth) / stackWidth;
    var imageCropHeight = (_imageHeight * _cropSizeHeight) / stackHeight;

    _libraryImage = Library.copyCrop(_libraryImage, imageCropX.toInt(),
        imageCropY.toInt(), imageCropWidth.toInt(), imageCropHeight.toInt());

    var _libraryUInt8List =
        Uint8List.fromList(Library.encodeJpg(_libraryImage, quality: 100));
    _onImageDoneListener(_libraryUInt8List);
    Navigator.pop(_context);
  }

  void _imageLoadingStarted() {
    _onImageStartLoading();
  }

  void _imageLoadingFinished() {
    _onImageEndLoading();
  }
}

Library.Image setWhiteColorInImage(
    Library.Image image,
    double imageWidth,
    double imageHeight,
    double renderedImageWidth,
    double renderedImageHeight,
    double stackWidth,
    double stackHeight) {
  bool isWhiteVisibleInScreenWidth = stackWidth > renderedImageWidth;
  bool isWhiteVisibleInScreenHeight = stackWidth > renderedImageHeight;

  double finalImageWidth = (stackWidth > imageWidth)
      ? stackWidth
      : (isWhiteVisibleInScreenWidth)
          ? (stackWidth * imageWidth) / renderedImageWidth
          : imageWidth;
  double finalImageHeight = (stackHeight > imageHeight)
      ? stackHeight
      : (isWhiteVisibleInScreenHeight)
          ? (stackHeight * imageHeight) / renderedImageHeight
          : imageHeight;

  int centreImageWidthPoint = ((finalImageWidth / 2) -
          (((finalImageWidth * renderedImageWidth) / stackWidth) / 2))
      .toInt();

  int centreImageHeightPoint = ((finalImageHeight / 2) -
          (((finalImageHeight * renderedImageHeight) / stackHeight) / 2))
      .toInt();

  var whiteImage =
      Library.Image(finalImageWidth.toInt(), finalImageHeight.toInt());
  whiteImage = whiteImage.fill(0xffffff);
  var mergedImage = Library.drawImage(whiteImage, image,
      dstX: centreImageWidthPoint, dstY: centreImageHeightPoint);
  return mergedImage;
}
