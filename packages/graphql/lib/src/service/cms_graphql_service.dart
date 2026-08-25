import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/src/model/cms_graphql_field.dart';
import 'package:utopia_cms_graphql/src/util/graphql_extensions.dart';

class CmsGraphQLService {
  const CmsGraphQLService();

  Future<Object?> query(
    GraphQLClient client, {
    required String name,
    required CmsGraphQLFields fields,
    Map<String, String> variableTypes = const {},
    Map<String, ValueNode> arguments = const {},
    JsonMap variables = const {},
  }) async {
    final document = _buildDocument(
      type: OperationType.query,
      name: name,
      fields: fields,
      variableTypes: variableTypes,
      arguments: arguments,
    );
    final result = await client.query(QueryOptions(document: document, variables: variables));
    return _readResult(result, name: name);
  }

  Future<Object?> mutate(
    GraphQLClient client, {
    required String name,
    CmsGraphQLFields? fields,
    Map<String, String> variableTypes = const {},
    Map<String, ValueNode> arguments = const {},
    JsonMap variables = const {},
  }) async {
    final document = _buildDocument(
      type: OperationType.mutation,
      name: name,
      fields: fields,
      variableTypes: variableTypes,
      arguments: arguments,
    );
    final result = await client.mutate(MutationOptions(document: document, variables: variables));
    return _readResult(result, name: name);
  }

  DocumentNode _buildDocument({
    required OperationType type,
    required String name,
    required CmsGraphQLFields? fields,
    Map<String, String> variableTypes = const {},
    Map<String, ValueNode> arguments = const {},
  }) {
    return DocumentNode(
      definitions: [
        OperationDefinitionNode(
          type: type,
          name: "operation".toNameNode(),
          variableDefinitions: variableTypes.toVariableDefinitions(),
          selectionSet: SelectionSetNode(
            selections: [
              FieldNode(
                alias: "result".toNameNode(),
                name: name.toNameNode(),
                selectionSet: fields?.let(_buildSelectionSet),
                arguments: arguments.toArgumentNodes(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SelectionSetNode _buildSelectionSet(CmsGraphQLFields fields) {
    return SelectionSetNode(
      selections: [
        if (fields.isEmpty) _buildFieldNode(CmsGraphQLField.typename),
        for (final field in fields) _buildFieldNode(field),
      ],
    );
  }

  FieldNode _buildFieldNode(CmsGraphQLField field) {
    return FieldNode(name: field.key.toNameNode(), selectionSet: field.fields?.let(_buildSelectionSet));
  }

  /// Unwraps the aliased root field, or reports why it is missing.
  ///
  /// A result can carry neither data nor an exception - a cache-only lookup, or a
  /// response whose `data` is null without any `errors` - and that has to surface
  /// as a described failure rather than a null-check error.
  Object? _readResult(QueryResult result, {required String name}) {
    if (result.hasException) throw result.exception!;
    final data = result.data;
    if (data == null) {
      throw StateError('GraphQL operation "$name" returned no data and no errors (source: ${result.source}).');
    }
    return data["result"];
  }
}
