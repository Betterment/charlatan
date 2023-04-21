## Releases

The releases of `Charlatan` are automated in such a way that we should be able to run the `Release` action at any time to release a new version on pub.dev. The following image details how this happens:

![Release workflow diagram](releases.png?raw=true "Release workflow diagram")

### Why is this so complicated?

Releases are a multi-stage process due to the fact that we cannot commit directly to `main`. If we could, we could generate release notes, update the `CHANGELOG.md` file, update `pubspec.yaml` with the new version, commit these changes to `main` and then continue on with tagging and publishing the new version. Instead, we need to open a PR with these changes, wait for it to merge, and then continue with the release.

Furthermore, we leave the actual publishing in a workflow of its own to support running it manually if we need to.