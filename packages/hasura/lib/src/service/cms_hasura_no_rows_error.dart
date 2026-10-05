/// Thrown by `CmsHasuraService.insertOne` when the insert comes back without the
/// row it wrote. In practice that is usually the role's select permission
/// filtering the new row out of `returning`.
///
/// It stays a [StateError] for direct callers of the service, but has a type of
/// its own so `guardHasuraCall` can report it without also swallowing every
/// other bad state.
class CmsHasuraNoRowsError extends StateError {
  CmsHasuraNoRowsError() : super('Expected the inserted row back from Hasura, got none.');
}
