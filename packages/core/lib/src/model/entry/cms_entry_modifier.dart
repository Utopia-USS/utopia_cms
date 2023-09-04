
import 'package:utopia_cms/src/delegate/cms_delegate.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table.dart';
import 'package:utopia_cms/src/ui/item_management/view/cms_item_management_view.dart';

/// Modifies the behavior of the [CmsEntry]
class CmsEntryModifier {
  /// Defines whether the entry will be displayed in [CmsTable], otherwise it will be accessible only from create/manage flow.
  final bool pinned;

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

  /// If true the entry will be placed in the separate row in the [CmsItemManagementView]
  final bool expanded;



  const CmsEntryModifier({
    this.pinned = true,
    this.editable = true,
    this.required = true,
    this.sortable = false,
    this.expanded = false,
    this.initializable = true,
  });
}
