import 'package:utopia_cms/src/model/cms_table_page_params.dart';
import 'package:utopia_cms/src/ui/table_page/widget/cms_table_actions.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_item.dart';
import 'package:utopia_cms/src/util/json_map.dart';

///  * [CmsTableAction] appears in the [CmsTableItem] popUpMenu. Default actions "delete" and "edit" are generated
///  automatically based on [CmsTableParams]
///  * [label] is displayed after pressing [CmsTableActionsButton]
///  * [onPressed] is triggered after pressing the item. It provides current item [JsonMap] value. If [shouldUpdateTable]
///  is true and result != null, item will be updated in the table.

class CmsTableAction {
  final String label;
  final bool shouldUpdateTable;
  final Future<JsonMap?> Function(JsonMap value) onPressed;

  CmsTableAction({
    required this.label,
    required this.shouldUpdateTable,
    required this.onPressed,
  });
}
