import 'package:utopia_cms_hasura/src/util/string_extensions.dart';

enum StringCase {
  snake,
  snakeUppercase,
  camel,
  camelCapitalized;

  String call(List<String> components) {
    return switch(this) {
      snake => components.join("_"),
      snakeUppercase => components.join("_").toUpperCase(),
      camel => components.first + components.skip(1).map((e) => e.capitalize()).join(),
      camelCapitalized => components.map((e) => e.capitalize()).join(),
    };
  }
}
