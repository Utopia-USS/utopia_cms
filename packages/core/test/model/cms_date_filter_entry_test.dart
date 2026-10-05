import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  CmsFilterDateEntry entryOf({
    CmsFilterDateEntryUnit unit = CmsFilterDateEntryUnit.dateTime,
    CmsFilterDateEntryMode mode = CmsFilterDateEntryMode.greater,
    List<String> filterKeys = const ['createdAt'],
    String entryKey = 'from',
  }) => CmsFilterDateEntry(filterKeys: filterKeys, entryKey: entryKey, unit: unit, mode: mode);

  test('json sends a literal wire value per unit and reads it back', () {
    final instant = DateTime.utc(2024, 1, 1, 12, 34, 56);
    const wire = <CmsFilterDateEntryUnit, Object>{
      CmsFilterDateEntryUnit.dateTime: '2024-01-01 12:34:56.000Z',
      CmsFilterDateEntryUnit.secondsSinceEpoch: 1704112496,
      CmsFilterDateEntryUnit.millisecondsSinceEpoch: 1704112496000,
      CmsFilterDateEntryUnit.microsecondsSinceEpoch: 1704112496000000,
    };

    for (final unit in CmsFilterDateEntryUnit.values) {
      final entry = entryOf(unit: unit);
      final literal = wire[unit]!;
      final json = entry.toJson(instant);

      expect(json, literal, reason: '$unit');
      // 1704112496.0 == 1704112496, so only the type catches an epoch unit sending a double.
      expect(json.runtimeType, literal.runtimeType, reason: '$unit');
      expect(entry.fromJson(literal)!.toUtc(), instant, reason: '$unit');
      // Initial filter values and JSON decoding can hand an epoch back as a double.
      if (literal is int) expect(entry.fromJson(literal.toDouble())!.toUtc(), instant, reason: '$unit');
      expect(entry.toJson(null), isNull, reason: '$unit');
      expect(entry.fromJson(null), isNull, reason: '$unit');
    }

    // CmsDatePicker emits a local midnight, which the dateTime unit currently
    // sends as wall time without an offset.
    expect(entryOf().toJson(DateTime(2024, 1, 15)), '2024-01-15 00:00:00.000');
    expect(entryOf().fromJson('2024-01-15 00:00:00.000'), DateTime(2024, 1, 15));
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
      expect(entryOf().filterFromValues({'from': serialized}), const CmsFilterGreaterOrEq('createdAt', serialized));
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
