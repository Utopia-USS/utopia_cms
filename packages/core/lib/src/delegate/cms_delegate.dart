import 'package:utopia_cms/src/delegate/cms_to_many_delegate.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/cms_functions_params.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table.dart';
import 'package:utopia_cms/src/util/json_map.dart';

///  * [CmsDelegate] is a main interface for handling [CmsTable] items.
///
/// It is not suitable on its own for handling toMany relationships. For this functionality check out [CmsToManyDelegate]
abstract class CmsDelegate {
  abstract final String idKey;

  /// Responsible for loading [CmsTable] items.
  Future<List<JsonMap>> get({
    CmsFunctionsSortingParams? sorting,
    CmsFilter filter,
    required CmsFunctionsPagingParams paging,
  });

  /// Responsible for updating existing item within the table
  Future<JsonMap> update(JsonMap value);

  /// Responsible for creating new object
  Future<JsonMap> create(JsonMap value);

  /// Responsible for deleting an object
  Future<void> delete(JsonMap value);
}
