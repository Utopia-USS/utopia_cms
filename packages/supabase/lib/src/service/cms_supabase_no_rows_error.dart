/// Thrown by `CmsSupabaseService` when a write that should come back with the
/// affected row comes back empty. In practice that is usually row-level
/// security silently filtering the target row out.
///
/// It stays a [StateError] for direct callers of the service, but has a type of
/// its own so `guardSupabaseCall` can report it without also swallowing every
/// other bad state.
class CmsSupabaseNoRowsError extends StateError {
  CmsSupabaseNoRowsError() : super('Expected at least one row from Supabase, got none.');
}
