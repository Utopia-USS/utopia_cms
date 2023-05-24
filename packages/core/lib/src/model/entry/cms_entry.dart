import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/model/entry/primitives/cms_bool_entry.dart';
import 'package:utopia_cms/src/model/entry/primitives/cms_date_entry.dart';
import 'package:utopia_cms/src/model/entry/primitives/cms_text_entry.dart';
import 'package:utopia_cms/src/model/entry/primitives/cms_to_many_dropdown_entry.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_item.dart';
import 'package:utopia_cms/src/ui/common/wrapper/cms_field_wrapper.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_item_management_state.dart';
import 'package:utopia_cms/src/ui/table_page/cms_table_page.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';
import 'package:utopia_cms/src/util/string_extensions.dart';

///  * [CmsEntry] is an interface of a basic [CmsTablePage] component.
///
/// There are few basic entries already implemented:
///  *[CmsBoolEntry] for handling [bool] values
///  *[CmsTextEntry] for handling [String] values
///  *[CmsDateEntry] for handling [DateTime] values
///  *[CmsToManyDropdownEntry] for handling toMany references
@optionalTypeArgs
abstract class CmsEntry<T> {
  ///  * [key] is a path to the value in [JsonMap]. It may be staggered e.g. [user.data.image]. To see how it works
  ///  check [JsonMapExtensions]
  abstract final String key;

  ///  * [label] displays the name of the entry. To find out more check [fixedLabel]
  abstract final String? label;

  /// Modifies the behavior of the [CmsEntry]
  abstract final CmsEntryModifier modifier;

  ///  * Defines size of the [CmsTableItem] in the [CmsTable]
  abstract final int flex;

  ///  Builder for edit/create flow. It provides [context], current [value] and [onChanged] method.
  ///  It is recommended to wrap it in the [CmsFieldWrapper].
  ///
  /// This function has access to [CmsItemManagementBaseState] using [Provider]. It can use it to register onSaved.
  Widget buildEditField({required BuildContext context, required T value, required void Function(T) onChanged});

  /// Preview of the value shown in the [CmsTable]
  Widget buildPreview(BuildContext context, T value);

  /// simple toJson method, e.g. 12.toString for an int value.
  Object? toJson(T value) => value;

  /// simple fromJson method, e.g. int.parse(json.toString) for an int value.
  T? fromJson(Object? json) => json as T?;

  /// Real display of the field. If null, last segment of [key] is displayed
  String get fixedLabel => label ?? key.split('.').last;

  /// Adds * at the end of the label
  String get fixedLabelRequired => fixedLabel.modifyRequired(required);

  bool get pinned => modifier.pinned;

  bool get required => modifier.required;

  bool get sortable => modifier.sortable;

  bool get editable => modifier.editable;

  bool get initializable => modifier.initializable;

  bool get expanded => modifier.expanded;

  Future<void> onSaved() async {}
}
