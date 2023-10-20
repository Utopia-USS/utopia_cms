import 'package:flutter/material.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/delegate/cms_delegate.dart';
import 'package:utopia_cms/src/model/cms_table_page_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/model/table_action/cms_table_action.dart';
import 'package:utopia_cms/src/ui/widget/dialog/cms_dialog.dart';
import 'package:utopia_cms/src/ui/table_page/state/cms_table_page_state.dart';
import 'package:utopia_cms/src/ui/table_page/view/cms_table_page_view.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

///  * [CmsTablePage] by default is able to generate complete flow of data table preview, creation/edition flow.

class CmsTablePage extends HookWidget {
  final CmsDelegate delegate;
  final CmsTableParams params;
  final String title;
  final List<CmsEntry<dynamic>> entries;
  final List<CmsFilterEntry<dynamic>>? filterEntries;
  final List<CmsTableAction>? customActions;
  final int? pagingLimit;

  const CmsTablePage({
    super.key,
    required this.delegate,
    required this.title,
    this.params = CmsTableParams.defaultParams,
    required this.entries,
    this.customActions,
    this.filterEntries,
    this.pagingLimit = 25,
  }) : assert(pagingLimit != 0);

  @override
  Widget build(BuildContext context) {
    final navigator = context.navigator;
    final state = useCmsTablePageState(
      delegate: delegate,
      params: params,
      navigator: navigator,
      entries: entries.lock,
      filterEntries: (filterEntries ?? []).lock,
      confirmDelete: () async => CmsDialog.show(context),
      pagingLimit: pagingLimit,
    );
    return CmsTablePageView(
      state: state,
      entries: entries.lock,
      filterEntries: (filterEntries ?? []).lock,
      title: title,
      customActions: (customActions ?? []).lock,
    );
  }
}
