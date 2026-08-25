import 'package:gql/ast.dart';

extension GraphQLValueNodeMapExtensions on Map<String, ValueNode> {
  ObjectValueNode toValueNode() {
    return ObjectValueNode(
      fields: [
        for (final entry in entries)
          ObjectFieldNode(
            name: NameNode(value: entry.key),
            value: entry.value,
          ),
      ],
    );
  }

  List<ArgumentNode> toArgumentNodes() {
    return [for (final entry in entries) ArgumentNode(name: entry.key.toNameNode(), value: entry.value)];
  }
}

extension GraphQLStringMapExtensions on Map<String, String> {
  List<VariableDefinitionNode> toVariableDefinitions() {
    return [
      for (final entry in entries)
        VariableDefinitionNode(
          variable: entry.key.toVariableNode(),
          type: entry.value.toNamedTypeNode(),
          defaultValue: const DefaultValueNode(value: null),
        ),
    ];
  }
}

extension GraphQLIterableExtensions on Iterable<ValueNode> {
  ListValueNode toValueNode() => ListValueNode(values: toList());
}

extension GraphQLStringExtensions on String {
  /// Wraps this string as a GraphQL string value, escaped for the wire.
  ///
  /// Block strings keep their content verbatim - they have their own escaping
  /// rules and no escape sequences to apply.
  StringValueNode toValueNode({bool isBlock = false}) =>
      StringValueNode(value: isBlock ? this : _escapeGraphQLString(this), isBlock: isBlock);

  NameNode toNameNode() => NameNode(value: this);

  NamedTypeNode toNamedTypeNode() => NamedTypeNode(name: toNameNode());

  EnumValueNode toEnumValueNode() => EnumValueNode(name: toNameNode());

  VariableNode toVariableNode() => VariableNode(name: toNameNode());
}

extension GraphQLAnyExtensions on Object? {
  ValueNode toValueNodeUnsafe() {
    final self = this;
    if (self is ValueNode) return self;
    if (self == null) return const NullValueNode();
    if (self is String) return self.toValueNode();
    if (self is int) return IntValueNode(value: self.toString());
    if (self is double) return FloatValueNode(value: self.toString());
    if (self is bool) return BooleanValueNode(value: self);
    if (self is Iterable) return self.map((it) => (it as Object?).toValueNodeUnsafe()).toValueNode();
    if (self is Map) {
      return self.map((key, value) => MapEntry(key.toString(), (value as Object?).toValueNodeUnsafe())).toValueNode();
    }
    throw Exception("Unsupported type: $runtimeType");
  }
}

/// Escapes [value] for the quoted GraphQL string form.
///
/// `gql` prints a `StringValueNode` verbatim between quotes, so the escaping has
/// to happen while the node is built. Without it any value carrying a backslash,
/// a double quote or a control character prints as a document no GraphQL server
/// can parse.
String _escapeGraphQLString(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    switch (rune) {
      case 0x22: // "
        buffer.write(r'\"');
      case 0x5C: // \
        buffer.write(r'\\');
      case 0x08:
        buffer.write(r'\b');
      case 0x09:
        buffer.write(r'\t');
      case 0x0A:
        buffer.write(r'\n');
      case 0x0C:
        buffer.write(r'\f');
      case 0x0D:
        buffer.write(r'\r');
      default:
        // Every other control character has no short escape, so it goes out as a
        // unicode escape sequence.
        if (rune < 0x20) {
          buffer.write('\\u${rune.toRadixString(16).padLeft(4, '0').toUpperCase()}');
        } else {
          buffer.writeCharCode(rune);
        }
    }
  }
  return buffer.toString();
}
