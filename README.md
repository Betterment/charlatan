# fake_http

[![pub package](https://img.shields.io/pub/v/fake_http.svg)](https://pub.dev/packages/fake_http)
[![Build status](https://github.com/Betterment/dart_fake_http/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Betterment/dart_fake_http/actions/workflows/ci.yml?query=branch%3Amain)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Betterment/dart_fake_http/pulse)

This package provides the ability to configure and return fake HTTP
responses from your Dio HTTP Client. This makes it easy to test the
behavior of code that interacts with HTTP services without having to use
mocks.

It consists of two components:

* `FakeHttp` - a class for configuring and providing fake HTTP responses
    based on HTTP method and URI template.
* `FakeHttpClientAdapter` - an implementation of Dio's
    `HttpClientAdapter` that returns responses from a configured
    `FakeHttp` instance

## Usage

Add `fake_http` to your pubspec.yaml's `dev_dependencies`.

```yaml
# pubspec.yaml
dev_dependencies:
  fake_http:
```

### Configuring fake responses

TODO

### Building a fake HTTP client

TODO

### FAQ

> What happens if I make a request that doesn't match a configured fake
> response?

TODO

> How can I configure a fake response that relies upon the result of
> another fake request? e.g. a POST followed by a GET that can "read its
> own writes"

TODO
