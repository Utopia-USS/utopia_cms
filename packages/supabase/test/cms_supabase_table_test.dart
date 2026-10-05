// fullName is deprecated but still public, so its value is pinned until it goes.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms_supabase/utopia_cms_supabase.dart';

void main() {
  test('the deprecated fullName qualifies the name only when there is a schema', () {
    expect(const CmsSupabaseTable('users').fullName, 'users');
    expect(const CmsSupabaseTable('users', schema: 'app').fullName, 'app.users');
  });
}
