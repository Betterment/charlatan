## 0.4.0

- Add `charlatanResponse` helper to concisely create `CharlatanResponseBuilder` values
- Remove `statusCode` from `when*` methods
- Change type of `CharlatanResponseBuilder`
  from `FutureOr<Object?> Function(CharlatanHttpRequest request, { int statusCode = 200 })`
  to `FutureOr<CharlatanHttpResponse> Function(CharlatanHttpRequest request)`

## 0.3.0

- Add `whenMatch` for more complex matching scenarios
- Remove `CharlatanHttpRequest#pathParameters`

## 0.2.0

- Upgrade `dio` to `5.0.0`

## 0.1.0

- Upgrade `dio` and `test`
- Upgrade to dart 2.15.0

## 0.0.1

- Initial version.
