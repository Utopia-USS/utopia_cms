import 'package:flutter/material.dart';
import 'package:utopia_cms/src/delegate/cms_delegate.dart';
import 'package:utopia_cms/src/delegate/cms_to_many_delegate.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/common/dropdown/to_many/cms_to_many_dropdown_field.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_preview_text.dart';
import 'package:utopia_cms/src/ui/item_management/view/cms_item_management_view.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

/// [CmsEntry] for handling toMany relationships
class CmsToManyDropdownEntry extends CmsEntry<Object> {
  /// server-layer for handling relationships operations
  final CmsToManyDelegate delegate;

  /// Builder for display of loaded values in the [buildPreview] / [CmsTable]
  ///
  /// Refers to generic values loaded by [CmsDelegate]
  final String Function(JsonMap)? previewDisplayBuilder;

  /// Builder for display of values in the [buildEditField] / [CmsItemManagementView]
  ///
  /// Refers to values loaded by [CmsToManyDelegate]
  final String Function(JsonMap) fieldDisplayBuilder;

  final List<String> filterFields;

  CmsToManyDropdownEntry({
    required this.delegate,
    required this.filterFields,
    required this.fieldDisplayBuilder,
    this.previewDisplayBuilder,
    required this.label,
    this.modifier = const CmsEntryModifier(pinned: false),
    this.flex = 4,
  });

  @override
  final int flex;

  // Used to get originId from the containing [CmsTable].
  @override
  String get key => delegate.originIdKey;

  @override
  final String label;

  @override
  final CmsEntryModifier modifier;

  @override
  Widget buildPreview(BuildContext context, Object value) {
    // TODO revisit
    return HookBuilder(builder: (context) {
      final values = useMemoizedFuture(() async => delegate.get(originId: value), initialData: null);

      return CmsTablePreviewText(values.data?.map(previewDisplayBuilder ?? fieldDisplayBuilder).join(', ') ?? '-');
    });
  }

  @override
  Widget buildEditField({
    required BuildContext context,
    required Object? value,
    required void Function(JsonMap value) onChanged,
  }) {
    return CmsToManyDropdownField(
      label: fixedLabel,
      valueLabelBuilder: fieldDisplayBuilder,
      delegate: delegate,
      filterFields: filterFields,
      originId: value,
    );
  }
}
