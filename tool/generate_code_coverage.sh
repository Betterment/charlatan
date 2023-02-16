#!/usr/bin/env bash
set -e
set -o pipefail

# Required to get coverage in lcov form
dart pub global activate coverage

# Run tests and generate lcov
dart test --test-randomize-ordering-seed=random --coverage=coverage && dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
