import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_constant.dart';

// ignore: avoid_classes_with_only_static_members
class AppFontStyle {


  static TextStyle appButton(double fontSize) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  static TextStyle appButtonThin(double fontSize) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w200,
      ),
    );
  }

  static TextStyle cancelButton(double fontSize) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  static TextStyle textFiledNormal({Color color = Colors.black}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.normal,
        fontSize: 15,
      ),
    );
  }


  static TextStyle textFieldPlaceholder({Color color = Colors.grey}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  static TextStyle customAlertTitle(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontSize: 15,
      ),
    );
  }

  static TextStyle createAAccountText(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  static TextStyle dropDownText(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 15.0,
      ),
    );
  }

  static TextStyle dropDownTextHint(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: AppColors.ffB8B8B8,
        fontWeight: FontWeight.w400,
        fontSize: 15.0,
      ),
    );
  }

  static TextStyle dropDownTextSelected(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 15.0,
      ),
    );
  }


  static TextStyle defaultTextStyle({Color color = Colors.black,double fontSize=12.0,FontWeight fontWeight=FontWeight.normal}){
    return GoogleFonts.poppins(
      textStyle: TextStyle(color: color, fontSize: fontSize,fontWeight: fontWeight),
    );
  }

  static TextStyle textLinkStyle(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(color: AppColors.theme, fontSize: 12.0),
    );
  }

  static TextStyle leftMenuItem({Color color = Colors.white}){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w400,
        fontSize: 15.0,
      ),
    );
  }

  static TextStyle settingTitle(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
      ),
    );
  }

  static TextStyle settingPageTitle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static TextStyle venueListItemName(){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 15.0,
      ),
    );
  }

  static TextStyle boldCountryDialCode({Color color=Colors.black}){
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 15.0,
      ),
    );
  }

  static TextStyle descriptionText({FontWeight fontWeight = FontWeight.normal, double fontSize = 12,Color color = Colors.grey}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
      ),
    );
  }

  static TextStyle openCloseTime() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    );
  }
}