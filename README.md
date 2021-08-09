# image_cropping

### You can see that user can add background if they want. 
![Image Plugin](https://github.com/Mindinventory/image_cropping/blob/master/assets/image_plugin_1.gif)

### User can rotate the image if they want.
![Image Plugin](https://github.com/Mindinventory/image_cropping/blob/master/assets/image_plugin_1.gif)

### User can change the image ratio if they want.
![Image Plugin](https://github.com/Mindinventory/image_cropping/blob/master/assets/image_plugin_1.gif)


## Usage

### Example
    ImageCropper.cropImage(context, imageBytes!, () {
          showLoader();
        }, () {
          hideLoader();
        }, (data) {
          imageBytes = data;
          setState(() {});
        },
            selectedImageRatio: ImageRatio.RATIO_1_1,
            visibleOtherAspectRatios: true,
            squareBorderWidth: 2,
            squareCircleColor: Colors.black,
            defaultTextColor: Colors.orange,
            selectedTextColor: Colors.black,
            colorForWhiteSpace: Colors.grey
			);

### Required parameters

##### BuildContext:
context is use to push new screen for image cropping.

##### _imageBytes:
image bytes is use to draw image in device and if image not fits in device screen then we manage background color(if you have passed colorForWhiteSpace or else White background) in image cropping screen.

##### _onImageStartLoading:
this is a callback. you have to override and show dialog or etc when image cropping is in loading state.

##### _onImageEndLoading:
this is a callback. you have to override and hide dialog or etc when image cropping is ready to show result in cropping screen.

##### _onImageDoneListener:
this is a callback. you have to override and you will get Uint8List as result.

## Optional parameters

##### ImageRatio:
this property contains ImageRatio value. You can set the initialized a  spect ratio when starting the cropper by passing a value of ImageRatio. default value is `ImageRatio.FREE`

##### visibleOtherAspectRatios:
this property contains boolean value. If this properties is true then it shows all other aspect ratios in cropping screen. default value is `true`.

##### squareBorderWidth:
this property contains double value. You can change square border width by passing this value.

##### squareCircleColor:
this property contains Color value. You can change square circle color by passing this value.

#####  defaultTextColor:
this property contains Color value. By passing this property you can set aspect ratios color which are unselected.

##### selectedTextColor:
this property contains Color value. By passing this property you can set aspect ratios color which is selected.

##### colorForWhiteSpace:
this property contains Color value. By passing this property you can set background color, if screen contains blank space.


## Note:
The result returns in Uint8List. so it can be lost later, you are responsible for storing it somewhere permanent (if needed).

## Guideline for contributors
Contribution towards our repository is always welcome, we request contributors to create a pull request to the develop branch only.

## Guideline to report an issue/feature request
It would be great for us if the reporter can share the below things to understand the root cause of the issue.
- Library version
- Code snippet
- Logs if applicable
- Device specification like (Manufacturer, OS version, etc)
- Screenshot/video with steps to reproduce the issue

## Library used
- [Image](https://pub.dev/packages/image "Image")
- [flutter_image_compress](https://pub.dev/packages/flutter_image_compress "flutter_image_compress")

# LICENSE!
Image Cropper is [MIT-licensed](https://github.com/Mindinventory/image_cropping/blob/master/LICENSE "MIT-licensed").

# Let us know!
We’d be really happy if you send us links to your projects where you use our component. Just send an email to sales@mindinventory.com And do let us know if you have any questions or suggestion regarding our work.