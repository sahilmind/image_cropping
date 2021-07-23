import 'package:flutter/material.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }

  Offset? get getOffset {
    final RenderBox renderObject = currentContext?.findRenderObject() as RenderBox;
    final positionRed = renderObject.localToGlobal(Offset.zero);
    return Offset(positionRed.dx, positionRed.dy);
  }

  Size? get getSize {
    final RenderBox renderObject = currentContext?.findRenderObject() as RenderBox;
    final positionRed = renderObject.localToGlobal(Offset.zero);
    return renderObject.size;
  }

}