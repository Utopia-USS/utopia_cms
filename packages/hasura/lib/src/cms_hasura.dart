import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/src/delegate/cms_hasura_delegate.dart';
import 'package:utopia_cms_hasura/src/delegate/cms_hasura_to_many_delegate.dart';
import 'package:utopia_cms_hasura/src/model/cms_hasura_naming_convention.dart';
import 'package:utopia_cms_hasura/src/model/cms_hasura_table.dart';
import 'package:utopia_cms_hasura/src/service/cms_hasura_service.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsHasura {
  static const instance = CmsHasura();

  final CmsGraphQL graphQL;
  final CmsHasuraNamingConvention namingConvention;

  const CmsHasura({this.graphQL = CmsGraphQL.instance, this.namingConvention = CmsHasuraNamingConvention.pascal});

  CmsHasuraService get service => CmsHasuraService(graphQL.service, namingConvention: namingConvention);

  GraphQLClient createAdminClient(String uri, {required String secret, Reporter? reporter}) {
    return graphQL.createClient(
      uri,
      header: 'x-hasura-admin-secret',
      tokenProvider: () async => secret,
      reporter: reporter,
    );
  }

  CmsHasuraDelegate delegate({
    required GraphQLClient client,
    required CmsHasuraDataTable table,
    required CmsGraphQLFields fields,
    CmsFilterNotEquals? archivedFilter,
  }) =>
      CmsHasuraDelegate(service, client: client, table: table, fields: fields, archivedFilter: archivedFilter);

  CmsHasuraOneToManyDelegate oneToManyDelegate({
    required GraphQLClient client,
    required CmsHasuraDataTable originTable,
    required CmsHasuraDataTable foreignTable,
    required CmsGraphQLFields foreignFields,
    required String foreignKey,
    CmsFilterNotEquals? archivedFilter,
  }) {
    return CmsHasuraOneToManyDelegate(
      service,
      client: client,
      originTable: originTable,
      foreignTable: foreignTable,
      foreignFields: foreignFields,
      foreignKey: foreignKey,
      archivedFilter: archivedFilter,
    );
  }

  CmsHasuraManyToManyDelegate manyToManyDelegate({
    required GraphQLClient client,
    required CmsHasuraAssociationTable associationTable,
    required CmsGraphQLFields foreignFields,
    CmsFilterNotEquals? archivedFilter,
  }) {
    return CmsHasuraManyToManyDelegate(
      service,
      client: client,
      associationTable: associationTable,
      foreignFields: foreignFields,
      archivedFilter: archivedFilter,
    );
  }
}
