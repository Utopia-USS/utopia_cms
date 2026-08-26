import 'package:utopia_cms/src/delegate/cms_delegate.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/item_management/view/cms_management_view.dart' show CmsManagementView;
import 'package:utopia_cms/src/ui/widget/layout/cms_page_wrapper.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table.dart';

/// Default [CmsEntryModifier.pinned]: the column shows on every page type.
bool _alwaysPinned(CmsPageType pageType) => true;

/// Modifies the behavior of the [CmsEntry]
class CmsEntryModifier {
  /// Gates whether the entry is displayed as a column in [CmsTable], evaluated
  /// per [CmsPageType] so columns can be dropped on smaller screens
  /// (e.g. `(t) => !t.isMobile` hides the column on mobile, `(t) => t.isWeb`
  /// keeps it only on web).
  ///
  /// This affects the table column ONLY. The create/manage overlay always
  /// receives every entry regardless of what this returns.
  final bool Function(CmsPageType pageType) pinned;

  ///  Defines whether the entry is editable.
  ///
  ///  If false field will be read only in the management flow and not visible in the create flow
  ///  e.g. id of an item shouldn't be editable.
  final bool editable;

  ///  Defines whether the entry appears in the create flow.
  ///
  ///  If true field will appear in the create item flow
  ///  Field can be initializable and not editable (e.g. user e-mail)
  final bool initializable;

  ///  If true field will be necessary to create/edit item
  final bool required;

  /// Defines whether the [CmsTable] can be sorted by the value of the [CmsEntry]
  ///
  /// [CmsDelegate] must support sorting by the given field. Check its documentation for more information.
  final bool sortable;

  /// Inverts the sorting order of null values.
  ///
  /// Must be supported by the [CmsDelegate].
  /// Does nothing if [sortable] is false.
  final bool sortInvertNulls;

  /// If true the entry will be placed in the separate row in the [CmsManagementView]
  final bool expanded;

  /// Groups full-width entries into ONE shared row of the management form.
  ///
  /// Entries that are [expanded] normally take a row each. When several of
  /// them carry the same non-null [rowGroup], they are laid out side by side
  /// in a single row instead, splitting the width evenly. Useful for a set of
  /// small, related fields - three cover images, for example - that read as a
  /// set and waste a lot of vertical space stacked.
  ///
  /// Ignored for entries that are not [expanded]; those already share rows.
  final String? rowGroup;

  const CmsEntryModifier({
    this.pinned = _alwaysPinned,
    this.editable = true,
    this.required = true,
    this.sortable = false,
    this.sortInvertNulls = false,
    this.expanded = false,
    this.rowGroup,
    this.initializable = true,
  });
}
