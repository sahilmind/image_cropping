import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropping/constant/color_constant.dart';

class AppLoader {

  static void show(BuildContext context){
    Loader.show(context,
        progressIndicator: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Stack(
                children: [
                  const Opacity(
                    opacity: 0.3,
                    child: ModalBarrier(dismissible: false, color: Colors.grey),
                  ),
                  Center(
                    child: Material(
                      type: MaterialType.transparency,
                      elevation: 20,
                      child: SpinKitCubeGrid(
                        size: 100.0,
                        color: AppColors.theme,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        themeData: Theme.of(context).copyWith(accentColor: Colors.white)
    );
  }

  static void hide(){
    Loader.hide();
  }
}
