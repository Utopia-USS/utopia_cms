import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/primitives/cms_text_entry.dart';
import 'package:utopia_utils/utopia_utils.dart';

extension EntriesExtensions on IList<CmsEntry<dynamic>> {
  IList<CmsEntry<dynamic>> editable({required bool isCreate, required bool isPageEditable}) =>
      !isPageEditable ? IList() : where((e) => e.editable || isCreate && e.initializable).toIList();

  IList<CmsEntry<dynamic>> get pinned => where((e) => e.pinned).toIList();

  IList<CmsEntry<dynamic>> readOnly({required bool isPageEditable}) =>
      !isPageEditable ? this : where((e) => !e.editable).toIList();

  IList<CmsEntry<dynamic>> get sorted {
    final short = <dynamic>[];
    final long = <dynamic>[];
    for (final item in this) {
      if (item is CmsTextEntry && item.maxLines > 1) {
        long.add(item);
      } else {
        short.add(item);
      }
    }
    return (short + long).cast<CmsEntry<dynamic>>().lock;
  }
}

extension EntryExtensions on CmsEntry<dynamic> {
  bool get isExpanded => this is CmsTextEntry && cast<CmsTextEntry>().maxLines > 1 || expanded;
}
