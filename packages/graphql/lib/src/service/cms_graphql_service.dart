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
    final description = 'run GraphQL query "$name"';
    return _guard(description, () async {
      final result = await client.query(QueryOptions(document: document, variables: variables));
      return _readResult(result, description: description);
    });
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
    final description = 'run GraphQL mutation "$name"';
    return _guard(description, () async {
      final result = await client.mutate(MutationOptions(document: document, variables: variables));
      return _readResult(result, description: description);
    });
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
  Object? _readResult(QueryResult result, {required String description}) {
    if (result.hasException) throw result.exception!;
    final data = result.data;
    if (data == null) {
      throw CmsDelegateException('Failed to $description: no data and no errors came back (source: ${result.source}).');
    }
    return data["result"];
  }

  /// Runs [run], reporting a GraphQL failure as a [CmsDelegateException] so the
  /// CMS can show it inline instead of crashing on an exception type it does not
  /// know.
  ///
  /// Only [OperationException] is caught - the single type the client raises,
  /// since it also folds a link-level failure into one. A programmer error keeps
  /// its type. [CmsDelegateException] has nowhere to carry a cause, so the server
  /// message goes into the message and the original stack trace is rethrown as
  /// is.
  Future<Object?> _guard(String description, Future<Object?> Function() run) async {
    try {
      return await run();
    } on OperationException catch (e, stackTrace) {
      Error.throwWithStackTrace(CmsDelegateException('Failed to $description: ${_describe(e)}'), stackTrace);
    }
  }

  /// The part of [exception] worth showing an admin: what the server refused,
  /// or - when it never answered - what went wrong on the way there.
  ///
  /// A link failure is described by its cause rather than by itself: every
  /// `LinkException.toString()` splices in the original stack trace, which has
  /// no place in a message rendered inline in the CMS.
  String _describe(OperationException exception) {
    final errors = exception.graphqlErrors.map((it) => it.message);
    if (errors.isNotEmpty) return errors.join('; ');

    final link = exception.linkException;
    if (link == null) return exception.toString();
    return '${link.originalException ?? link.runtimeType}';
  }
}
