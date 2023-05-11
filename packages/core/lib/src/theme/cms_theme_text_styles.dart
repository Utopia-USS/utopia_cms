import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cms_theme_text_styles.freezed.dart';

@freezed
class CmsThemeTextStyles with _$CmsThemeTextStyles {
  const CmsThemeTextStyles._();

  const factory CmsThemeTextStyles({
    required TextStyle header,
    required TextStyle label,
    required TextStyle text,
    required TextStyle title,
    required TextStyle caption,
    required TextStyle button,
  }) = _CmsThemeTextStyles;

  static const CmsThemeTextStyles defaultTheme = CmsThemeTextStyles(
    header: TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: Colors.black87,
      letterSpacing: 1,
    ),
    label: TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.black87,
      letterSpacing: 1,
    ),
    caption: TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      fontSize: 10,
      color: Colors.black87,
      letterSpacing: 1,
    ),
    text: TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.black87,
      letterSpacing: 1,
    ),
    title: TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Colors.black87,
      letterSpacing: 1,
    ),
    button: TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: Colors.white,
      letterSpacing: 1,
    ),
  );
}
