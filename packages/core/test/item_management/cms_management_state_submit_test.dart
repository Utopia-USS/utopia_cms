import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/src/ui/item_management/cms_management_page.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_management_state.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  late List<bool> moveBacks;
  late List<({JsonMap newJson, JsonMap? oldJson})> uploads;
  late SimpleHookContext<CmsItemManagementState> context;

  CmsTextEntry entry(String key, {bool required = true, bool editable = true, bool initializable = true}) =>
      CmsTextEntry(
        key: key,
        modifier: CmsEntryModifier(required: required, editable: editable, initializable: initializable),
      );

  SimpleHookContext<CmsItemManagementState> build({
    JsonMap? initialValue,
    List<CmsEntry<dynamic>> entries = const [],
    Future<JsonMap> Function()? upload,
  }) {
    return context = SimpleHookContext(
      () => useCmsItemManagementState(
        args: CmsManagementArgs(
          initialValue: initialValue,
          uploadChanges: (newJson, oldJson) {
            uploads.add((newJson: newJson, oldJson: oldJson));
            return upload?.call() ?? Future.value({...newJson, 'id': 'row-1'});
          },
          params: CmsTableParams.defaultParams,
          entries: entries.lock,
          sectionEntries: const [],
        ),
        moveBack: moveBacks.add,
      ),
    );
  }

  setUp(() {
    moveBacks = [];
    uploads = [];
  });

  tearDown(() {
    if (context.mounted) context.dispose();
  });

  group('submit', () {
    test('create uploads the collected values and closes the overlay', () async {
      build(entries: [entry('name')]);

      context.value.onValueChanged('name', 'Ada');
      await context.value.onSubmit();

      expect(uploads.single.newJson, {'name': 'Ada'});
      expect(uploads.single.oldJson, isNull);
      expect(moveBacks, [true]);
    });

    test('a nested edit reaches uploadChanges without touching the row it came from', () async {
      final row = <String, dynamic>{
        'id': '1',
        'contact': {'name': 'old', 'city': 'Berlin'},
      };
      build(initialValue: row, entries: [entry('contact.name')]);

      context.value.onValueChanged('contact.name', 'new');
      await context.value.onSubmit();

      // The new value is visible, the old one is still the pre-edit value, so a
      // delegate diffing the two sees the nested change.
      expect(uploads.single.newJson.getAtPath('contact.name'), 'new');
      expect(uploads.single.oldJson?.getAtPath('contact.name'), 'old');
      expect(uploads.single.newJson.getAtPath('contact.city'), 'Berlin');
    });

    test('a delegate error keeps the overlay open with a message', () async {
      build(upload: () => Future.error(const CmsDelegateException('name already taken')));

      await context.value.onSubmit();

      expect(context.value.errorMessage, 'name already taken');
      expect(moveBacks, isEmpty);
    });

    test('a second submit while the first is in flight is skipped', () async {
      final completer = Completer<JsonMap>();
      build(upload: () => completer.future);

      unawaited(context.value.onSubmit());
      expect(context.value.isUploading, true);

      // Bounded: an unskipped second submit would await the same pending upload,
      // and the bare wait would fail as a whole-test timeout instead of here.
      await context.value.onSubmit().timeout(const Duration(seconds: 1));
      expect(uploads.length, 1);

      completer.complete({'id': 'row-1'});
      await context.waitUntil((it) => !it.isUploading);
      expect(moveBacks, [true]);
    });

    test('post-save callbacks receive the row uploadChanges returned', () async {
      build(upload: () async => {'id': 'row-9', 'name': 'Ada'});
      final saved = <JsonMap>[];
      context.value.addOnSavedCallback((row) async => saved.add(row));

      await context.value.onSubmit();

      expect(saved.single, {'id': 'row-9', 'name': 'Ada'});
    });

    test('a post-save callback failing with a delegate error does not reopen the form', () async {
      build();
      context.value.addOnSavedCallback((_) async => throw const CmsDelegateException('linking media failed'));

      await expectLater(context.value.onSubmit(), throwsA(isA<CmsDelegateException>()));

      // The only case the committed flag guards: the same exception type that
      // becomes an inline message before the write must not become one after it,
      // or the user retries a write that already succeeded.
      expect(context.value.errorMessage, isNull);
      expect(moveBacks, [true]);
    });
  });

  test('isButtonAvailable before and after one change', () {
    /// (available before, available after, change recorded)
    (bool, bool, bool) availability(
      List<CmsEntry<dynamic>> entries,
      String key,
      Object? value, {
      JsonMap? initialValue,
    }) {
      build(initialValue: initialValue, entries: entries);
      final before = context.value.isButtonAvailable;
      context.value.onValueChanged(key, value);
      final after = context.value.isButtonAvailable;
      final changed = context.value.hasChanges;
      context.dispose();
      return (before, after, changed);
    }

    // create: a required entry blocks until it is filled, an optional one never does
    expect(availability([entry('name'), entry('nickname', required: false)], 'name', 'Ada'), (false, true, true));
    // create: a required entry that is initializable but not editable is rendered, so it blocks
    expect(availability([entry('email', editable: false)], 'email', 'ada@example.com'), (false, true, true));
    // create: a required entry that create does not render never blocks
    expect(availability([entry('slug', initializable: false)], 'slug', null), (true, true, true));
    // edit: filled values still wait for a change
    expect(availability([entry('name')], 'name', 'Grace', initialValue: {'name': 'Ada'}), (false, true, true));
    // edit: emptying a required editable entry blocks, although the change is recorded
    expect(availability([entry('name')], 'name', null, initialValue: {'name': 'Ada'}), (false, false, true));
  });
}
