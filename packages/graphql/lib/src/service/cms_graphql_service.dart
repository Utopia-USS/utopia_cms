import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/src/model/cms_graphql_field.dart';
import 'package:utopia_cms_graphql/src/util/graphql_extensions.dart';
import 'package:utopia_utils/utopia_utils.dart';

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
    _checkResult(result);
    return result.data!["result"];
  }

  Future<Object?> mutate(
    GraphQLClient client, {
    required String name,
    CmsGraphQLFields fields = const {},
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
    _checkResult(result);
    return result.data!["result"];
  }

  DocumentNode _buildDocument({
    required OperationType type,
    required String name,
    required CmsGraphQLFields fields,
    Map<String, String> variableTypes = const {},
    Map<String, ValueNode> arguments = const {},
  }) {
    return DocumentNode(definitions: [
      OperationDefinitionNode(
        type: type,
        name: "operation".toNameNode(),
        variableDefinitions: variableTypes.toVariableDefinitions(),
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            alias: "result".toNameNode(),
            name: name.toNameNode(),
            selectionSet: _buildSelectionSet(fields),
            arguments: arguments.toArgumentNodes(),
          ),
        ]),
      ),
    ]);
  }

  SelectionSetNode _buildSelectionSet(CmsGraphQLFields fields) {
    return SelectionSetNode(selections: [
      if (fields.isEmpty) _buildFieldNode(CmsGraphQLField.typename),
      for (final field in fields) _buildFieldNode(field),
    ]);
  }

  FieldNode _buildFieldNode(CmsGraphQLField field) {
    return FieldNode(
      name: field.key.toNameNode(),
      selectionSet: field.fields?.let(_buildSelectionSet),
    );
  }

  void _checkResult(QueryResult result) {
    if (result.hasException) throw result.exception!;
  }
}
