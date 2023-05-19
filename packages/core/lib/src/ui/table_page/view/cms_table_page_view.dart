import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/table_action/cms_table_action.dart';
import 'package:utopia_cms/src/ui/common/button/cms_button.dart';
import 'package:utopia_cms/src/ui/common/header/cms_header.dart';
import 'package:utopia_cms/src/ui/common/loading/cms_loader.dart';
import 'package:utopia_cms/src/ui/common/loading/cms_mock_loading_box.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table.dart';
import 'package:utopia_cms/src/ui/table_page/state/cms_table_page_state.dart';
import 'package:utopia_cms/src/ui/table_page/widget/cms_table_actions.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_widgets/misc/multi_widget.dart';

class CmsTablePageView extends HookWidget {
  final CmsTablePageState state;
  final IList<CmsEntry<dynamic>> entries;
  final IList<CmsTableAction> customActions;
  final String title;

  const CmsTablePageView({
    super.key,
    required this.state,
    required this.entries,
    required this.title,
    required this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    return MultiWidget(
      [
        (child) => Scaffold(backgroundColor: context.colors.canvas, body: child),
        (child) => SizedBox.expand(child: child),
        (child) => _buildNotificationListener(child: child),
        (_) => _buildContent(context),
      ],
    );
  }

  Widget _buildNotificationListener({required Widget child}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.extentAfter < 50 && state.pagingEnabled && state.items.isNotEmpty) {
          unawaited(state.computedState.refresh());
        }
        return false;
      },
      child: child,
    );
  }

  Widget _buildContent(BuildContext context) {
    final values = state.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.theme.pageTopPadding),
        _buildTopRow(context),
        Expanded(
          child: values.isEmpty && state.computedState.value is ComputedStateValueInProgress
              ? _buildLoader(context)
              : _buildTable(context),
        ),
        if (values.isNotEmpty && state.computedState.value is ComputedStateValueInProgress)
          const Center(
            child: CmsLoader(),
          ),
      ],
    );
  }

  Widget _buildTopRow(BuildContext context) {
    //todo revisit text
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Row(
        children: [
          CmsHeader(text: title),
          const Spacer(),
          if (state.params.canCreate)
            CmsButton(
              maxWidth: context.theme.shortButtonWidth,
              onTap: state.onCreatePressed,
              dense: true,
              child: const Text("Create"),
            ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return CmsTable(
      onManagePressed: state.params.canEdit ? state.onEditPressed : null,
      scrollController: state.scrollController,
      values: state.items,
      entries: entries,
      onSortPressed: state.onSortPressed,
      currentSortParams: state.currentSortingParams,
      actionsBuilder: !state.hasDefaultActions && customActions.isNotEmpty
          ? null
          : (e, index) {
              ///workaround: force actions to the end of the [DataTable]
              return CmsTableActionsButton(
                value: e,
                onUpdate: (value) => state.updateItem(value, index),
                actions: [
                  if (state.params.canEdit) _buildManageAction(index),
                  if (customActions.isNotEmpty) ...customActions,
                  if (state.params.canDelete) _buildDeleteAction(index),
                ],
              );
            },
    );
  }

  CmsTableAction _buildDeleteAction(int index) {
    return CmsTableAction(
      label: "Delete",
      shouldUpdateTable: false,
      onPressed: (value) async {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            await state.onDeletePressed(value, index);
          },
        );
        return null;
      },
    );
  }

  CmsTableAction _buildManageAction(int index) {
    return CmsTableAction(
      label: "Manage",
      shouldUpdateTable: false,
      onPressed: (value) async {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            state.onEditPressed(value, index);
          },
        );
        return null;
      },
    );
  }

  Widget _buildLoader(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i = 0; i < 20; i++)
          const Padding(
            padding: EdgeInsets.only(
              top: CmsTable.tileHeight,
            ),
            child: CmsMockLoadingBox(
              width: double.infinity,
              height: CmsTable.tileHeight,
            ),
          )
      ],
    );
  }
}
