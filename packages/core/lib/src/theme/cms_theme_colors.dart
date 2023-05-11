import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cms_theme_colors.freezed.dart';

@freezed
class CmsThemeColors with _$CmsThemeColors {
  const CmsThemeColors._();

  factory CmsThemeColors({
    required Color primary,
    required Color accent,
    required Color field,
    required Color canvas,
    required Color error,
    required Color disabled,
  }) = _CmsThemeColors;

  static final CmsThemeColors defaultTheme = CmsThemeColors(
    primary: Colors.indigoAccent[200]!,
    accent: Colors.indigoAccent,
    error: Colors.redAccent,
    field: const Color(0xFFEDEDED),
    canvas: Colors.grey[100]!,
    disabled: Colors.grey[400]!,
  );
}
