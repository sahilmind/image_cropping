import 'dart:typed_data';
import 'package:image/image.dart' as Library;

class ImageDrawDetails {
  Uint8List bytes;
  Library.Image dest;
  int width, height;

  ImageDrawDetails(this.bytes, this.dest, this.width, this.height);
}