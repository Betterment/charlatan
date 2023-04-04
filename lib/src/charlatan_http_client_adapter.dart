import 'dart:convert';
import 'dart:typed_data';

import 'package:charlatan/src/charlatan.dart';
import 'package:charlatan/src/charlatan_response_definition.dart';
import 'package:dio/dio.dart';

/// {@template charlatan_http_client_adapter}
/// An implementation of dio's [HttpClientAdapter] that returns fake HTTP
/// responses based on the configuration of a [Charlatan] instance.
///
/// ```dart
/// final charlatan = Charlatan();
/// Dio()..httpClientAdapter = CharlatanHttpClientAdapter(charlatan);
/// ```
/// {@endtemplate}
class CharlatanHttpClientAdapter implements HttpClientAdapter {
  /// Fake HTTP definitions for this adapter
  final Charlatan charlatan;

  /// {@macro charlatan_http_client_adapter}
  const CharlatanHttpClientAdapter(this.charlatan);

  /// Returns a [ResponseBody] matching the request if one exists in [charlatan].
  /// If no response matches, throws [UnimplementedError].
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    final path = options.path;
    final method = options.method.toLowerCase();
    final request = CharlatanHttpRequest(
      requestOptions: options,
    );
    final match = charlatan.findMatch(request);

    if (match != null) {
      return _buildResponse(request, match);
    }

    final errorMessage = '''

Unable to find matching fake http response definition for:

${method.toUpperCase()} $path

Did you configure it?

The fake http response definitions configured were:
${charlatan.toPrettyPrintedString()}

''';
    if (charlatan.shouldLogErrors) {
      // ignore: avoid_print
      print(errorMessage);
    }

    throw UnimplementedError(errorMessage);
  }

  /// {@nodoc}
  @override
  void close({bool force = false}) {}
}

Future<ResponseBody> _buildResponse(
  CharlatanHttpRequest request,
  CharlatanResponseDefinition definition,
) async {
  final response = await definition.buildResponse(request);
  final responseType = request.requestOptions.responseType;

  if (responseType == ResponseType.json) {
    return ResponseBody.fromString(
      // Dio currently converts null response bodies to empty string, so
      // we preserve that behavior here for correctness :shrug:
      response.body == null ? '' : json.encode(response.body),
      response.statusCode,
      headers: {
        'content-type': ['application/json'],
        for (final header in response.headers.entries)
          header.key: [header.value],
      },
    );
  } else if (responseType == ResponseType.bytes) {
    return ResponseBody.fromBytes(
      response.body as Uint8List,
      response.statusCode,
      headers: {
        for (final header in response.headers.entries)
          header.key: [header.value],
      },
    );
  } else {
    throw UnimplementedError('Unsupported response type: $responseType');
  }
}
