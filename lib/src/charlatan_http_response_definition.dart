import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uri/uri.dart';

/// {@template charlatan_http_response_builder}
/// A type representing a function to convert an http request into a response.
///
/// The return value may be any json encodable object, a [CharlatanHttpResponse],
/// or null.
///
/// Typically you will want to return a json response of Map<String, Object?>
/// which will be automatically serialized and returned with a 200 status code.
///
/// If you want to customize the headers or the status code of the response, you
/// can return an instance of [CharlatanHttpResponse].
/// {@endtemplate}
typedef CharlatanResponseBuilder = FutureOr<Object?> Function(
  /// The request including path params, body, headers, options, etc
  CharlatanHttpRequest request,
);

/// {@template charlatan_http_response_definition}
/// The definition of a fake HTTP response and the pattern of requests it
/// matches.
/// {@endtemplate}
class CharlatanHttpResponseDefinition {
  /// The HTTP status code for the response.
  final int statusCode;

  /// The HTTP method for request matching.
  final String httpMethod;

  /// The URI pattern for request matching.
  /// e.g. '/users' or '/users/{id}'
  final String pathOrTemplate;

  /// The callback that produces the response.
  final CharlatanResponseBuilder responseBuilder;

  /// {@macro charlatan_http_response_definition}
  CharlatanHttpResponseDefinition({
    required this.statusCode,
    required this.httpMethod,
    required this.pathOrTemplate,
    required this.responseBuilder,
  });

  /// Returns a [CharlatanHttpResponseMatch] if this [CharlatanHttpResponseDefinition] is
  /// a match for the provided path
  CharlatanHttpResponseMatch? computeMatch(String path) {
    final uri = Uri.parse(path);
    final template = UriTemplate(pathOrTemplate);
    final parser = UriParser(template);

    final match = parser.matches(uri);
    if (!match) {
      return null;
    }

    // by reversing the parse we're confirming that we match the right pattern
    // e.g. /goals/{id} will also be a match for /goals/{id}/foo
    // but we want to use a /goals/{id}/foo pattern if one exists
    final vars = parser.parse(uri);
    final reverseMatch = template.expand(vars) == uri.toString();
    if (!reverseMatch) {
      return null;
    }

    return CharlatanHttpResponseMatch(
      definition: this,
      path: path,
      pathParameters: vars,
    );
  }

  /// Builds a [CharlatanHttpResponse] from the [responseBuilder] given the
  /// [request].
  Future<CharlatanHttpResponse> buildResponse(
    CharlatanHttpRequest request,
  ) async {
    final result = await responseBuilder(request);

    if (result is CharlatanHttpResponse) {
      return result;
    }

    return CharlatanHttpResponse(
      body: result,
      statusCode: statusCode,
    );
  }
}

/// {@template charlatan_http_response_match}
/// A type representing a match of a path string to a [CharlatanHttpResponseDefinition].
///
/// This match contains any parameters extracted from the path's URI template.
/// {@endtemplate}
class CharlatanHttpResponseMatch {
  /// The path of the request
  final String path;

  /// The definition that matched the [path]
  final CharlatanHttpResponseDefinition definition;

  /// The matching parameters extracted from the [path]
  final Map<String, String> pathParameters;

  /// {@macro charlatan_http_response_match}
  CharlatanHttpResponseMatch({
    required this.path,
    required this.definition,
    required this.pathParameters,
  });
}

/// {@template charlatan_http_request}
/// A type representing a HTTP request and any extract path parameters.
/// {@endtemplate}
class CharlatanHttpRequest {
  /// The matching parameters extracted from the path of this request
  final Map<String, String> pathParameters;

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
    required this.pathParameters,
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
