import 'package:dropdown_search/dropdown_search.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/delegate/cms_to_many_delegate.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/ui/widget/button/cms_button.dart';
import 'package:utopia_cms/src/ui/widget/dropdown/to_many/cms_to_many_dropdown_state.dart';
import 'package:utopia_cms/src/ui/widget/loading/cms_loader.dart';
import 'package:utopia_cms/src/ui/widget/wrapper/cms_field_wrapper.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsToManyDropdownField extends HookWidget {
  final CmsToManyDelegate delegate;
  final Object? originId;
  final String label;
  final String Function(JsonMap) valueLabelBuilder;
  final List<String>? filterFields;
  final CmsFilter Function(String)? filterBuilder;

  const CmsToManyDropdownField({
    super.key,
    required this.label,
    required this.valueLabelBuilder,
    required this.delegate,
    required this.originId,
    this.filterFields,
    this.filterBuilder,
  }) : assert(filterFields != null || filterBuilder != null);

  @override
  Widget build(BuildContext context) {
    final state = useCmsToManyDropdownState(delegate: delegate, originId: originId);

    return CmsFieldWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDropDown(context, state),
        ],
      ),
    );
  }

  Widget _buildDropDown(BuildContext context, CmsToManyDropdownState state) {
    final style = context.textStyles.text;
    final labelStyle = context.textStyles.label;
    return DropdownSearch<JsonMap>.multiSelection(
      asyncItems: (filter) async {
        return state.getItems(
          filter: filterBuilder?.call(filter) ?? _buildFilter(filter),
        );
      },
      dropdownButtonProps: DropdownButtonProps(color: context.colors.accent),
      itemAsString: valueLabelBuilder,
      clearButtonProps: _buildClearButtonsProps(context),
      onChanged: (value) => state.onChanged(value.toISet()),
      selectedItems: state.selectedValues.toList(),
      compareFn: (a, b) => a[delegate.foreignIdKey] == b[delegate.foreignIdKey],
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          isDense: true,
        ),
      ),
      dropdownBuilder: (__, values) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.textStyles.caption),
            Text(values.reversed.map(valueLabelBuilder).join(', '), overflow: TextOverflow.ellipsis, style: labelStyle),
          ],
        );
      },
      popupProps: PopupPropsMultiSelection.menu(
        searchDelay: const Duration(milliseconds: 200),
        showSelectedItems: true,
        showSearchBox: true,
        scrollbarProps: const ScrollbarProps(thumbColor: Colors.transparent, trackColor: Colors.transparent),
        loadingBuilder: (_, __) => const CmsLoader(),
        itemBuilder: (context, value, isSelected) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
          child: Text(valueLabelBuilder(value), style: style),
        ),
        validationWidgetBuilder: (context, value) => _buildValidator(context, value, state),
        selectionWidget: (context, value, isSelected) => _buildCheckBox(isSelected, context),
        searchFieldProps: _buildSearchProps(context),
      ),
    );
  }

  Widget _buildValidator(BuildContext context, List<Map<String, dynamic>> value, CmsToManyDropdownState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: SizedBox(
        height: 40,
        child: CmsButton(
          onTap: () {
            Navigator.pop(context);
            state.onChanged(value.toISet());
          },
          dense: true,
          child: const Text("Ok"),
        ),
      ),
    );
  }

  ClearButtonProps _buildClearButtonsProps(BuildContext context) {
    return const ClearButtonProps(color: Colors.red);
  }

  TextFieldProps _buildSearchProps(BuildContext context) {
    final decoration = context.fieldDecoration;
    final values = context.theme;
    final textStyles = context.textStyles;
    return TextFieldProps(
      style: textStyles.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: decoration.color,
        label: const Text("Search"),
        floatingLabelStyle: textStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        labelStyle: textStyles.label,
        contentPadding: values.fieldContentPadding,
        border: OutlineInputBorder(
          borderRadius: values.borderRadius,
          borderSide: BorderSide(color: decoration.color!, width: 8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: values.borderRadius,
          borderSide: BorderSide(color: decoration.color!, width: 8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: values.borderRadius,
          borderSide: BorderSide(color: decoration.color!, width: 8),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: values.borderRadius,
          borderSide: BorderSide(color: decoration.color!, width: 8),
        ),
      ),
    );
  }

  Widget _buildCheckBox(bool isEnabled, BuildContext context) {
    final main = context.colors.accent;
    final border = context.textStyles.text.color;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Checkbox(
        value: isEnabled,
        activeColor: main,
        side: BorderSide(color: border!, width: 1.5),
        onChanged: (value) {},
      ),
    );
  }

  CmsFilter _buildFilter(String filter) =>
      CmsFilter.or([for (final field in filterFields!) CmsFilter.containsString(field, filter, caseSensitive: false)]);
}
