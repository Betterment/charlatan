import 'package:charlatan/src/charlatan_http_response_definition.dart';

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
  final Map<String, List<CharlatanHttpResponseDefinition>> _mapping = {};

  /// {@nodoc}
  bool shouldLogErrors = true;

  /// {@nodoc}
  void silenceErrors() => shouldLogErrors = false;

  /// Adds a fake response definition for a GET request to the provided
  /// [pathOrTemplate] with the corresponding [statusCode].
  void whenGet(
    String pathOrTemplate,
    CharlatanResponseBodyBuilder responseBodyBuilder, {
    int statusCode = 200,
  }) {
    _addDefintionForHttpMethod(
      httpMethod: 'get',
      pathOrTemplate: pathOrTemplate,
      statusCode: statusCode,
      responseBodyBuilder: responseBodyBuilder,
    );
  }

  /// Adds a fake response definition for a POST request to the provided
  /// [pathOrTemplate] with the corresponding [statusCode].
  void whenPost(
    String pathOrTemplate,
    CharlatanResponseBodyBuilder responseBodyBuilder, {
    int statusCode = 200,
  }) {
    _addDefintionForHttpMethod(
      httpMethod: 'post',
      pathOrTemplate: pathOrTemplate,
      statusCode: statusCode,
      responseBodyBuilder: responseBodyBuilder,
    );
  }

  /// Adds a fake response definition for a PUT request to the provided
  /// [pathOrTemplate] with the corresponding [statusCode].
  void whenPut(
    String pathOrTemplate,
    CharlatanResponseBodyBuilder responseBodyBuilder, {
    int statusCode = 200,
  }) {
    _addDefintionForHttpMethod(
      httpMethod: 'put',
      pathOrTemplate: pathOrTemplate,
      statusCode: statusCode,
      responseBodyBuilder: responseBodyBuilder,
    );
  }

  /// Adds a fake response definition for a DELETE request to the provided
  /// [pathOrTemplate] with the corresponding [statusCode].
  void whenDelete(
    String pathOrTemplate,
    CharlatanResponseBodyBuilder responseBodyBuilder, {
    int statusCode = 200,
  }) {
    _addDefintionForHttpMethod(
      httpMethod: 'delete',
      pathOrTemplate: pathOrTemplate,
      statusCode: statusCode,
      responseBodyBuilder: responseBodyBuilder,
    );
  }

  void _addDefintionForHttpMethod({
    required String httpMethod,
    required String pathOrTemplate,
    required int statusCode,
    required CharlatanResponseBodyBuilder responseBodyBuilder,
  }) {
    final definition = CharlatanHttpResponseDefinition(
      statusCode: statusCode,
      httpMethod: httpMethod,
      pathOrTemplate: pathOrTemplate,
      responseBodyBuilder: responseBodyBuilder,
    );

    getDefinitionsForHttpMethod(httpMethod)
      // we're removing exact matches for house-keeping purposes. technically,
      // it's totally fine to just insert at the beginning and not remove an
      // existing exact match, but it feels weird to have a data structure that
      // contains responses with duplicate pathOrTemplate knowing that only one
      // of them can ever be matched.
      ..removeWhere((possibleDefinition) =>
          possibleDefinition.pathOrTemplate == pathOrTemplate)
      // this is the important part. we want to always insert new entries at the
      // beginning of the list because that matches the expecations of the user
      // in terms of how overriding a fake response would work.
      ..insert(0, definition);
  }

  /// Returns all the matching [CharlatanHttpResponseDefinition]s for the provided
  /// [httpMethod] or an empty list.
  List<CharlatanHttpResponseDefinition> getDefinitionsForHttpMethod(
    String httpMethod,
  ) {
    return _mapping.putIfAbsent(httpMethod, () => []);
  }

  /// Prints a human-readable list of all the registered fake responses.
  String toPrettyPrintedString() {
    if (_mapping.entries.isEmpty) {
      return 'No responses defined.';
    }

    return _mapping.entries
        .expand<String>(
          (entry) => entry.value.map(
            (definition) =>
                '${definition.httpMethod.toUpperCase()} ${definition.pathOrTemplate}',
          ),
        )
        .join('\n');
  }
}
