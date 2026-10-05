import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms_supabase/utopia_cms_supabase.dart';

import 'http_recorder.dart';

void main() {
  late HttpRecorder recorder;
  late SupabaseClient client;
  late CmsSupabaseManyToManyDelegate delegate;

  setUp(() {
    recorder = HttpRecorder();
    client = SupabaseClient('https://project.supabase.co', 'anon-key', httpClient: recorder);
    delegate = CmsSupabase.instance.manyToManyDelegate(
      client: client,
      associationTable: const CmsSupabaseAssociationTable(
        'user_groups',
        originTable: CmsSupabaseDataTable('users'),
        foreignTable: CmsSupabaseDataTable('groups'),
        originKey: 'user_id',
        foreignKey: 'group_id',
      ),
    );
  });

  tearDown(() => client.dispose());

  test('get for an origin reads its associations, then the foreign rows by id', () async {
    recorder.body = '[{"user_id": 1, "group_id": 10}, {"user_id": 1, "group_id": 11}]';

    await delegate.get(originId: 1);

    expect([for (final it in recorder.requests) it.url.path], ['/rest/v1/user_groups', '/rest/v1/groups']);
    expect(recorder.requests.first.url.queryParameters['user_id'], 'eq.1');
    expect(recorder.last!.url.queryParameters['id'], 'in.(10,11)');
  });

  test('get for an origin without associations sends no second request', () async {
    await delegate.get(originId: 1);

    expect([for (final it in recorder.requests) it.url.path], ['/rest/v1/user_groups']);
  });

  test('removing a foreign id deletes only its association row', () async {
    await delegate.update(originId: 1, addedForeignIds: const ISet.empty(), removedForeignIds: {10}.lock);

    expect(recorder.last!.method, 'DELETE');
    expect(recorder.last!.url.path, '/rest/v1/user_groups');
    expect(recorder.last!.url.queryParameters, {'user_id': 'eq.1', 'group_id': 'in.(10)', 'select': '*'});
  });
}
