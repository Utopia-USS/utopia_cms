import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

import '../_fake/stub_build_context.dart';

class _UnusedMediaDelegate implements CmsMediaDelegate {
  @override
  Future<CmsMediaUploadRes> upload(XFile file) => throw UnimplementedError();

  @override
  Future<void> delete(Object? value) => throw UnimplementedError();
}

CmsMediaType _alwaysImage(dynamic object) => CmsMediaType.image;

void main() {
  test('label falls back to the last key segment and marks required entries', () {
    expect(CmsTextEntry(key: 'user.contactData.name').fixedLabel, 'name');
    expect(CmsTextEntry(key: 'user.contactData.name', label: 'Full name').fixedLabel, 'Full name');
    expect(CmsTextEntry(key: 'name').fixedLabelRequired, 'name*');
    expect(CmsTextEntry(key: 'name', modifier: const CmsEntryModifier(required: false)).fixedLabelRequired, 'name');
  });

  test('media fields use the shared label instead of the dotted key', () {
    final delegate = _UnusedMediaDelegate();
    CmsMediaField fieldOf(CmsEntry<dynamic> entry) =>
        entry.buildEditField(context: StubBuildContext(), value: null, onChanged: (_) {}) as CmsMediaField;

    final media = CmsMediaEntry(
      key: 'assets.cover',
      delegate: delegate,
      supportedMedia: const [CmsMediaType.image],
      mediaTypeBuilder: _alwaysImage,
    );
    final singleMedia = CmsSingleMediaEntry(
      key: 'assets.cover',
      delegate: delegate,
      supportedMedia: const [CmsMediaType.image],
      mediaTypeBuilder: _alwaysImage,
      modifier: const CmsEntryModifier(required: false),
    );

    expect(fieldOf(media).label, 'cover*');
    expect(fieldOf(singleMedia).label, 'cover');
  });

  test('date entry stores DateTime.toString and reads DateTime.parse', () {
    final entry = CmsDateEntry(key: 'createdAt');

    expect(entry.toJson(DateTime.utc(2024, 3, 10, 23)), '2024-03-10 23:00:00.000Z');
    expect(entry.toJson(DateTime(2024, 3, 11, 8, 30)), '2024-03-11 08:30:00.000');
    expect(entry.fromJson('2024-03-10T23:00:00.000Z'), DateTime.utc(2024, 3, 10, 23));
    expect(entry.fromJson('2024-03-11 08:30:00.000'), DateTime(2024, 3, 11, 8, 30));
    expect(entry.toJson(null), isNull);
    expect(entry.fromJson(null), isNull);
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
