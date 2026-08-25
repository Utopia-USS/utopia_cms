import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/src/util/date_time_extension.dart';
import 'package:utopia_cms/utopia_cms.dart';

class _UnusedMediaDelegate implements CmsMediaDelegate {
  @override
  Future<CmsMediaUploadRes> upload(XFile file) => throw UnimplementedError();

  @override
  Future<void> delete(Object? value) => throw UnimplementedError();
}

CmsMediaType _alwaysImage(dynamic object) => CmsMediaType.image;

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext result;
  await tester.pumpWidget(
    Builder(
      builder: (context) {
        result = context;
        return const SizedBox();
      },
    ),
  );
  return result;
}

void main() {
  group('label', () {
    test('falls back to the last segment of a dotted key', () {
      expect(CmsTextEntry(key: 'user.contactData.name').fixedLabel, 'name');
    });

    test('prefers an explicit label', () {
      expect(CmsTextEntry(key: 'user.contactData.name', label: 'Full name').fixedLabel, 'Full name');
    });

    test('appends an asterisk only when the entry is required', () {
      expect(CmsTextEntry(key: 'name').fixedLabelRequired, 'name*');
      expect(
        CmsTextEntry(key: 'name', modifier: const CmsEntryModifier(required: false)).fixedLabelRequired,
        'name',
      );
    });
  });

  group('media entry label', () {
    final delegate = _UnusedMediaDelegate();

    testWidgets('media entry field uses the shared label logic', (tester) async {
      final entry = CmsMediaEntry(
        key: 'assets.cover',
        delegate: delegate,
        supportedMedia: const [CmsMediaType.image],
        mediaTypeBuilder: _alwaysImage,
      );
      final context = await _pumpContext(tester);
      final field = entry.buildEditField(context: context, value: null, onChanged: (_) {}) as CmsMediaField;
      expect(field.label, 'cover*');
    });

    testWidgets('single media entry field uses the shared label logic', (tester) async {
      final entry = CmsSingleMediaEntry(
        key: 'assets.cover',
        delegate: delegate,
        supportedMedia: const [CmsMediaType.image],
        mediaTypeBuilder: _alwaysImage,
        modifier: const CmsEntryModifier(required: false),
      );
      final context = await _pumpContext(tester);
      final field = entry.buildEditField(context: context, value: null, onChanged: (_) {}) as CmsMediaField;
      expect(field.label, 'cover');
    });
  });

  group('date entry', () {
    final entry = CmsDateEntry(key: 'createdAt');

    test('round-trips a local date', () {
      final value = DateTime(2024, 3, 11, 8, 30);
      expect(entry.fromJson(entry.toJson(value)), value);
    });

    test('keeps a stored utc instant through a read and a write', () {
      const stored = '2024-03-10T23:00:00.000Z';
      final parsed = entry.fromJson(stored)!;
      expect(parsed.isUtc, isTrue);
      expect(DateTime.parse(entry.toJson(parsed)!).isAtSameMomentAs(DateTime.parse(stored)), isTrue);
    });

    test('serializes with the DateTime.toString format', () {
      expect(entry.toJson(DateTime.utc(2024, 3, 10, 23)), '2024-03-10 23:00:00.000Z');
      expect(entry.toJson(DateTime(2024, 3, 11)), '2024-03-11 00:00:00.000');
    });

    test('returns null for a null json', () {
      expect(entry.fromJson(null), isNull);
      expect(entry.toJson(null), isNull);
    });

    test('display formatting depends on the instant, not the DateTime flavor', () {
      // Inert under TZ=UTC: run tests with a non-UTC TZ to exercise the toLocal() fix.
      final utc = DateTime.utc(2024, 3, 10, 23);
      final sameMoment = DateTime.fromMillisecondsSinceEpoch(utc.millisecondsSinceEpoch);
      expect(utc.toDisplayString(), sameMoment.toDisplayString());
      expect(utc.toDisplayStringWithoutHours(), sameMoment.toDisplayStringWithoutHours());
    });
  });

  group('primitive fromJson', () {
    // The base fromJson is a raw cast. Both primitives override it so a backend
    // storing them as text renders instead of crashing the whole table with a
    // TypeError raised from inside the row builder.
    Matcher throwsFormatExceptionOn(Object? source) =>
        throwsA(isA<FormatException>().having((it) => it.source, 'source', source));

    test('num entry widens a stringified number and reports garbage', () {
      final entry = CmsNumEntry(key: 'price');

      expect(entry.fromJson('12.5'), 12.5);
      expect(entry.fromJson('-3'), -3);
      expect(entry.fromJson(12.5), 12.5);
      expect(entry.fromJson(null), isNull);

      expect(() => entry.fromJson('twelve'), throwsFormatExceptionOn('twelve'));
      expect(() => entry.fromJson(''), throwsFormatExceptionOn(''));
      expect(() => entry.fromJson(true), throwsFormatExceptionOn(true));
    });

    test('bool entry parses the spellings a backend stores and reports garbage', () {
      final entry = CmsBoolEntry(key: 'visible');

      expect(entry.fromJson(true), isTrue);
      expect(entry.fromJson('true'), isTrue);
      expect(entry.fromJson('FALSE'), isFalse);
      expect(entry.fromJson(1), isTrue);
      expect(entry.fromJson(0), isFalse);
      expect(entry.fromJson(null), isNull);

      expect(() => entry.fromJson('yes'), throwsFormatExceptionOn('yes'));
      expect(() => entry.fromJson(2), throwsFormatExceptionOn(2));
      expect(() => entry.fromJson(const <String, dynamic>{}), throwsFormatExceptionOn(const <String, dynamic>{}));
    });
  });
}
