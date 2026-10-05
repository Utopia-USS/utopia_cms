import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/src/service/cms_supabase_no_rows_error.dart';

/// Runs [run], reporting a Supabase failure as a [CmsDelegateException] so the
/// CMS can show it inline instead of crashing on an exception type it does not
/// know.
///
/// [description] names the operation in domain terms, e.g. `update "users"`.
///
/// Only failures the backend causes are wrapped: the exceptions it throws and a
/// [CmsSupabaseNoRowsError] for a write it matched to no rows. A programmer
/// error - a bad argument, a missing id, any other [StateError], an exception a
/// delegate subclass raises - keeps its type so it still surfaces as the bug it
/// is. The original stack trace is kept either way: [CmsDelegateException] has
/// nowhere to carry a cause, so the backend message goes into the message and
/// the trace is rethrown as is.
Future<T> guardSupabaseCall<T>(String description, Future<T> Function() run) async {
  try {
    return await run();
  } on PostgrestException catch (e, stackTrace) {
    Error.throwWithStackTrace(CmsDelegateException('Failed to $description: ${e.message}'), stackTrace);
  } on AuthException catch (e, stackTrace) {
    Error.throwWithStackTrace(CmsDelegateException('Failed to $description: ${e.message}'), stackTrace);
  } on CmsSupabaseNoRowsError catch (e, stackTrace) {
    Error.throwWithStackTrace(CmsDelegateException('Failed to $description: ${e.message}'), stackTrace);
  }
}
