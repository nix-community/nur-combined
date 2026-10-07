# NUR Packages

[![build](https://github.com/codgician/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/codgician/nur-packages/actions/workflows/build.yml)
[![evergreen](https://github.com/codgician/nur-packages/actions/workflows/evergreen.yml/badge.svg)](https://github.com/codgician/nur-packages/actions/workflows/evergreen.yml)

NUR Packages from codgician.

Packages are built on GitHub Actions via [atelier](https://github.com/stepbrobd/atelier) for `x86_64-linux`, `aarch64-linux` and `aarch64-darwin`.

## Automatic build repairs

When a package build or check fails on the current `main` revision, build-completion automation invokes Pi and opens one PR per failing package on `bot/repair-<package>`. Multiple platform failures for the same package share one repair. Existing open repair PRs prevent duplicate creation; stale builds, cancelled runs, and harness or unattributed infrastructure failures do not create repair PRs.

Main-build fixes preserve the package version. They share the existing bot-PR repair pipeline, including package-only changes, updater idempotence, formatting, build and smoke validation, signed publication, and revision freshness checks. Failed builds on eligible bot-owned, same-repository, single-package PRs update the same PR, with at most three AI repair commits. Human-authored and fork PRs are not repaired automatically.

Repairs use the existing `DENDRO_API_KEY`, `APP_PRIVATE_KEY`, and `APP_CLIENT_ID` configuration. The repository's `bot-build-fix` label distinguishes same-version repairs from updates. Agent execution has read-only repository permissions; only the separate publisher receives the GitHub App write token. AI-assisted PRs require human review and normal PR CI before merging.

## Binary cache

- **Cache URL**: `https://cache.codgician.me/nur-packages`
- **Public Key**: `nur-packages:AbWm/DsIy5+TtVaW6GhiZX98nU6y5913NqjEXeeV8mA=`
