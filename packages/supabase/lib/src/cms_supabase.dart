import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/src/delegate/cms_supabase_delegate.dart';
import 'package:utopia_cms_supabase/src/delegate/cms_supabase_to_many_delegate.dart';
import 'package:utopia_cms_supabase/src/model/cms_supabase_table.dart';
import 'package:utopia_cms_supabase/src/service/cms_supabase_service.dart';

class CmsSupabase {
  static const instance = CmsSupabase();

  final CmsSupabaseService service;

  const CmsSupabase({this.service = const CmsSupabaseService()});

  CmsSupabaseDelegate delegate({
    required SupabaseClient client,
    required CmsSupabaseDataTable table,
    CmsFilterNotEquals? archivedFilter,
  }) =>
      CmsSupabaseDelegate(service, client: client, table: table, archivedFilter: archivedFilter);

  CmsSupabaseOneToManyDelegate oneToManyDelegate({
    required SupabaseClient client,
    required CmsSupabaseDataTable originTable,
    required CmsSupabaseDataTable foreignTable,
    required String foreignKey,
    CmsFilterNotEquals? archivedFilter,
  }) {
    return CmsSupabaseOneToManyDelegate(
      service,
      client: client,
      originTable: originTable,
      foreignTable: foreignTable,
      foreignKey: foreignKey,
      archivedFilter: archivedFilter,
    );
  }

  CmsSupabaseManyToManyDelegate manyToManyDelegate({
    required SupabaseClient client,
    required CmsSupabaseAssociationTable associationTable,
    CmsFilterNotEquals? archivedFilter,
  }) {
    return CmsSupabaseManyToManyDelegate(
      service,
      client: client,
      associationTable: associationTable,
      archivedFilter: archivedFilter,
    );
  }
}

