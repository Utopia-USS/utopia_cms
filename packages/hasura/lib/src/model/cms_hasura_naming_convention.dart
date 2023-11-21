import 'package:utopia_cms_hasura/src/util/string_extensions.dart';

enum CmsHasuraNamingConvention {
  pascal,
  camel;

  String call(List<String> components) {
    return switch(this) {
      pascal => components.join("_"),
      camel => components.first + components.skip(1).map((e) => e.capitalize()).join(),
    };
  }
}