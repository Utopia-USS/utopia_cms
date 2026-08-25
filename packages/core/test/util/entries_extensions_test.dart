import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/src/util/entries_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  CmsTextEntry entry(String key, {bool editable = true, bool initializable = true}) =>
      CmsTextEntry(key: key, modifier: CmsEntryModifier(editable: editable, initializable: initializable));

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

  group('readOnly', () {
    test('returns all entries when the page is not editable', () {
      final entries = [entry('a'), entry('b', editable: false)].lock;
      expect(entries.readOnly(isPageEditable: false), entries);
    });

    test('returns only non-editable entries when the page is editable', () {
      final readOnly = entry('b', editable: false);
      final entries = [entry('a'), readOnly].lock;
      expect(entries.readOnly(isPageEditable: true).toList(), [readOnly]);
    });
  });

  test('pinnedFor filters by the page type predicate', () {
    final desktopOnly = CmsTextEntry(key: 'a', modifier: CmsEntryModifier(pinned: (t) => !t.isMobile));
    final entries = [desktopOnly].lock;
    expect(entries.pinnedFor(CmsPageType.web).toList(), [desktopOnly]);
    expect(entries.pinnedFor(CmsPageType.mobile), isEmpty);
  });

  test('sorted moves multi-line text entries to the end and is otherwise stable', () {
    final multiline = CmsTextEntry(key: 'description', maxLines: 3);
    final first = entry('a');
    final second = entry('b');
    expect([multiline, first, second].lock.sorted.toList(), [first, second, multiline]);
  });

  group('isExpanded', () {
    test('is true for a multi-line text entry', () {
      expect(CmsTextEntry(key: 'a', maxLines: 3).isExpanded, isTrue);
    });

    test('is true for an entry with an expanded modifier', () {
      expect(CmsDateEntry(key: 'a', modifier: const CmsEntryModifier(expanded: true)).isExpanded, isTrue);
    });

    test('is false for a single-line text entry', () {
      expect(entry('a').isExpanded, isFalse);
    });
  });
}
