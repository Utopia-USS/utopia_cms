import 'dart:math';

import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/item_management/cms_management_section_entry.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_management_state.dart';
import 'package:utopia_cms/src/ui/widget/button/cms_button.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_header.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_title.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_page_wrapper.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/entries_extensions.dart';
import 'package:utopia_cms/src/util/foundation.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

class CmsManagementView extends HookWidget {
  final CmsItemManagementState state;
  final List<CmsManagementSectionEntry> sectionEntries;
  final Animation<double> animation;

  const CmsManagementView({super.key, required this.state, required this.animation, required this.sectionEntries});

  static const _itemWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = useMemoized(() => CurvedAnimation(parent: animation, curve: Curves.easeOut));
    // CmsPageWrapper resolves the size class from the overlay's own width (the
    // route fills the viewport), so a narrow viewport => mobile => full screen.
    return CmsPageWrapper(
      builder: (context, pageType) => AnimatedBuilder(
        animation: animation,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) => Material(
            type: MaterialType.transparency,
            child: pageType.isMobile
                ? _buildMobileScreen(context, constraints, curvedAnimation)
                : _buildSidePanel(context, constraints, curvedAnimation),
          ),
        ),
      ),
    );
  }

  /// Tablet / web: the overlay slides in from the right as a constrained panel,
  /// leaving the table partially visible behind the route barrier.
  Widget _buildSidePanel(BuildContext context, BoxConstraints constraints, Animation<double> animation) {
    final canNest = constraints.maxWidth > _itemWidth * 1.6;
    const maxWidth = _itemWidth * 2.2;
    final fixedWidth = min(maxWidth, constraints.maxWidth);
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          right: (1 - animation.value) * (-fixedWidth),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              color: context.colors.canvas,
              width: fixedWidth,
              height: constraints.maxHeight,
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Stack(fit: StackFit.expand, children: [_buildScrollView(canNest), _buildButtons(context)]),
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile: the overlay becomes a full-screen page that slides up from the
  /// bottom. Single column,
  /// tighter padding, dismissed via the header back action / system back.
  Widget _buildMobileScreen(BuildContext context, BoxConstraints constraints, Animation<double> animation) {
    return FractionalTranslation(
      translation: Offset(0, 1 - animation.value),
      child: Container(
        color: context.colors.canvas,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(fit: StackFit.expand, children: [_buildScrollView(false), _buildButtons(context)]),
      ),
    );
  }

  Widget _buildScrollView(bool canNest) {
    return HookBuilder(
      builder: (context) {
        final readOnlyShort = useMemoized(
          () => state.entries.readOnly(isPageEditable: state.params.canEdit).where((e) => !e.isExpanded).toIList(),
        );
        final readOnlyExpanded = useMemoized(
          () => state.entries.readOnly(isPageEditable: state.params.canEdit).where((e) => e.isExpanded).toIList(),
        );
        // Each flow is gated by its own permission: the create overlay is only
        // reachable behind `canCreate`, so reading `canEdit` for it rendered no
        // fields at all under `canCreate: true, canEdit: false` - the Create
        // button was shown while its required entries could never be filled.
        final isPageEditable = state.isEdit ? state.params.canEdit : state.params.canCreate;
        final editableShort = useMemoized(
          () => state.entries
              .editable(isCreate: !state.isEdit, isPageEditable: isPageEditable)
              .where((e) => !e.isExpanded),
        ).toIList();
        final editableExpanded = useMemoized(
          () => state.entries
              .editable(isCreate: !state.isEdit, isPageEditable: isPageEditable)
              .where((e) => e.isExpanded)
              .toIList(),
        );

        return CustomScrollView(
          controller: state.scrollController,
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CmsHeader(text: _buildHeader(), navigateBack: true),
              ),
            ),
            if (state.isEdit && (readOnlyExpanded.isNotEmpty || readOnlyShort.isNotEmpty)) ...[
              _buildTitle("Read only", context),
              _buildNestedSection(context, readOnlyShort, readOnly: true, canNest: canNest),
              _buildSingularSection(readOnlyExpanded, readOnly: true),
            ],
            if (state.isEdit && (editableShort.isNotEmpty || editableExpanded.isNotEmpty)) ...[
              _buildTitle("Editable", context),
              _buildNestedSection(context, editableShort, canNest: canNest),
              _buildSingularSection(editableExpanded),
            ],
            if (!state.isEdit) ...[
              _buildNestedSection(context, editableShort, canNest: canNest),
              _buildSingularSection(editableExpanded),
            ],
            for (final entry in sectionEntries) ..._buildCustomSection(context, entry),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  List<Widget> _buildCustomSection(BuildContext context, CmsManagementSectionEntry entry) {
    final edit = state.isEdit;
    if ((entry.showEdit && edit) || (entry.showCreate && !edit)) {
      return [_buildTitle(entry.title, context), entry.sliverBuilder(state.values, state.isEdit)];
    }

    return [];
  }

  String _buildHeader() {
    if (!state.isEdit) return "Create new";
    if (state.canCreate) return "Manage item";
    return "Item details";
  }

  /// The short (non-expanded) fields, laid out as two independent columns that
  /// flow vertically on their own. Distributing by parity keeps every field in
  /// the same column a row-paired grid would put it in, but decouples the two
  /// columns' vertical rhythm: a tall field (e.g. a multi-input link entry) on
  /// one side no longer pushes the opposite side's next field down, so the
  /// inter-field spacing stays even on both columns. On mobile (`!canNest`) the
  /// fields collapse into a single column.
  Widget _buildNestedSection(
    BuildContext context,
    IList<CmsEntry<dynamic>> entries, {
    bool readOnly = false,
    bool canNest = true,
  }) {
    if (entries.isEmpty) return const SliverToBoxAdapter();
    if (!canNest) {
      return SliverToBoxAdapter(child: _buildColumn(context, entries.toList(), readOnly: readOnly));
    }
    final left = <CmsEntry<dynamic>>[];
    final right = <CmsEntry<dynamic>>[];
    for (var i = 0; i < entries.length; i++) {
      (i.isEven ? left : right).add(entries[i]);
    }
    final spacing = context.theme.fieldContentPadding.left;
    return SliverToBoxAdapter(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildColumn(context, left, readOnly: readOnly)),
          SizedBox(width: spacing),
          Expanded(child: _buildColumn(context, right, readOnly: readOnly)),
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, List<CmsEntry<dynamic>> entries, {required bool readOnly}) {
    return IgnorePointer(
      ignoring: readOnly,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: _buildEditField(context, entry)),
        ],
      ),
    );
  }

  SliverList _buildSingularSection(IList<CmsEntry<dynamic>> entries, {bool readOnly = false}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return _buildTile(readOnly: readOnly, firstItem: _buildEditField(context, entries[index]));
      }, childCount: entries.length),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 36),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [context.colors.canvas, context.colors.canvas.withValues(alpha: 0)],
          ),
        ),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.canDelete)
                  CmsButton(
                    maxWidth: context.theme.shortButtonWidth,
                    colors: [context.colors.error, context.colors.error.withValues(alpha: 0.95)],
                    onTap: state.onDelete,
                    loading: state.isDeleting,
                    dense: true,
                    child: const Text("Delete"),
                  ),
                const SizedBox(width: 12),
                if (state.canCreate || !state.isEdit)
                  CmsButton(
                    maxWidth: context.theme.shortButtonWidth,
                    onTap: state.onSubmit,
                    loading: state.isUploading,
                    dense: true,
                    isEnabled: state.isButtonAvailable,
                    child: Text(state.isEdit ? "Update" : "Create"),
                  ),
              ],
            ),
            if (state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: context.textStyles.label.copyWith(color: context.colors.error),
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTitle(String title, BuildContext context) {
    if (!state.canCreate) return const SliverToBoxAdapter();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: CmsTitle(title: title),
      ),
    );
  }

  Widget _buildTile({required Widget firstItem, required bool readOnly}) {
    return IgnorePointer(
      ignoring: readOnly,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Flexible(child: firstItem)],
        ),
      ),
    );
  }

  Widget _buildEditField(BuildContext context, CmsEntry entry) {
    return entry.buildEditField(
      context: context,
      value: entry.fromJson(state.values.getAtPath(entry.key)),
      onChanged: (value) => state.onValueChanged(entry.key, entry.toJson(value)),
    );
  }
}
