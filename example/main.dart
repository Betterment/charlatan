import 'package:charlatan/charlatan.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:uri/uri.dart';

void main() {
  late Dio client;
  late Charlatan charlatan;

  setUp(() {
    charlatan = Charlatan();
    client = Dio()..httpClientAdapter = charlatan.toFakeHttpClientAdapter();
  });

  test('Create a plain fake response', () async {
    charlatan.whenGet(
      '/user',
      charlatanResponse(statusCode: 200, body: {'name': 'frodo'}),
    );

    final plain = await client.get<Object?>('/user');
    expect(plain.data, {'name': 'frodo'});
  });

  test('Use a URI template', () async {
    final pathWithTemplate = '/users/{id}';
    charlatan.whenGet(
      pathWithTemplate,
      (request) {
        final uri = Uri.parse(request.path);
        final template = UriTemplate(pathWithTemplate);
        final parser = UriParser(template);
        final pathParameters = parser.parse(uri);
        return CharlatanHttpResponse(
          statusCode: 200,
          body: {
            'id': pathParameters['id'],
            'name': 'frodo',
          },
        );
      },
    );

    final withPathParams = await client.get<Object?>('/users/12');
    expect(withPathParams.data, {'id': '12', 'name': 'frodo'});
  });

  test('Use a custom status code and an empty body', () async {
    charlatan.whenGet(
      '/posts',
      charlatanResponse(statusCode: 204),
    );

    final emptyBody = await client.get<Object?>('/posts');
    expect(emptyBody.data, null);
    expect(emptyBody.statusCode, 204);
  });

  test('Use a custom request matcher', () async {
    charlatan.whenMatch(
      (request) => request.method == 'GET' && request.path == '/posts',
      charlatanResponse(statusCode: 204),
    );

    final emptyBody = await client.get<Object?>('/posts');
    expect(emptyBody.data, null);
    expect(emptyBody.statusCode, 204);
  });

  test('Use a custom request matcher with helpers', () async {
    charlatan.whenMatch(
      requestMatchesAll([
        requestMatchesHttpMethod('GET'),
        requestMatchesPathOrTemplate('/posts'),
      ]),
      charlatanResponse(statusCode: 204),
    );

    final emptyBody = await client.get<Object?>('/posts');
    expect(emptyBody.data, null);
    expect(emptyBody.statusCode, 204);
  });

  test('Return a complicated response based on conditions', () async {
    charlatan.whenPost('/users', (req) {
      final data = req.body as Map<String, Object?>? ?? {};
      final name = data['name'] as String?;
      if (name == null) {
        return CharlatanHttpResponse(
          statusCode: 422,
          body: {
            'errors': {
              'name': ['cannot be blank'],
            },
          },
        );
      }

      return CharlatanHttpResponse(
        statusCode: 201,
        body: {'id': 1, 'name': name},
      );
    });

    final invalidResponse = await client.post<Object?>(
      '/users',
      data: {'name': null},
      // don't throw on non 2xx/3xx responses so that we can do assertions
      options: Options(validateStatus: (_) => true),
    );
    expect(invalidResponse.data, {
      'errors': {
        'name': ['cannot be blank']
      }
    });
    expect(invalidResponse.statusCode, 422);

    final validResponse = await client.post<Object?>(
      '/users',
      data: {'name': 'frodo'},
    );
    expect(validResponse.data, {'id': 1, 'name': 'frodo'});
    expect(validResponse.statusCode, 201);
  });

  test('Handle a POST and then a GET with shared state', () async {
    final posts = <Object>[];
    charlatan
      ..whenPost(
        '/posts',
        (request) {
          final params = request.body as Map<String, Object?>? ?? {};
          posts.add({'name': params['name']});
          return CharlatanHttpResponse(statusCode: 204);
        },
      )
      ..whenGet(
        '/posts',
        charlatanResponse(body: {'posts': posts}),
      );

    final beforeCreatePost = await client.get<Object?>('/posts');
    expect(beforeCreatePost.data, {'posts': <Object?>[]});

    final createPost = await client.post<Object?>(
      '/posts',
      data: {'name': 'bilbo'},
    );
    expect(createPost.statusCode, 204);

    final afterCreatePost = await client.get<Object?>('/posts');
    expect(afterCreatePost.data, {
      'posts': [
        {'name': 'bilbo'},
      ]
    });
  });
}
