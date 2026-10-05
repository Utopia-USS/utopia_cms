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
  ///  If false the field is read only in the edit flow, e.g. the id of an item
  ///  shouldn't be editable. Create-flow membership is decided by [initializable].
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

  const CmsEntryModifier({
    this.pinned = _alwaysPinned,
    this.editable = true,
    this.required = true,
    this.sortable = false,
    this.sortInvertNulls = false,
    this.expanded = false,
    this.initializable = true,
  });
}
