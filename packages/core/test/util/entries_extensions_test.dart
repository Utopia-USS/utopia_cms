import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/src/util/entries_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  CmsTextEntry entry(String key, {bool editable = true, bool initializable = true}) => CmsTextEntry(
    key: key,
    modifier: CmsEntryModifier(editable: editable, initializable: initializable),
  );

  group('editable', () {
    test('returns nothing when the page is not editable', () {
      final entries = [entry('a')].lock;
      expect(entries.editable(isCreate: false, isPageEditable: false), isEmpty);
      expect(entries.editable(isCreate: true, isPageEditable: false), isEmpty);
    });

    test('returns only editable entries in the edit flow', () {
      final editable = entry('a');
      final entries = [editable, entry('b', editable: false)].lock;
      expect(entries.editable(isCreate: false, isPageEditable: true).toList(), [editable]);
    });

    test('excludes a non-initializable entry in the create flow', () {
      final initializable = entry('a');
      final entries = [initializable, entry('b', initializable: false)].lock;
      expect(entries.editable(isCreate: true, isPageEditable: true).toList(), [initializable]);
    });

    test('includes an initializable non-editable entry in the create flow', () {
      final createOnly = entry('a', editable: false);
      expect([createOnly].lock.editable(isCreate: true, isPageEditable: true).toList(), [createOnly]);
    });
  });

  test('readOnly, pinnedFor and isExpanded follow the entry settings', () {
    final writable = entry('a');
    final readOnly = entry('b', editable: false);
    final entries = [writable, readOnly].lock;
    expect(entries.readOnly(isPageEditable: false), entries);
    expect(entries.readOnly(isPageEditable: true).toList(), [readOnly]);

    final desktopOnly = CmsTextEntry(
      key: 'a',
      modifier: CmsEntryModifier(pinned: (t) => !t.isMobile),
    );
    expect([desktopOnly].lock.pinnedFor(CmsPageType.web).toList(), [desktopOnly]);
    expect([desktopOnly].lock.pinnedFor(CmsPageType.mobile), isEmpty);

    expect(CmsTextEntry(key: 'a', maxLines: 3).isExpanded, isTrue);
    expect(CmsDateEntry(key: 'a', modifier: const CmsEntryModifier(expanded: true)).isExpanded, isTrue);
    expect(writable.isExpanded, isFalse);
  });
}
