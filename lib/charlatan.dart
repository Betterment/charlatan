library charlatan;

import 'src/charlatan.dart';
import 'src/charlatan_http_client_adapter.dart';

export 'src/charlatan.dart';
export 'src/charlatan_http_client_adapter.dart';
export 'src/charlatan_response_definition.dart'
    show
        CharlatanHttpRequest,
        CharlatanHttpResponse,
        CharlatanResponseBuilder,
        CharlatanRequestMatcher,
        charlatanResponse,
        requestMatchesAll,
        requestMatchesHttpMethod,
        requestMatchesPathOrTemplate;

/// Utilities to make it easier to work with [Charlatan].
extension CharlatanExtensions on Charlatan {
  /// Builds a [CharlatanHttpClientAdapter] for a [Charlatan] instance.
  CharlatanHttpClientAdapter toFakeHttpClientAdapter() =>
      CharlatanHttpClientAdapter(this);
}
