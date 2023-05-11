import 'package:flutter/material.dart';

class CmsThemeValues {
  final BorderRadius borderRadius;
  final EdgeInsets fieldContentPadding;
  final double pageTopPadding;
  final List<BoxShadow> menuShadow;
  final BorderRadius menuRadius;
  final double shortButtonWidth;

  const CmsThemeValues({
    required this.borderRadius,
    required this.menuRadius,
    required this.fieldContentPadding,
    required this.menuShadow,
    this.pageTopPadding = 48,
    this.shortButtonWidth = 144,
  });

  static final CmsThemeValues defaultTheme = CmsThemeValues(
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
  );
}
