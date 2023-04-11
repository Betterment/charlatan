import 'dart:typed_data';

import 'package:charlatan/charlatan.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('CharlatanHttpClientAdapter', () {
    late Dio client;
    late Charlatan charlatan;

    setUp(() {
      charlatan = Charlatan()..silenceErrors();
      client = Dio()..httpClientAdapter = charlatan.toFakeHttpClientAdapter();
    });

    test('it matches a url without templated segments', () async {
      charlatan.whenGet(
        '/user',
        charlatanResponse(statusCode: 200, body: {'name': 'frodo'}),
      );

      final result = await client.get<Object?>('/user');
      expect(result.data, {'name': 'frodo'});
    });

    test('it matches a url with templated segments', () async {
      charlatan.whenGet(
        '/users/{id}',
        charlatanResponse(statusCode: 200, body: {'name': 'frodo'}),
      );

      final result = await client.get<Object?>('/users/12');
      expect(result.data, {'name': 'frodo'});
    });

    test('it matches the longest matching url with templated segments',
        () async {
      charlatan
        ..whenGet('/users/{id}', charlatanResponse(body: {'name': 'frodo'}))
        ..whenGet('/users/{id}/profile', charlatanResponse(body: {'age': 12}));

      final result = await client.get<Object?>('/users/12/profile');
      expect(result.data, {'age': 12});
    });

    test('it disambiguates matches by http method', () async {
      charlatan
        ..whenGet('/users', charlatanResponse(body: {'name': 'frodo'}))
        ..whenPost('/users', charlatanResponse(body: {'name': 'sam'}))
        ..whenPut('/users', charlatanResponse(body: {'name': 'gandalf'}))
        ..whenDelete('/users', charlatanResponse(body: {'name': 'bilbo'}));

      final getResult = await client.get<Object?>('/users');
      expect(getResult.data, {'name': 'frodo'});

      final postResult = await client.post<Object?>('/users');
      expect(postResult.data, {'name': 'sam'});

      final putResult = await client.put<Object?>('/users');
      expect(putResult.data, {'name': 'gandalf'});

      final deleteResult = await client.delete<Object?>('/users');
      expect(deleteResult.data, {'name': 'bilbo'});
    });

    test('it overrides existing definitions for the same method and url',
        () async {
      charlatan
        ..whenGet('/users', charlatanResponse(body: {'name': 'frodo'})) //
        ..whenGet('/users', charlatanResponse(body: {'name': 'bilbo'}));

      final getResult = await client.get<Object?>('/users');
      expect(getResult.data, {'name': 'bilbo'});
    });

    test('it returns a helpful error message when no match is found', () async {
      charlatan
        ..whenGet('/users', charlatanResponse(body: {'name': 'frodo'}))
        ..whenPost('/users', charlatanResponse(body: {'name': 'sam'}))
        ..whenPut('/users', charlatanResponse(body: {'name': 'gandalf'}))
        ..whenDelete('/users', charlatanResponse(body: {'name': 'bilbo'}));

      expect(
        () async => client.get<Object?>('/blahhhh'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('''
Unable to find matching fake http response definition for:

GET /blahhhh

Did you configure it?

The fake http response definitions configured were:
GET /users
POST /users
PUT /users
DELETE /users
'''),
          ),
        ),
      );
    });

    test('it supports query strings', () async {
      charlatan.whenGet(
          '/users{?foo}', charlatanResponse(body: {'name': 'frodo'}));

      final result = await client.get<Object?>('/users?foo=bar');
      expect(result.data, {'name': 'frodo'});
    });

    test('it supports bytes response bodies', () async {
      charlatan.whenGet('/user.png', charlatanResponse(body: Uint8List(1)));

      final result = await client.get<Object?>(
        '/user.png',
        options: Options(responseType: ResponseType.bytes),
      );
      expect(result.data, Uint8List(1));
    });

    test('it supports async response body builders', () async {
      charlatan.whenGet(
        '/user',
        (_) async => Future.delayed(Duration.zero,
            () => CharlatanHttpResponse(body: {'name': 'frodo'})),
      );

      final result = await client.get<Object?>('/user');
      expect(result.data, {'name': 'frodo'});
    });

    test('it supports returning a CharlatanHttpResponse', () async {
      charlatan.whenPost('/user', (request) {
        return CharlatanHttpResponse(
          statusCode: 201,
          body: {'name': 'frodo'},
          headers: {'x-cool-header': 'cool-value'},
        );
      });

      final result = await client.post<Object?>('/user');
      expect(result.statusCode, 201);
      expect(result.data, {'name': 'frodo'});
      expect(
        result.headers.map,
        {
          'content-type': ['application/json'],
          'x-cool-header': ['cool-value'],
        },
      );
    });

    group('whenMatch', () {
      test('it returns a 200 status by default', () async {
        charlatan.whenMatch(
          (request) => request.path == '/user',
          charlatanResponse(),
        );

        final result = await client.get<Object?>('/user');
        expect(result.statusCode, 200);
      });

      test('it returns the provided status', () async {
        charlatan.whenMatch(
          (request) => request.path == '/user',
          charlatanResponse(statusCode: 404),
        );

        expect(
          client.get<Object?>('/user'),
          throwsA(
            isA<DioError>().having(
              (e) => e.response?.statusCode,
              'is a 404',
              404,
            ),
          ),
        );
      });
    });

    group('whenGet', () {
      test('it returns a 200 status by default', () async {
        charlatan.whenGet('/user', charlatanResponse());

        final result = await client.get<Object?>('/user');
        expect(result.statusCode, 200);
      });

      test('it returns the provided status', () async {
        charlatan.whenGet('/user', charlatanResponse(statusCode: 404));

        expect(
          client.get<Object?>('/user'),
          throwsA(
            isA<DioError>().having(
              (e) => e.response?.statusCode,
              'is a 404',
              404,
            ),
          ),
        );
      });
    });

    group('whenPost', () {
      test('it returns a 200 status by default', () async {
        charlatan.whenPost('/user', charlatanResponse());

        final result = await client.post<Object?>('/user');
        expect(result.statusCode, 200);
      });

      test('it returns the provided status', () async {
        charlatan.whenPost('/user', charlatanResponse(statusCode: 404));

        expect(
          client.post<Object?>('/user'),
          throwsA(
            isA<DioError>().having(
              (e) => e.response?.statusCode,
              'is a 404',
              404,
            ),
          ),
        );
      });
    });

    group('whenPut', () {
      test('it returns a 200 status by default', () async {
        charlatan.whenPut('/user', charlatanResponse());

        final result = await client.put<Object?>('/user');
        expect(result.statusCode, 200);
      });

      test('it returns the provided status', () async {
        charlatan.whenPut('/user', charlatanResponse(statusCode: 404));

        expect(
          client.put<Object?>('/user'),
          throwsA(
            isA<DioError>().having(
              (e) => e.response?.statusCode,
              'is a 404',
              404,
            ),
          ),
        );
      });
    });

    group('whenDelete', () {
      test('it returns a 200 status by default', () async {
        charlatan.whenDelete('/user', charlatanResponse());

        final result = await client.delete<Object?>('/user');
        expect(result.statusCode, 200);
      });

      test('it returns the provided status', () async {
        charlatan.whenDelete('/user', charlatanResponse(statusCode: 404));

        expect(
          client.delete<Object?>('/user'),
          throwsA(
            isA<DioError>().having(
              (e) => e.response?.statusCode,
              'is a 404',
              404,
            ),
          ),
        );
      });
    });
  });
}
