import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_search_filter_entry.dart';
import 'package:utopia_cms/src/ui/widget/button/cms_button.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_breakpoints.dart';
import 'package:utopia_cms/src/ui/widget/text_field/cms_search_field.dart';
import 'package:utopia_cms/src/util/foundation.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

/// The main panel at the top of the table card: a prominent search bar, a
/// refresh control, the "+" create button, and any remaining (non-search)
/// filter fields laid out beneath.
class CmsTableSearchPanel extends StatelessWidget {
  final CmsFilterSearchEntry? searchEntry;
  final String searchHint;
  final String? searchValue;
  final IList<CmsFilterEntry<dynamic>> otherFilters;
  final JsonMap filterValues;
  final void Function(String entryKey, Object? value) onFilterChanged;
  final bool canCreate;
  final void Function() onCreatePressed;
  final bool isReloading;
  final void Function() onReloadPressed;

  const CmsTableSearchPanel({
    super.key,
    required this.searchEntry,
    required this.searchHint,
    required this.searchValue,
    required this.otherFilters,
    required this.filterValues,
    required this.onFilterChanged,
    required this.canCreate,
    required this.onCreatePressed,
    required this.isReloading,
    required this.onReloadPressed,
  });

  /// Shared height for every control in the panel (search, filter fields and the
  /// refresh / create buttons) so the toolbar row lines up.
  static const double _controlHeight = 48;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Web (wide content) lays search, filters and buttons out in a single
        // row; tablet / mobile stacks the filters under the search + buttons row.
        final inline = constraints.maxWidth >= CmsBreakpoints.webMin;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: inline ? _buildInlineRow(context) : _buildStacked(context),
        );
      },
    );
  }

  Widget _buildInlineRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSearch(context)),
        for (final entry in otherFilters) ...[const SizedBox(width: 12), _buildFilterField(context, entry)],
        const SizedBox(width: 12),
        _buildReload(context),
        if (canCreate) ...[const SizedBox(width: 12), _buildCreate(context)],
      ],
    );
  }

  Widget _buildStacked(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildSearch(context)),
            const SizedBox(width: 12),
            _buildReload(context),
            if (canCreate) ...[const SizedBox(width: 12), _buildCreate(context)],
          ],
        ),
        if (otherFilters.isNotEmpty) ...[const SizedBox(height: 12), _buildFilters(context)],
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    final entry = searchEntry;
    final field = entry == null
        ? const SizedBox.shrink()
        : CmsSearchField(
            value: searchValue ?? '',
            hint: searchHint,
            formatters: entry.formatters,
            onChanged: (value) => onFilterChanged(entry.entryKey, value),
          );
    return SizedBox(height: _controlHeight, child: field);
  }

  /// The refresh control - the same [CmsButton] as the "+" create button (same
  /// primary fill, square and radius) so the pair shares one colour. Reuses the
  /// button's built-in loading state for the in-progress spinner.
  Widget _buildReload(BuildContext context) {
    return Tooltip(
      message: 'Refresh',
      child: CmsButton(
        dense: true,
        height: _controlHeight,
        maxWidth: _controlHeight,
        loading: isReloading,
        isEnabled: !isReloading,
        onTap: onReloadPressed,
        child: const Icon(Icons.refresh, size: 24),
      ),
    );
  }

  Widget _buildCreate(BuildContext context) {
    return CmsButton(
      dense: true,
      height: _controlHeight,
      maxWidth: _controlHeight,
      onTap: onCreatePressed,
      child: const Icon(Icons.add, size: 24),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [for (final entry in otherFilters) _buildFilterField(context, entry)],
    );
  }

  Widget _buildFilterField(BuildContext context, CmsFilterEntry<dynamic> entry) {
    return SizedBox(
      width: (100.0 * entry.flex).clamp(160.0, 320.0),
      height: _controlHeight,
      child: entry.buildField(
        context: context,
        // Values are written with `setAtPath`, so a dotted `entryKey` only reads
        // back through `getAtPath`.
        value: entry.fromJson(filterValues.getAtPath(entry.entryKey)),
        onChanged: (value) => onFilterChanged(entry.entryKey, entry.toJson(value)),
      ),
    );
  }
}
