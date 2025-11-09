import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/model/cms_table_page_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_item_management_state.dart';
import 'package:utopia_cms/src/ui/item_management/view/cms_item_management_view.dart';
import 'package:utopia_cms/src/util/json_map.dart';

class CmsItemManagementArgs {
  final JsonMap? initialValue;
  final Future<JsonMap> Function(JsonMap newJson, JsonMap? oldJson) uploadChanges;
  final Future<void> Function()? deleteItem;
  final CmsTableParams params;
  final IList<CmsEntry<dynamic>> entries;

  const CmsItemManagementArgs({
    this.initialValue,
    required this.uploadChanges,
    this.deleteItem,
    required this.params,
    required this.entries,
  });
}

class CmsItemManagement extends HookWidget {
  final CmsItemManagementArgs args;
  final Animation<double> animation;

  const CmsItemManagement({super.key, required this.args, required this.animation});

  @override
  Widget build(BuildContext context) {
    final state = useCmsItemManagementState(
      args: args,
      moveBack: (value) => context.navigator.pop(value),
    );
    return Provider<CmsItemManagementBaseState>.value(
      value: state,
      child: CmsItemManagementView(state: state, animation: animation),
    );
  }
}
