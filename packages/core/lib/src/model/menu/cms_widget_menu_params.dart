enum CmsMenuType { standard, floating }

enum CmsMenuBehavior { flexible, collapsed, expanded }

class CmsWidgetMenuParams {
  final CmsMenuType type;
  final CmsMenuBehavior behavior;

  const CmsWidgetMenuParams({
    this.type = CmsMenuType.floating,
    this.behavior = CmsMenuBehavior.flexible,
  });
}
