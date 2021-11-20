import 'package:dio/dio.dart';
import 'package:uri/uri.dart';

/// A type representing a function to convert an http request into a response body.
///
/// The response body may be any valid object or null. Typically you will want to
/// return a json response of Map<String, Object?>.
typedef ResponseBodyBuilder = Object? Function(FakeHttpRequest request);

/// {@template fake_http_response_defintion}
/// The definition of a fake HTTP response and the pattern of requests it
/// matches.
/// {@endtemplate}
class FakeHttpResponseDefinition {
  /// The HTTP status code for the response.
  final int statusCode;

  /// The HTTP method for request matching.
  final String httpMethod;

  /// The URI pattern for request matching.
  /// e.g. '/users' or '/users/{id}'
  final String pathOrTemplate;

  /// The callback that produces the response body for this fake response.
  final ResponseBodyBuilder responseBodyBuilder;

  /// {@macro fake_http_response_definition}
  FakeHttpResponseDefinition({
    required this.statusCode,
    required this.httpMethod,
    required this.pathOrTemplate,
    required this.responseBodyBuilder,
  });

  /// Returns a [FakeHttpResponseMatch] if this [FakeHttpResponseDefinition] is
  /// a match for the provided path
  FakeHttpResponseMatch? computeMatch(String path) {
    final uri = Uri.parse(path);
    final template = UriTemplate(pathOrTemplate);
    final parser = UriParser(template);

    // by reversing the parse we're confirming that we match the right pattern
    // e.g. /goals/{id} will be a match for /goals/{id}/foo
    // and we want to use a /goals/{id}/foo pattern if one exists
    final match = parser.matches(uri);
    if (match) {
      final vars = parser.parse(uri);
      final reverseMatch = template.expand(vars) == uri.toString();
      if (reverseMatch) {
        return FakeHttpResponseMatch(
          definition: this,
          path: path,
          pathParameters: vars,
        );
      }
    }

    return null;
  }
}

/// {@template fake_http_response_match}
/// A type representing a match of a path string to a [FakeHttpResponseDefinition].
///
/// This match contains any parameters extracted from the path's URI template.
/// {@endtemplate}
class FakeHttpResponseMatch {
  /// The path of the request
  final String path;

  /// The definition that matched the [path]
  final FakeHttpResponseDefinition definition;

  /// The matching parameters extracted from the [path]
  final Map<String, String> pathParameters;

  /// {@macro fake_http_response_match}
  FakeHttpResponseMatch({
    required this.path,
    required this.definition,
    required this.pathParameters,
  });
}

/// {@template fake_http_request}
/// A type representing a match of a path string to a [FakeHttpResponseDefinition].
///
/// This match contains any parameters extracted from the path's URI template.
/// {@endtemplate}
class FakeHttpRequest {
  /// The matching parameters extracted from the path of this request
  final Map<String, String> pathParameters;

  /// The request headers, body, and options
  final RequestOptions requestOptions;

  /// {@macro fake_http_request}
  FakeHttpRequest({
    required this.pathParameters,
    required this.requestOptions,
  });
}
