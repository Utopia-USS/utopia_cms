class CmsSupabaseTable {
  final String name;

  /// Exposed Postgres schema holding the table, or `null` for the default one.
  final String? schema;

  const CmsSupabaseTable(this.name, {this.schema});

  @Deprecated('Schema is now selected via client.schema(); this produced an invalid PostgREST endpoint.')
  String get fullName => '$schema.$name';
}

class CmsSupabaseDataTable extends CmsSupabaseTable {
  final String idKey;

  const CmsSupabaseDataTable(super.name, {this.idKey = 'id', super.schema});
}

class CmsSupabaseAssociationTable extends CmsSupabaseTable {
  final CmsSupabaseDataTable originTable, foreignTable;
  final String originKey, foreignKey;

  const CmsSupabaseAssociationTable(
    super.name, {
    required this.originTable,
    required this.foreignTable,
    required this.originKey,
    required this.foreignKey,
    super.schema,
  });

  CmsSupabaseAssociationTable get reversed {
    return CmsSupabaseAssociationTable(
      name,
      originTable: foreignTable,
      foreignTable: originTable,
      originKey: foreignKey,
      foreignKey: originKey,
      schema: schema,
    );
  }
}
