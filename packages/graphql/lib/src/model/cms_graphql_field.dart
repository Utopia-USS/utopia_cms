class CmsGraphQLField {
  final String key;
  final CmsGraphQLFields? fields;

  const CmsGraphQLField(this.key, [this.fields]);

  static const typename = CmsGraphQLField('__typename');
}

typedef CmsGraphQLFields = Set<CmsGraphQLField>;
