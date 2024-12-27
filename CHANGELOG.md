## 0.4.1 - 2025-01-01

- Export `CharlatanResponseBuilder`

## 0.4.0 - 2023-04-13

- Add `charlatanResponse` helper to concisely create `CharlatanResponseBuilder` values
- Remove `statusCode` from `when*` methods
- Change type of `CharlatanResponseBuilder`
  from `FutureOr<Object?> Function(CharlatanHttpRequest request, { int statusCode = 200 })`
  to `FutureOr<CharlatanHttpResponse> Function(CharlatanHttpRequest request)`

## 0.3.1 - 2023-04-13

- Export `CharlatanHttpRequest` and `CharlatanRequestMatcher`

## 0.3.0 - 2023-04-11

- Add `whenMatch` for more complex matching scenarios
- Remove `CharlatanHttpRequest#pathParameters`

## 0.2.0 - 2023-02-16

- Upgrade `dio` to `5.0.0`

## 0.1.0 - 2022-02-11

- Upgrade `dio` and `test`
- Upgrade to dart 2.15.0

## 0.0.1 - 2021-12-16

- Initial version.
