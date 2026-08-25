import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  CmsFilterDateEntry entryOf({
    CmsFilterDateEntryUnit unit = CmsFilterDateEntryUnit.dateTime,
    CmsFilterDateEntryMode mode = CmsFilterDateEntryMode.greater,
    List<String> filterKeys = const ['createdAt'],
    String entryKey = 'from',
  }) => CmsFilterDateEntry(filterKeys: filterKeys, entryKey: entryKey, unit: unit, mode: mode);

  final instant = DateTime.utc(2024, 1, 1, 12, 34, 56);

  group('json', () {
    test('dateTime unit round-trips the instant', () {
      final entry = entryOf();
      expect(entry.fromJson(entry.toJson(instant)), instant);
    });

    test('millisecondsSinceEpoch unit round-trips the instant', () {
      final entry = entryOf(unit: CmsFilterDateEntryUnit.millisecondsSinceEpoch);
      expect(entry.fromJson(entry.toJson(instant))!.isAtSameMomentAs(instant), isTrue);
    });

    test('microsecondsSinceEpoch unit round-trips the instant', () {
      final entry = entryOf(unit: CmsFilterDateEntryUnit.microsecondsSinceEpoch);
      expect(entry.fromJson(entry.toJson(instant))!.isAtSameMomentAs(instant), isTrue);
    });

    test('secondsSinceEpoch unit serializes to an int', () {
      final entry = entryOf(unit: CmsFilterDateEntryUnit.secondsSinceEpoch);
      expect(entry.toJson(instant), isA<int>());
      expect(entry.toJson(instant), instant.millisecondsSinceEpoch ~/ 1000);
    });

    test('secondsSinceEpoch unit round-trips a second-aligned instant', () {
      final entry = entryOf(unit: CmsFilterDateEntryUnit.secondsSinceEpoch);
      expect(entry.fromJson(entry.toJson(instant))!.isAtSameMomentAs(instant), isTrue);
    });

    test('secondsSinceEpoch unit still reads a value stored as a double', () {
      final entry = entryOf(unit: CmsFilterDateEntryUnit.secondsSinceEpoch);
      expect(entry.fromJson(instant.millisecondsSinceEpoch / 1000)!.isAtSameMomentAs(instant), isTrue);
    });

    test('null passes through both directions', () {
      final entry = entryOf();
      expect(entry.toJson(null), isNull);
      expect(entry.fromJson(null), isNull);
    });
  });

  group('filterFromValues', () {
    const serialized = '2024-01-01 12:34:56.000Z';

    test('returns all when the value is absent', () {
      expect(entryOf().filterFromValues({}), const CmsFilterAll());
    });

    test('returns all when there are no filter keys', () {
      expect(entryOf(filterKeys: const []).filterFromValues({'from': serialized}), const CmsFilterAll());
    });

    test('builds greaterOrEq for a single key in greater mode', () {
      expect(
        entryOf().filterFromValues({'from': serialized}),
        const CmsFilterGreaterOrEq('createdAt', serialized),
      );
    });

    test('builds lesserOrEq for a single key in lesser mode', () {
      expect(
        entryOf(mode: CmsFilterDateEntryMode.lesser).filterFromValues({'from': serialized}),
        const CmsFilterLesserOrEq('createdAt', serialized),
      );
    });

    test('ors one filter per filter key', () {
      expect(
        entryOf(filterKeys: const ['createdAt', 'updatedAt']).filterFromValues({'from': serialized}),
        const CmsFilterOr([
          CmsFilterGreaterOrEq('createdAt', serialized),
          CmsFilterGreaterOrEq('updatedAt', serialized),
        ]),
      );
    });

    test('reads a dotted entry key', () {
      expect(
        entryOf(entryKey: 'range.from').filterFromValues({
          'range': {'from': serialized},
        }),
        const CmsFilterGreaterOrEq('createdAt', serialized),
      );
    });
  });
}
