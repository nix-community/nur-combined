# Merrkry's NUR Repository

## Tooling

Mise installs the toolchain and runs tasks. `mise run check` runs all static checks and tests, and `mise run format` formats everything. `mise run test:nix-hash` runs `nix-hash` against real Nix builds.

`default.nix` is the NUR entry point and must evaluate with only `pkgs`. NUR's index and downstream overlays import it directly; `flake.nix` only wraps it for CI and `nix run`.

## Updates

Use `mise run update -- <package> [<package> ...]` to update packages. The Update NUR workflow runs it daily for every updatable package once Build and Check pass on the default branch. It opens a PR per updated package. Incomplete updates with source changes stay in draft PRs; validated updates become ready and enable auto-merge. Matching build and test derivations from draft PRs skip repeated failures. Failures without source changes remain workflow errors.

## Packaging

Aim for low maintenance: prefer packaging that keeps working across automatic updates without manual changes.

Follow nixpkgs' packaging conventions, including its manual for the relevant package manager (e.g. pnpm, cargo) or ecosystem (e.g. Electron).

- Reuse the upstream build process as much as possible. Don't disable the entire upstream test suite.
- Set `meta.description` from the upstream GitHub "About" text. If there is none, summarize the introduction in the README. Follow nixpkgs' conventions: a short noun phrase, e.g. `CLI for XXX`, without a leading article, the package name, or trailing punctuation.
- Keep packages compatible with the updater. In order of preference: the repository's default handling, `passthru.updateScript` with `nix-update` and extra arguments, a custom update script.
- When supported by the build system, enable `strictDeps` and `__structuredAttrs`, and define the derivation with `finalAttrs`.
- Primarily focus on `x86_64-linux`. No verifications for other platforms needed. When packaging requires extra effort for other platforms, e.g. platform-specific workarounds, maintaining hashes for and caching large binaries, drop the support for them.

## Verification

- Upstream's test suite. Disable tests as little as possible, and only when necessary.
- Nixpkgs's automatic check hooks.
- Manual tests, e.g. build the package, run it and verify its basic functionalities.
- For complex software, consider adding tests or checks that catch packaging broken by an automatic update. They should catch cases where upstream changes make the packaging stop fitting, e.g. an existing workaround no longer applies or a new feature isn't handled, not restate the current expression. E.g. after adding a dependency, don't add a test that only checks the dependency is present.
