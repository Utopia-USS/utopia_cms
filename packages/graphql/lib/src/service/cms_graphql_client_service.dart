import 'dart:convert';

import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:utopia_reporter/utopia_reporter.dart';

class CmsGraphQLClientService {
  const CmsGraphQLClientService();

  GraphQLClient createClient(
    String uri, {
    String header = 'Authorization',
    Future<String?> Function()? tokenProvider,
    Reporter? reporter,
  }) {
    final link = Link.from([
      if(reporter != null) _ReporterLink(reporter),
      if (tokenProvider != null) AuthLink(headerKey: header, getToken: tokenProvider),
      HttpLink(uri),
    ]);
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(query: Policies(fetch: FetchPolicy.noCache)),
    );
  }
}

class _ReporterLink extends Link {
  static const _json = JsonEncoder.withIndent('  ');

  final Reporter reporter;

  const _ReporterLink(this.reporter);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    reporter.info([
      "GraphQL request:",
      printNode(request.operation.document),
      if (request.variables.isNotEmpty) "Variables: ${_json.convert(request.variables)}",
    ].join("\n"));
    await for (final response in forward!(request)) {
      final method = response.errors != null ? reporter.warning : reporter.info;
      method([
        "GraphQL response:",
        if (response.data != null) _json.convert(response.data!),
        if (response.errors != null) "Errors: ${response.errors!.map((it) => it.toString()).join("\n")}",
      ].join("\n"));
      yield response;
    }
  }
}
