import 'package:charlatan/src/charlatan_response_definition.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('CharlatanHttpRequest', () {
    test('it proxies the path from the request options', () {
      final path = '/users';
      final requestOptions = RequestOptions(path: path);

      final subject = CharlatanHttpRequest(
        requestOptions: requestOptions,
      );

      expect(subject.path, path);
    });

    test('it proxies the method from the request options', () {
      final method = 'POST';
      final requestOptions = RequestOptions(
        path: '/users',
        method: method,
      );

      final subject = CharlatanHttpRequest(
        requestOptions: requestOptions,
      );

      expect(subject.method, method);
    });

    test('it proxies the body from the request options', () {
      final body = {'name': 'frodo'};
      final requestOptions = RequestOptions(path: '/users', data: body);

      final subject = CharlatanHttpRequest(
        requestOptions: requestOptions,
      );

      expect(subject.body, body);
    });

    test('it proxies the headers from the request options', () {
      final headers = {'x-request-id': 'boo'};
      final requestOptions = RequestOptions(path: '/users', headers: headers);

      final subject = CharlatanHttpRequest(
        requestOptions: requestOptions,
      );

      expect(subject.headers, {...headers});
    });

    test('it proxies the query parameters from the request options', () {
      final queryParameters = {'q': 'boo'};
      final requestOptions = RequestOptions(
        path: '/users',
        queryParameters: queryParameters,
      );

      final subject = CharlatanHttpRequest(
        requestOptions: requestOptions,
      );

      expect(subject.queryParameters, queryParameters);
    });
  });
}
