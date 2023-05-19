import 'package:utopia_cms/src/model/table_action/cms_table_action.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_item.dart';
import 'package:utopia_cms/src/ui/item_management/cms_item_management_page.dart';

/// Modifies basic actions' behavior in the [CmsTable]
class CmsTableParams {
  /// Defines whether new objects can be created by user
  ///
  /// If true button appears that navigates for generic creation flow in the [CmsItemManagement]
  final bool canCreate;

  /// Defines whether new objects can be deleted by user
  ///
  /// If true [CmsTableAction] appears in the [CmsTableItem]
  final bool canDelete;

  /// Defines whether new objects can be edited by user
  ///
  /// If true [CmsTableAction] appears in the [CmsTableItem]
  final bool canEdit;


  CmsTableParams({
    this.canEdit = true,
    this.canCreate = true,
    this.canDelete = true,
  });

  static final CmsTableParams defaultParams = CmsTableParams();
}
