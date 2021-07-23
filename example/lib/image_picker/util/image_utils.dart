import 'package:image/image.dart' as Library;

Library.Image drawPixelInImage(Library.Image image, int x, int y, int color){
  image.setPixel(x, y, color);
  return image;
}