import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  group('getAtPath', () {
    test('reads a flat key', () {
      expect(<String, dynamic>{'a': 1}.getAtPath('a'), 1);
    });

    test('reads a nested path', () {
      expect(
        <String, dynamic>{
          'a': {'b': 'x'},
        }.getAtPath('a.b'),
        'x',
      );
    });

    test('returns null for a missing key', () {
      expect(<String, dynamic>{'a': 1}.getAtPath('b'), isNull);
    });

    test('returns null when the path continues through null', () {
      expect(<String, dynamic>{'a': null}.getAtPath('a.b'), isNull);
    });

    test('returns null when an intermediate value is not a map', () {
      expect(<String, dynamic>{'a': 1}.getAtPath('a.b'), isNull);
    });

    test('reads through a covariantly-typed nested map', () {
      expect(
        <String, dynamic>{'a': <String, String>{'b': 'x'}}.getAtPath('a.b'),
        'x',
      );
    });
  });

  group('setAtPath', () {
    test('sets a flat key', () {
      final map = <String, dynamic>{};
      map.setAtPath('a', 1);
      expect(map, {'a': 1});
    });

    test('sets inside an existing nested map', () {
      final map = <String, dynamic>{
        'a': {'b': 1, 'keep': true},
      };
      map.setAtPath('a.b', 2);
      expect(map, {
        'a': {'b': 2, 'keep': true},
      });
    });

    test('creates missing parents on an empty map', () {
      final map = <String, dynamic>{};
      map.setAtPath('contactData.name', 'x');
      expect(map, {
        'contactData': {'name': 'x'},
      });
    });

    test('creates a multi-level chain of missing parents', () {
      final map = <String, dynamic>{};
      map.setAtPath('a.b.c', 1);
      expect(map, {
        'a': {
          'b': {'c': 1},
        },
      });
    });

    test('replaces a non-map intermediate value with a map', () {
      final map = <String, dynamic>{'a': 1};
      map.setAtPath('a.b', 2);
      expect(map, {
        'a': {'b': 2},
      });
    });
  });

  group('deepCopy', () {
    test('copies nested maps and lists so mutations do not leak back', () {
      final original = <String, dynamic>{
        'a': {
          'b': 1,
          'list': [
            {'c': 2},
          ],
        },
      };

      final copy = original.deepCopy();
      copy.setAtPath('a.b', 99);
      (((copy['a'] as JsonMap)['list'] as List).first as JsonMap)['c'] = 99;

      expect(original.getAtPath('a.b'), 1);
      expect(original.getAtPath('a.list'), [
        {'c': 2},
      ]);
    });

    test('keeps scalar values as-is', () {
      final original = <String, dynamic>{'a': 'x', 'b': null};
      expect(original.deepCopy(), original);
    });
  });
}
