import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/primitives/cms_text_entry.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_page_wrapper.dart';
import 'package:utopia_cms/src/util/foundation.dart';

extension EntriesExtensions on IList<CmsEntry<dynamic>> {
  IList<CmsEntry<dynamic>> editable({required bool isCreate, required bool isPageEditable}) =>
      !isPageEditable ? IList() : where((e) => e.isWritable(isCreate: isCreate)).toIList();

  IList<CmsEntry<dynamic>> pinnedFor(CmsPageType pageType) => where((e) => e.modifier.pinned(pageType)).toIList();

  IList<CmsEntry<dynamic>> readOnly({required bool isPageEditable}) =>
      !isPageEditable ? this : where((e) => !e.editable).toIList();
}

extension EntryExtensions on CmsEntry<dynamic> {
  bool get isExpanded => this is CmsTextEntry && cast<CmsTextEntry>().maxLines > 1 || expanded;
}
