# Contributing to charlatan

Thanks for checking out `charlatan` and thank you even more for wanting to contribute 🎉
The following guidelines should get you started out on your path towards contribution.

## Creating a Bug Report

[Create an issue][bug_report_template] if you have found a bug rather than immediately opening a pull request. This allows us to triage the issue as necessary and discuss potential solutions. When creating the issue, use the built-in [Bug Report template][bug_report_template] and provide as much information as possible including detailed reproduction steps. Once one of the package maintainers has reviewed the issue and an agreement is reached regarding the fix, a pull request can be created.

## Creating a Feature Request

Use the built-in [Feature Request template](https://github.com/Betterment/charlatan/blob/main/.github/ISSUE_TEMPLATE/feature_request.md) and add in any relevant details with your request. Once one of the package maintainers has reviewed the issue and triaged it, a pull request can be created.

## Creating a Pull Request

Before creating a pull request please:

1. Fork the repository and create your branch from `main`.
2. Install all dependencies (`dart pub get`).
3. Make your changes.
4. Add tests!
5. Ensure the existing test suite passes locally.
6. Format your code (`dart format .`).
7. Analyze your code (`dart analyze --fatal-infos --fatal-warnings .`).
8. Create the Pull Request with [semantic title](https://github.com/zeke/semantic-pull-requests).
9. Verify that all status checks are passing.

## License

This packages uses the [MIT license](https://github.com/Betterment/charlatan/blob/main/LICENSE)

[bug_report_template]: https://github.com/Betterment/charlatan/blob/main/.github/ISSUE_TEMPLATE/bug_report.md
