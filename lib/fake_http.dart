library fake_http;

import 'package:fake_http/src/fake_http.dart';
import 'package:fake_http/src/fake_http_client_adapter.dart';

export 'src/fake_http.dart';
export 'src/fake_http_client_adapter.dart';

/// Utilities to make it easier to work with [FakeHttp].
extension FakeHttpExtensions on FakeHttp {
  /// Builds a [FakeHttpClientAdapter] for a [FakeHttp] instance.
  FakeHttpClientAdapter toFakeHttpClientAdapter() =>
      FakeHttpClientAdapter(this);
}
