import 'dart:convert';

import 'package:charlatan/charlatan.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  late Dio client;
  late Charlatan charlatan;

  setUp(() {
    charlatan = Charlatan();
    client = Dio()..httpClientAdapter = charlatan.toFakeHttpClientAdapter();
  });

  test('example', () async {
    // Create a plain fake response
    charlatan.whenGet('/user', (_) => {'name': 'frodo'});

    final plain = await client.get<Object?>('/user');
    expect(plain.data, {'name': 'frodo'});

    // Use a URI template and use the path parameters in the response
    charlatan.whenGet(
      '/user/{id}',
      (request) => {
        'id': request.pathParameters['id'],
        'name': 'frodo',
      },
    );

    final withPathParams = await client.get<Object?>('/user/12');
    expect(withPathParams.data, {'id': '12', 'name': 'frodo'});

    // Use a URI template and use the path parameters in the response
    charlatan.whenGet(
      '/posts',
      (_) => null,
      statusCode: 204,
    );

    final emptyBody = await client.get<Object?>('/posts');
    expect(emptyBody.data, '');
    expect(emptyBody.statusCode, 204);

    // Handle a POST and then a GET with shared state
    final posts = <Object>[];
    charlatan
      ..whenPost(
        '/posts',
        (request) {
          final params = json.decode(request.requestOptions.data as String)
              as Map<String, Object?>;
          posts.add({'name': params['name']});
          return null;
        },
        statusCode: 204,
      )
      ..whenGet(
        '/posts',
        (_) => {'posts': posts},
      );

    final beforeCreatePost = await client.get<Object?>('/posts');
    expect(beforeCreatePost.data, {'posts': <Object?>[]});

    final createPost =
        await client.post<Object?>('/posts', data: {'name': 'bilbo'});
    expect(createPost.statusCode, 204);

    final afterCreatePost = await client.get<Object?>('/posts');
    expect(afterCreatePost.data, {
      'posts': [
        {'name': 'bilbo'},
      ]
    });
  });
}
