import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms_hasura/src/util/string_case_utils.dart';

void main() {
  test('camel joins components without lowering their interior capitals', () {
    expect(StringCase.camel(['insert', 'userProfile']), 'insertUserProfile');
  });

  test('camelCapitalized keeps interior capitals too', () {
    expect(StringCase.camelCapitalized(['orderBy']), 'OrderBy');
  });

  test('snake joins components with underscores', () {
    expect(StringCase.snake(['update', 'user', 'by', 'pk']), 'update_user_by_pk');
  });

  test('snakeUppercase upcases the joined result', () {
    expect(StringCase.snakeUppercase(['desc', 'nulls', 'last']), 'DESC_NULLS_LAST');
  });
}
