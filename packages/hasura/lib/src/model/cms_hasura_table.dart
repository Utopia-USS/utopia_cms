class CmsHasuraTable {
  final String name;

  const CmsHasuraTable(this.name);
}

// TODO consider including the fields
class CmsHasuraDataTable extends CmsHasuraTable {
  final String idKey;

  const CmsHasuraDataTable(super.name, {this.idKey = 'id'});
}

class CmsHasuraAssociationTable extends CmsHasuraTable {
  final CmsHasuraDataTable originTable, foreignTable;
  final String originKey, foreignKey;

  const CmsHasuraAssociationTable(
    super.name, {
    required this.originTable,
    required this.foreignTable,
    required this.originKey,
    required this.foreignKey,
  });

  CmsHasuraAssociationTable get reversed {
    return CmsHasuraAssociationTable(
      name,
      originTable: foreignTable,
      foreignTable: originTable,
      originKey: foreignKey,
      foreignKey: originKey,
    );
  }
}
