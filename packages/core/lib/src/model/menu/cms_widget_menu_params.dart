import 'package:flutter/widgets.dart';

/// Builds the menu header (logo / branding), pinned above the items.
///
/// [isCollapsed] is `true` when the rail is narrow (icons only) - return a
/// compact, text-less mark; `false` when the rail is expanded or shown as a
/// drawer - return the full lockup. Keep the returned widget's *height* equal
/// across both states (e.g. a fixed-height box) so the items below don't shift
/// when the rail toggles. The host owns the header's colours and alignment: on
/// a coloured menu (see [CmsWidgetMenuParams.backgroundColors]) return a header
/// that reads on the gradient.
// ignore: avoid_positional_boolean_parameters
typedef CmsMenuHeaderBuilder = Widget Function(BuildContext context, bool isCollapsed);

/// Host-facing menu configuration.
///
/// Behaviour is *not* configured here: the sidebar collapses / expands at
/// runtime (the top toggle icon, hover-peek), and rail-vs-drawer is chosen
/// automatically from the window width (see `CmsBreakpoints`). Hosts only
/// provide branding (the [headerBuilder]) and an optional colour
/// [backgroundColors].
class CmsWidgetMenuParams {
  final List<Color>? backgroundColors;

  /// Whether the rail may collapse. When `false` the sidebar is always shown at
  /// its full width: no hover-peek, no toggle, and the content next to it keeps
  /// a stable width instead of being pushed on every pass of the pointer.
  /// Ignored in drawer presentation, which is always full width.
  final bool isCollapsible;

  /// Builds the header shown at the top of the menu. Receives whether the rail
  /// is currently collapsed so the host can swap a full lockup for a bare mark.
  final CmsMenuHeaderBuilder? headerBuilder;

  const CmsWidgetMenuParams({this.backgroundColors, this.headerBuilder, this.isCollapsible = true});
}
