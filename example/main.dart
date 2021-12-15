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

  test('Create a plain fake response', () async {
    charlatan.whenGet('/user', (_) => {'name': 'frodo'});

    final plain = await client.get<Object?>('/user');
    expect(plain.data, {'name': 'frodo'});
  });

  test('Use a URI template and use the path parameters in the response',
      () async {
    charlatan.whenGet(
      '/user/{id}',
      (request) => {
        'id': request.pathParameters['id'],
        'name': 'frodo',
      },
    );

    final withPathParams = await client.get<Object?>('/user/12');
    expect(withPathParams.data, {'id': '12', 'name': 'frodo'});
  });

  test('Use a custom status code and an emtpy body', () async {
    charlatan.whenGet(
      '/posts',
      (_) => null,
      statusCode: 204,
    );

    final emptyBody = await client.get<Object?>('/posts');
    expect(emptyBody.data, '');
    expect(emptyBody.statusCode, 204);
  });

  test('Handle a POST and then a GET with shared state', () async {
    final posts = <Object>[];
    charlatan
      ..whenPost(
        '/posts',
        (request) {
          final params = request.body as Map<String, Object?>? ?? {};
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
