import 'package:charlatan/src/charlatan_response_definition.dart';
import 'package:collection/collection.dart';

/// {@template charlatan}
/// A class for building a collection of fake http responses to power a fake
/// http client.
///
/// ```dart
/// final charlatan = Charlatan()
///   ..whenGet('/hero', (_) => <String, Object?>{'name': 'Bilbo'})
///   ..whenGet('/sidekick', (_) => <String, Object?>{'name': 'Samwise'});
/// ```
/// {@endtemplate}
class Charlatan {
  // ignore: public_member_api_docs
  bool shouldLogErrors = true;

  // ignore: public_member_api_docs
  void silenceErrors() => shouldLogErrors = false;

  final List<CharlatanResponseDefinition> _matchers = [];

  /// Adds a fake response definition for a request that matches the provided
  /// [requestMatcher]. If the response is not a [CharlatanHttpResponse] then
  /// the [statusCode] will be used.
  ///
  /// [description] is used to describe the response for debugging; it defaults
  /// to 'Custom Matcher' but should be provided for clarity, e.g. 'GET /users/123?q=foo'
  void whenMatch(
    CharlatanRequestMatcher requestMatcher,
    CharlatanResponseBuilder responseBuilder, {
    String? description,
  }) {
    _matchers.insert(
      0,
      CharlatanResponseDefinition(
        description: description ?? 'Custom Matcher',
        requestMatcher: requestMatcher,
        responseBuilder: responseBuilder,
      ),
    );
  }

  /// Adds a fake response definition for a GET request to the provided
  /// [pathOrTemplate]. If the response is not a [CharlatanHttpResponse] then
  /// the [statusCode] will be used.
  void whenGet(
    String pathOrTemplate,
    CharlatanResponseBuilder responseBuilder,
  ) {
    _matchers.insert(
      0,
      CharlatanResponseDefinition(
        description: 'GET $pathOrTemplate',
        requestMatcher: requestMatchesAll([
          requestMatchesHttpMethod('get'),
          requestMatchesPathOrTemplate(pathOrTemplate),
        ]),
        responseBuilder: responseBuilder,
      ),
    );
  }

  /// Adds a fake response definition for a POST request to the provided
  /// [pathOrTemplate]. If the response is not a [CharlatanHttpResponse] then
  /// the [statusCode] will be used.
  void whenPost(
    String pathOrTemplate,
    CharlatanResponseBuilder responseBuilder,
  ) {
    _matchers.insert(
      0,
      CharlatanResponseDefinition(
        description: 'POST $pathOrTemplate',
        requestMatcher: requestMatchesAll([
          requestMatchesHttpMethod('post'),
          requestMatchesPathOrTemplate(pathOrTemplate),
        ]),
        responseBuilder: responseBuilder,
      ),
    );
  }

  /// Adds a fake response definition for a PUT request to the provided
  /// [pathOrTemplate]. If the response is not a [CharlatanHttpResponse] then
  /// the [statusCode] will be used.
  void whenPut(
    String pathOrTemplate,
    CharlatanResponseBuilder responseBuilder,
  ) {
    _matchers.insert(
      0,
      CharlatanResponseDefinition(
        description: 'PUT $pathOrTemplate',
        requestMatcher: requestMatchesAll([
          requestMatchesHttpMethod('put'),
          requestMatchesPathOrTemplate(pathOrTemplate),
        ]),
        responseBuilder: responseBuilder,
      ),
    );
  }

  /// Adds a fake response definition for a DELETE request to the provided
  /// [pathOrTemplate]. If the response is not a [CharlatanHttpResponse] then
  /// the [statusCode] will be used.
  void whenDelete(
    String pathOrTemplate,
    CharlatanResponseBuilder responseBuilder,
  ) {
    _matchers.insert(
      0,
      CharlatanResponseDefinition(
        description: 'DELETE $pathOrTemplate',
        requestMatcher: requestMatchesAll([
          requestMatchesHttpMethod('delete'),
          requestMatchesPathOrTemplate(pathOrTemplate),
        ]),
        responseBuilder: responseBuilder,
      ),
    );
  }

  /// Returns the first fake response definition that matches the provided [request].
  CharlatanResponseDefinition? findMatch(CharlatanHttpRequest request) {
    return _matchers.firstWhereOrNull((matcher) => matcher.matches(request));
  }

  /// Prints a human-readable list of all the registered fake responses.
  String toPrettyPrintedString() {
    if (_matchers.isEmpty) {
      return 'No definitions.';
    }

    // the reversed here is because we insert new matchers at the front of the
    // list, but we want to print them in the order they were added.
    return _matchers.reversed.map((def) => def.description).join('\n');
  }
}
