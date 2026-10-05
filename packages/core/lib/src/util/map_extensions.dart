import 'package:utopia_cms/src/util/json_map.dart';

extension JsonMapExtensions on JsonMap {
  dynamic getAtPath(String path) {
    assert(path.isNotEmpty);
    dynamic value = this;
    for (final component in path.split('.')) {
      if (value is! JsonMap) return null;
      value = value[component];
      if (value == null) break;
    }
    return value;
  }

  /// Sets [value] at the dot-separated [path], creating missing parent maps.
  /// An intermediate value that is not a map is replaced by a new map.
  // ignore: avoid_annotating_with_dynamic
  void setAtPath(String path, dynamic value) {
    assert(path.isNotEmpty);
    final components = path.split('.');
    var map = this;
    for (final component in components.take(components.length - 1)) {
      final next = map[component];
      if (next is JsonMap) {
        map = next;
      } else {
        final created = <String, dynamic>{};
        map[component] = created;
        map = created;
      }
    }
    map[components.last] = value;
  }

  /// Recursively copies this map, so that no nested [Map] or [List] is shared
  /// with the original. Non-collection values are kept as-is.
  JsonMap deepCopy() => _copyValue(this) as JsonMap;
}

dynamic _copyValue(dynamic value) {
  if (value is JsonMap) return {for (final entry in value.entries) entry.key: _copyValue(entry.value)};
  if (value is List) return value.map<dynamic>(_copyValue).toList();
  return value;
}
