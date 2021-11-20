import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_http/src/fake_http.dart';
import 'package:fake_http/src/fake_http_response_definition.dart';

/// {@template fake_http_client_adapter}
/// An implementation of dio's [HttpClientAdapter] that returns fake HTTP
/// responses based on the configuration of a [FakeHttp] instance.
///
/// ```dart
/// final fakeHttp = FakeHttp();
/// Dio()..httpClientAdapter = FakeHttpClientAdapter(fakeHttp);
/// ```
/// {@endtemplate}
class FakeHttpClientAdapter implements HttpClientAdapter {
  /// Fake HTTP definitions for this adapter
  final FakeHttp fakeHttp;

  /// {@macro fake_http_client_adapter}
  const FakeHttpClientAdapter(this.fakeHttp);

  /// Returns a [ResponseBody] matching the request if one exists in [fakeHttp].
  /// If no response matches, throws [UnimplementedError].
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    final path = options.path;
    final method = options.method.toLowerCase();
    final possibleDefinitions = fakeHttp.getDefinitionsForHttpMethod(method);
    final match = _findMatchForPath(possibleDefinitions, path);

    if (match != null) {
      final definition = match.definition;
      final request = FakeHttpRequest(
        pathParameters: match.pathParameters,
        requestOptions: options,
      );
      final responseBody = definition.responseBodyBuilder(request);
      final responseType = options.responseType;

      if (responseType == ResponseType.json) {
        return ResponseBody.fromString(
          responseBody == null ? '' : json.encode(responseBody),
          definition.statusCode,
          headers: {
            'content-type': ['application/json'],
          },
        );
      } else if (responseType == ResponseType.bytes) {
        return ResponseBody.fromBytes(
          responseBody! as Uint8List,
          definition.statusCode,
        );
      } else {
        throw UnimplementedError('Unsupported response type: $responseType');
      }
    }

    final errorMessage = '''

Unable to find matching fake http response definition for:

${method.toUpperCase()} $path

Did you configure it?

The fake http response definitions configured were:
${fakeHttp.toPrettyPrintedString()}

''';
    if (fakeHttp.shouldLogErrors) {
      // ignore: avoid_print
      print(errorMessage);
    }

    throw UnimplementedError(errorMessage);
  }

  /// {@nodoc}
  @override
  void close({bool force = false}) {}

  FakeHttpResponseMatch? _findMatchForPath(
    List<FakeHttpResponseDefinition> possibleDefinitions,
    String path,
  ) {
    for (final possibleDefinition in possibleDefinitions) {
      final match = possibleDefinition.computeMatch(path);
      if (match != null) {
        return match;
      }
    }

    return null;
  }
}
