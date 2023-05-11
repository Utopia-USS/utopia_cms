import 'package:flutter/material.dart';
import 'package:utopia_arch/utopia_arch.dart';

class CmsRouteConfigs {
  static RouteConfig transparentConfig<T>(
    Widget Function() builder, {
    RouteConfigOrientation? orientation,
  }) {
    return RouteConfig(
      routeBuilder: (settings, contentBuilder) => RawDialogRoute<T>(
        barrierColor: Colors.red,
        pageBuilder: (_, __, ___) => contentBuilder(),
        settings: settings,
      ),
      contentBuilder: builder,
      orientation: orientation,
    );
  }
}
