import 'package:gql/ast.dart';

extension GraphQLValueNodeMapExtensions on Map<String, ValueNode> {
  ObjectValueNode toValueNode() {
    return ObjectValueNode(
      fields: [for (final entry in entries) ObjectFieldNode(name: NameNode(value: entry.key), value: entry.value)],
    );
  }

  List<ArgumentNode> toArgumentNodes() {
    return [
      for (final entry in entries) ArgumentNode(name: entry.key.toNameNode(), value: entry.value),
    ];
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
  StringValueNode toValueNode({bool isBlock = false}) => StringValueNode(value: this, isBlock: isBlock);

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
