# image_cropping

#### Usage

**Required parameters **

**BuildContext**: context is use to push new screen for image cropping.

**_imageBytes**: image bytes is use to draw image in device and if image not fits in device screen then we manage background color(if you have passed colorForWhiteSpace or else White background) in image cropping screen.

**_onImageStartLoading**: this is a callback. you have to override and show dialog or etc when image cropping is in loading state.

**_onImageEndLoading**: this is a callback. you have to override and hide dialog or etc when image cropping is ready to show result in cropping screen.

**_onImageDoneListener**: this is a callback. you have to override and you will get Uint8List as result.

#### Optional parameters

- **ImageRatio**: this property contains ImageRatio value. You can set the initialized aspect ratio when starting the cropper by passing a value of ImageRatio. default value is `ImageRatio.FREE`

- **visibleOtherAspectRatios**: this property contains boolean value. If this properties is true then it shows all other aspect ratios in cropping screen. default value is `true`.

- **squareBorderWidth**: this property contains double value. You can change square border width by passing this value.

- **squareCircleColor**: this property contains Color value. You can change square circle color by passing this value.

- **squareCircleSize**: this property contains double value. You can change square circle size by passing this value.

- **defaultTextColor**: this property contains Color value. By passing this property you can set aspect ratios color which are unselected.

- **selectedTextColor**: this property contains Color value. By passing this property you can set aspect ratios color which is selected.

- **colorForWhiteSpace**: this property contains Color value. By passing this property you can set background color, if screen contains blank space.

**Note**
The result returns in Uint8List. so it can be lost later, you are responsible for storing it somewhere permanent (if needed).