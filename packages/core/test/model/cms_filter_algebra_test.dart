import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  const a = CmsFilterEquals('a', 1);
  const b = CmsFilterEquals('b', 2);
  const c = CmsFilterEquals('c', 3);
  const all = CmsFilterAll();

  test('and flattens nested ands on either side, not nested ors', () {
    expect(a & b, const CmsFilterAnd([a, b]));
    expect(const CmsFilterAnd([a, b]) & c, const CmsFilterAnd([a, b, c]));
    expect(a & const CmsFilterAnd([b, c]), const CmsFilterAnd([a, b, c]));
    expect(
      a & const CmsFilterOr([b, c]),
      const CmsFilterAnd([
        a,
        CmsFilterOr([b, c]),
      ]),
    );
  });

  test('or flattens nested ors and never drops an all term', () {
    expect(a | b, const CmsFilterOr([a, b]));
    expect(const CmsFilterOr([a, b]) | const CmsFilterOr([c]), const CmsFilterOr([a, b, c]));
    // All absorbs in an or: dropping it as if it were an identity narrows the result.
    expect(all | a, const CmsFilterOr([all, a]));
    expect(a | all, const CmsFilterOr([a, all]));
  });

  test('not wraps a leaf and applies De Morgan to and / or', () {
    expect(~a, const CmsFilterNot(a));
    expect(~const CmsFilterAnd([a, b]), const CmsFilterOr([CmsFilterNot(a), CmsFilterNot(b)]));
    expect(~const CmsFilterOr([a, b]), const CmsFilterAnd([CmsFilterNot(a), CmsFilterNot(b)]));
    expect(~const CmsFilterAnd([]), const CmsFilterOr([]));
  });
}
