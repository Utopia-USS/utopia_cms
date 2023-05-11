import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:utopia_cms/src/theme/cms_theme_colors.dart';
import 'package:utopia_cms/src/theme/cms_theme_text_styles.dart';

part 'cms_theme_data.freezed.dart';

@freezed
class CmsThemeData with _$CmsThemeData {
  const CmsThemeData._();

  const factory CmsThemeData({
    required CmsThemeColors colors,
    required CmsThemeTextStyles textStyles,
    required BorderRadius borderRadius,
    required EdgeInsets fieldContentPadding,
    required double pageTopPadding,
    required List<BoxShadow> menuShadow,
    required BorderRadius menuRadius,
    required double shortButtonWidth,
  }) = _CmsThemeData;

  static final CmsThemeData defaultTheme = CmsThemeData(
    colors: CmsThemeColors.defaultTheme,
    textStyles: CmsThemeTextStyles.defaultTheme,
    menuRadius: BorderRadius.circular(12),
    borderRadius: BorderRadius.circular(6),
    fieldContentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    menuShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        offset: const Offset(3, 3), //(x,y)
        blurRadius: 14,
      ),
    ],
    pageTopPadding: 48,
    shortButtonWidth: 144,
  );

  BoxDecoration get fieldDecoration => BoxDecoration(
        borderRadius: borderRadius,
        color: colors.field,
      );
}
