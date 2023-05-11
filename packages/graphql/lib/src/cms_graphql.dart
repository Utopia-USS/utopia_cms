import 'package:graphql/client.dart';
import 'package:utopia_cms_graphql/src/service/cms_graphql_client_service.dart';
import 'package:utopia_cms_graphql/src/service/cms_graphql_service.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsGraphQL {
  const CmsGraphQL._();

  static const service = CmsGraphQLService();
  static const clientService = CmsGraphQLClientService();

  static GraphQLClient createClient(
    String uri, {
    String header = 'Authorization',
    Future<String?> Function()? tokenProvider,
    Reporter? reporter,
  }) =>
      clientService.createClient(uri, header: header, tokenProvider: tokenProvider, reporter: reporter);
}
