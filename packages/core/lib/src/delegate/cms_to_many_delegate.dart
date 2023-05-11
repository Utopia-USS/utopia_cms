import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:utopia_cms/src/delegate/cms_delegate.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/entry/primitives/cms_to_many_dropdown_entry.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table.dart';
import 'package:utopia_cms/src/util/json_map.dart';

///  * [CmsToManyDelegate] is an interface for handling toMany relationships.
///
/// This serves as an independent from [CmsDelegate] part of the server-logic for the [CmsTable]
/// For handling more complex relationships
abstract class CmsToManyDelegate {
  abstract final String originIdKey, foreignIdKey;

  /// Responsible for getting related objects.
  ///
  /// if [originId] equals null, it should return all relationships defined for the origin
  /// [filter] is responsible for filtering options. To find out more check [CmsToManyDropdownEntry]
  Future<List<JsonMap>> get({Object? originId, CmsFilter filter});

  /// Responsible for updating any changes in the references
  Future<void> update({
    required Object originId,
    required ISet<Object> addedForeignIds,
    required ISet<Object> removedForeignIds,
  });
}
