import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  const a = CmsFilterEquals('a', 1);
  const b = CmsFilterEquals('b', 2);
  const c = CmsFilterEquals('c', 3);

  group('and', () {
    test('keeps two leaf operands as two terms', () {
      expect(a & b, const CmsFilterAnd([a, b]));
    });

    test('flattens a nested and on the left', () {
      expect(const CmsFilterAnd([a, b]) & c, const CmsFilterAnd([a, b, c]));
    });

    test('flattens a nested and on the right', () {
      expect(a & const CmsFilterAnd([b, c]), const CmsFilterAnd([a, b, c]));
    });

    test('does not flatten a nested or', () {
      expect(a & const CmsFilterOr([b, c]), const CmsFilterAnd([a, CmsFilterOr([b, c])]));
    });

    test('keeps the all term instead of simplifying it away', () {
      expect(const CmsFilterAll() & a, const CmsFilterAnd([CmsFilterAll(), a]));
    });

    test('does not mutate the operands', () {
      final leftFilters = <CmsFilter>[a, b];
      final rightFilters = <CmsFilter>[c];
      expect(CmsFilterAnd(leftFilters) & CmsFilterAnd(rightFilters), const CmsFilterAnd([a, b, c]));
      expect(leftFilters, [a, b]);
      expect(rightFilters, [c]);
    });
  });

  group('or', () {
    test('keeps two leaf operands as two terms', () {
      expect(a | b, const CmsFilterOr([a, b]));
    });

    test('flattens nested ors on both sides', () {
      expect(const CmsFilterOr([a, b]) | const CmsFilterOr([c]), const CmsFilterOr([a, b, c]));
    });
  });

  group('not', () {
    test('wraps a leaf filter', () {
      expect(~a, const CmsFilterNot(a));
    });

    test('applies De Morgan to and', () {
      expect(~const CmsFilterAnd([a, b]), const CmsFilterOr([CmsFilterNot(a), CmsFilterNot(b)]));
    });

    test('applies De Morgan to or', () {
      expect(~const CmsFilterOr([a, b]), const CmsFilterAnd([CmsFilterNot(a), CmsFilterNot(b)]));
    });

    test('turns an empty and into an empty or', () {
      expect(~const CmsFilterAnd([]), const CmsFilterOr([]));
    });
  });
}
