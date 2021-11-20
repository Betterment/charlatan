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
  });
}
