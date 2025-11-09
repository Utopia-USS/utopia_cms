import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_item_management_state.dart';
import 'package:utopia_cms/src/ui/widget/button/cms_button.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_header.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_title.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/entries_extensions.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsItemManagementView extends HookWidget {
  final CmsItemManagementState state;
  final Animation<double> animation;

  const CmsItemManagementView({super.key, required this.state, required this.animation});

  static const _itemWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = useMemoized(() => CurvedAnimation(parent: animation, curve: Curves.easeOut));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final canNest = constraints.maxWidth > _itemWidth * 1.6;
            const maxWidth = _itemWidth * 2.2;
            final fixedWidth = min(maxWidth, constraints.maxWidth);
            return Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: (1 - curvedAnimation.value) * (-fixedWidth),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            color: context.colors.canvas,
                            width: fixedWidth,
                            height: constraints.maxHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildScrollView(canNest),
                                _buildButtons(context),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScrollView(bool canNest) {
    return HookBuilder(builder: (context) {
      final readOnlyShort = useMemoized(
          () => state.entries.readOnly(isPageEditable: state.params.canEdit).where((e) => !e.isExpanded).toIList());
      final readOnlyExpanded = useMemoized(
          () => state.entries.readOnly(isPageEditable: state.params.canEdit).where((e) => e.isExpanded).toIList());
      final editableShort = useMemoized(() => state.entries
          .editable(isCreate: !state.isEdit, isPageEditable: state.params.canEdit)
          .where((e) => !e.isExpanded)).toIList();
      final editableExpanded = useMemoized(() => state.entries
          .editable(isCreate: !state.isEdit, isPageEditable: state.params.canEdit)
          .where((e) => e.isExpanded)
          .toIList());
      return CustomScrollView(
        controller: state.scrollController,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CmsHeader(
                text: _buildHeader(),
                navigateBack: true,
              ),
            ),
          ),
          if (state.isEdit && (readOnlyExpanded.isNotEmpty || readOnlyShort.isNotEmpty)) ...[
            _buildTitle("Read only", context),
            _buildNestedSection(readOnlyShort, readOnly: true, canNest: canNest),
            _buildSingularSection(readOnlyExpanded, readOnly: true),
          ],
          if (state.isEdit && (editableShort.isNotEmpty || editableExpanded.isNotEmpty)) ...[
            _buildTitle("Editable", context),
            _buildNestedSection(editableShort, canNest: canNest),
            _buildSingularSection(editableExpanded),
          ],
          if (!state.isEdit) ...[
            _buildNestedSection(editableShort, canNest: canNest),
            _buildSingularSection(editableExpanded),
          ]
        ],
      );
    });
  }

  String _buildHeader() {
    if (!state.isEdit) return "Create new";
    if (state.canCreate) return "Manage item";
    return "Item details";
  }

  SliverList _buildNestedSection(IList<CmsEntry<dynamic>> entries, {bool readOnly = false, bool canNest = true}) {
    final length = (entries.length / 2).floor();
    final fixedNestedCount = entries.length.isEven ? length : length + 1;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final fixedIndex = canNest ? index * 2 : index;
          final shouldBuildSecond = fixedIndex + 1 < entries.length && canNest;
          return _buildTile(
            context,
            readOnly: readOnly,
            firstItem: _buildEditField(context, entries[fixedIndex]),
            secondItem: !shouldBuildSecond
                ? _buildSecondItemPlaceholder(canNest)
                : _buildEditField(context, entries[fixedIndex + 1]),
          );
        },
        childCount: canNest ? fixedNestedCount : entries.length,
      ),
    );
  }

  Widget? _buildSecondItemPlaceholder(bool canNest) {
    if (canNest) {
      return const SizedBox();
    }
    return null;
  }

  SliverList _buildSingularSection(IList<CmsEntry<dynamic>> entries, {bool readOnly = false}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildTile(
            context,
            readOnly: readOnly,
            firstItem: _buildEditField(context, entries[index]),
          );
        },
        childCount: entries.length,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    //todo revisit text
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
        child: Row(
          children: [
            const Spacer(),
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
                child: const Text("Continue"),
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

  Widget _buildTile(BuildContext context, {required Widget firstItem, Widget? secondItem, required bool readOnly}) {
    final spacing = context.theme.fieldContentPadding.left;
    return IgnorePointer(
      ignoring: readOnly,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Flexible(child: firstItem),
            if (secondItem != null) ...[
              SizedBox(width: spacing),
              Flexible(child: secondItem),
            ]
          ],
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
