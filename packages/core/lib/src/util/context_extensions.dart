import 'package:flutter/widgets.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/theme/cms_theme_colors.dart';
import 'package:utopia_cms/src/theme/cms_theme_data.dart';
import 'package:utopia_cms/src/theme/cms_theme_text_styles.dart';

extension CmsContextExtensions on BuildContext {
  CmsThemeData get theme {
    final data = getUnsafe(CmsThemeData) as CmsThemeData?;
    return data ?? CmsThemeData.defaultTheme;
  }

  CmsThemeColors get colors => theme.colors;

  CmsThemeTextStyles get textStyles => theme.textStyles;

  BoxDecoration get fieldDecoration => theme.fieldDecoration;
}
