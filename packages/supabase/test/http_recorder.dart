import 'dart:convert';

import 'package:http/http.dart' as http;

/// Records every request postgrest builds and answers it with [body].
class HttpRecorder extends http.BaseClient {
  final requests = <http.BaseRequest>[];

  String body = '[]';

  http.BaseRequest? get last => requests.isEmpty ? null : requests.last;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}
