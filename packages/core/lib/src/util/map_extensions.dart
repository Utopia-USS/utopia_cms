import 'package:utopia_cms/src/util/json_map.dart';

extension JsonMapExtensions on JsonMap {
  dynamic getAtPath(String path) {
    assert(path.isNotEmpty);
    dynamic value = this;
    for (final component in path.split('.')) {
      value = (value as JsonMap)[component];
      if(value == null) break;
    }
    return value;
  }

  // ignore: avoid_annotating_with_dynamic
  void setAtPath(String path, dynamic value) {
    assert(path.isNotEmpty);
    final components = path.split('.');
    var map = this;
    for (final component in components.take(components.length - 1)) {
      map = map[component] as JsonMap;
    }
    map[components.last] = value;
  }
}
