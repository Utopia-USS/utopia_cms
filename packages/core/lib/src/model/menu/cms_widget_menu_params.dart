import 'dart:ui';

enum CmsMenuType { standard, floating }

enum CmsMenuBehavior { flexible, collapsed, expanded }

class CmsWidgetMenuParams {
  final CmsMenuType type;
  final CmsMenuBehavior behavior;
  final List<Color>? backgroundColors;
  const CmsWidgetMenuParams({
    this.type = CmsMenuType.floating,
    this.behavior = CmsMenuBehavior.flexible,
    this.backgroundColors,
  });
}
