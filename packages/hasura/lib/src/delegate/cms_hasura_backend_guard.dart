import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_hasura/src/model/cms_hasura_table.dart';
import 'package:utopia_cms_hasura/src/service/cms_hasura_no_rows_error.dart';

/// Runs [call] as the delegate [operation] on [table], reporting a backend
/// failure as a [CmsDelegateException] so the CMS shows it inline instead of
/// letting a raw backend exception escape into the error boundary.
///
/// Wrapped are the failures the backend itself produces:
/// - [OperationException], which the `graphql` client raises both for errors the
///   server returned and for transport failures, which the query manager
///   translates into its `linkException`;
/// - [CmsHasuraNoRowsError], which `insertOne` raises for an insert that
///   returned no row.
///
/// `CmsGraphQLService` already reports its own failures, a response carrying
/// neither data nor errors included, as a [CmsDelegateException], which passes
/// through untouched. Everything else - [ArgumentError], [TypeError], any other
/// [StateError] and the like - is a bug in the delegate wiring rather than
/// something the operator can act on, so it passes through untouched too.
Future<T> guardHasuraCall<T>(
  Future<T> Function() call, {
  required String operation,
  required CmsHasuraTable table,
}) async {
  try {
    return await call();
  } on OperationException catch (exception) {
    // In the standard stack CmsGraphQLService already wraps this into a
    // CmsDelegateException (which passes through untouched above); this clause
    // covers custom services that surface the raw client exception.
    throw CmsDelegateException(_message(operation, table, _describe(exception)));
  } on CmsHasuraNoRowsError catch (error) {
    throw CmsDelegateException(_message(operation, table, error.message));
  }
}

String _message(String operation, CmsHasuraTable table, String reason) =>
    'Could not $operation "${table.name}": $reason';

/// What the server said, falling back to the transport failure - the exception's
/// own `toString` repeats the whole envelope, which reads badly inline.
String _describe(OperationException exception) {
  final errors = exception.graphqlErrors.map((it) => it.message).where((it) => it.isNotEmpty);
  if (errors.isNotEmpty) return errors.join('; ');
  return (exception.linkException ?? exception).toString();
}
