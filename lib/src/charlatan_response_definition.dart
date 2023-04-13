import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uri/uri.dart';

/// {@template charlatan_request_matcher}
/// A type representing a function to detect if an http request matches a predicate.
///
/// The return value is true if a match or false if no match.
/// {@endtemplate}
typedef CharlatanRequestMatcher = bool Function(
  /// The request including path params, body, headers, options, etc
  CharlatanHttpRequest request,
);

/// {@template charlatan_response_builder}
/// A type representing a function to convert an http request into a response.
///
/// The return value is a [CharlatanHttpResponse].
/// {@endtemplate}
typedef CharlatanResponseBuilder = FutureOr<CharlatanHttpResponse> Function(
  /// The request including path params, body, headers, options, etc
  CharlatanHttpRequest request,
);

/// {@template charlatan_response}
/// A function to build a [CharlatanResponseBuilder]. The [statusCode] defaults
/// to 200, the [body] defaults to null, and the [headers] defaults to empty.
/// {@endtemplate}
CharlatanResponseBuilder charlatanResponse({
  int statusCode = 200,
  Object? body,
  Map<String, String> headers = const {},
}) =>
    (request) => CharlatanHttpResponse(
          statusCode: statusCode,
          body: body,
          headers: headers,
        );

/// {@template charlatan_matches_all}
/// A function to build a [CharlatanRequestMatcher] that matches if all of the
/// provided [CharlatanRequestMatcher]s match.
/// {@endtemplate}
CharlatanRequestMatcher requestMatchesAll(
  List<CharlatanRequestMatcher> matchers,
) =>
    (request) => matchers.every((matcher) => matcher(request));

/// {@template charlatan_matches_http_method}
/// A function to build a [CharlatanRequestMatcher] that matches if the http
/// method of the request matches the provided [method].
/// {@endtemplate}
CharlatanRequestMatcher requestMatchesHttpMethod(String method) =>
    (request) => request.method.toLowerCase() == method.toLowerCase();

/// {@template charlatan_matches_path_or_template}
/// A function to build a [CharlatanRequestMatcher] that matches if the request
/// path matches the provided [pathOrTemplate].
/// {@endtemplate}
CharlatanRequestMatcher requestMatchesPathOrTemplate(String pathOrTemplate) =>
    (request) {
      final uri = Uri.parse(request.path);
      final template = UriTemplate(pathOrTemplate);
      final parser = UriParser(template);

      final match = parser.matches(uri);
      if (!match) {
        return false;
      }

      // by reversing the parse we're confirming that we match the right pattern
      // e.g. /goals/{id} will also be a match for /goals/{id}/foo
      // but we want to use a /goals/{id}/foo pattern if one exists
      final vars = parser.parse(uri);
      final reverseMatch = template.expand(vars) == uri.toString();
      if (!reverseMatch) {
        return false;
      }

      return true;
    };

/// {@template charlatan_response_definition}
/// A type representing a pairing of a [CharlatanRequestMatcher] and a
/// [CharlatanResponseBuilder].
/// {@endtemplate}
class CharlatanResponseDefinition {
  /// The filter that determines if a request matches.
  final CharlatanRequestMatcher requestMatcher;

  /// The callback that produces the response.
  final CharlatanResponseBuilder responseBuilder;

  /// A description of the response definition, e.g. GET /users/123
  final String description;

  /// {@macro charlatan_http_response_definition}
  CharlatanResponseDefinition({
    required this.requestMatcher,
    required this.responseBuilder,
    required this.description,
  });

  /// Returns true if the [request] matches the [requestMatcher] of this definition.
  bool matches(CharlatanHttpRequest request) => requestMatcher(request);

  /// Builds a [CharlatanHttpResponse] from the [responseBuilder] given the
  /// [request].
  Future<CharlatanHttpResponse> buildResponse(
    CharlatanHttpRequest request,
  ) async {
    final responseOrFuture = responseBuilder(request);
    if (responseOrFuture is Future<CharlatanHttpResponse>) {
      return await responseOrFuture;
    }
    return responseOrFuture;
  }
}

/// {@template charlatan_http_request}
/// A type representing a HTTP request.
/// {@endtemplate}
class CharlatanHttpRequest {
  /// The underlying dio request headers, body, and other options
  final RequestOptions requestOptions;

  /// The HTTP method
  String get method => requestOptions.method;

  /// The request path
  String get path => requestOptions.path;

  /// The request query parameters
  Map<String, Object?> get queryParameters => requestOptions.queryParameters;

  /// The request headers
  Map<String, Object?> get headers => requestOptions.headers;

  /// The request body
  Object? get body => requestOptions.data;

  /// {@macro charlatan_http_request}
  CharlatanHttpRequest({
    required this.requestOptions,
  });
}

/// {@template charlatan_http_response}
/// A type representing a HTTP response.
/// {@endtemplate}
class CharlatanHttpResponse {
  /// The body of the HTTP response
  final Object? body;

  /// The status code of the HTTP response, defaults to 200
  final int statusCode;

  /// The headers for the HTTP response, defaults to empty
  final Map<String, String> headers;

  /// {@macro charlatan_http_response}
  CharlatanHttpResponse({
    this.body,
    this.statusCode = 200,
    this.headers = const {},
  });
}
