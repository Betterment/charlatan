import 'package:dio/dio.dart';
import 'package:uri/uri.dart';

/// A type representing a function to convert an http request into a response body.
///
/// The response body may be any valid object or null. Typically you will want to
/// return a json response of Map<String, Object?>.
typedef ResponseBodyBuilder = Object? Function(RequestOptions request);

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

  /// Returns true if this [FakeHttpResponseDefinition] is a match for the
  /// provided path
  bool matches(String path) {
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
      return reverseMatch;
    }

    return false;
  }
}
