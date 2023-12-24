import 'package:utopia_cms_hasura/src/util/string_case_utils.dart';

enum CmsHasuraNamingConvention {
  hasura.uniform(StringCase.snake),
  graphql(
    field: StringCase.camel,
    type: StringCase.camelCapitalized,
    argument: StringCase.camel,
    enumValue: StringCase.snakeUppercase,
  );

  const CmsHasuraNamingConvention({
    required this.field,
    required this.type,
    required this.argument,
    required this.enumValue,
  });

  const CmsHasuraNamingConvention.uniform(StringCase stringCase)
      : this(field: stringCase, type: stringCase, argument: stringCase, enumValue: stringCase);

  final StringCase field, type, argument, enumValue;
}
