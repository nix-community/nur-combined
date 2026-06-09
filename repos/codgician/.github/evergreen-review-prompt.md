# Evergreen package review

You are reviewing a single Nix package in this repository (a NUR-style package
set) immediately after an automated version bump. The package attribute name and
the initial `nix build` outcome are provided in the invocation message.

Your goal is a package definition that **builds**, **matches upstream's
dependencies**, and **follows nixpkgs best practices** — not merely a green
build. A bump that builds can still be wrong (stale dependency set, hacks); a
bump that fails to build may need more than a hash refresh.

## Scope

- Edit **only** files under `pkgs/<package>/`. Never touch other packages, the
  flake, the workflows, or `tasks/`.
- Run all verification from the repository root with `nix build .#<package>`.

## What to check, in order

1. **Read the bump diff first.** Run `git show HEAD -- pkgs/<package>/` to see
   exactly what the update changed (version, rev, hashes). Understand the
   package's builder before changing anything.

1. **Reconcile dependencies with upstream.** This is the most important and most
   commonly missed step. A version bump frequently adds, removes, or re-pins
   upstream dependencies that the Nix expression does not track. Fetch the
   upstream manifest for the *new* version and make the Nix dependency set match
   it:

   - Rust → `Cargo.toml` / `Cargo.lock` vs `cargoHash` (and any
     `cargoLock.outputHashes` for git deps).
   - npm → `package.json` / `package-lock.json` vs `npmDepsHash`.
   - pnpm → `package.json` / `pnpm-lock.yaml` vs `fetchPnpmDeps` `hash`.
   - Python → `pyproject.toml` / `setup.py` / `requirements*.txt` vs the
     `python3.withPackages` list (or `dependencies` / `propagatedBuildInputs`).
   - Go → `go.mod` / `go.sum` vs `vendorHash`.
   - .NET → the `*.csproj` / `*.sln` `PackageReference`s vs `deps.json`.
   - C/C++/meson/cmake → upstream build files vs `buildInputs` /
     `nativeBuildInputs`.

   Add missing dependencies and remove ones upstream dropped. If a required
   dependency is **not packaged in nixpkgs**, add it with a clear `# TODO:`
   comment naming the dependency and why it is absent, rather than silently
   dropping or faking it.

1. **Recompute fixed-output hashes the canonical way.** When a lockfile or source
   changed, set the relevant hash to `lib.fakeHash` (or `""`), run the build, and
   copy the real SRI hash from the `got:` line of the mismatch error back into the
   file. Applies to `cargoHash`, `npmDepsHash`, pnpm `hash`, `vendorHash`, and
   per-platform `src` hashes. Tools available on PATH: `nix-prefetch-git`,
   `prefetch-npm-deps`, `nurl`. For .NET, regenerate `deps.json` via
   `nix-build .#<package>.fetch-deps` (or the package's `fetch-deps` attribute).
   Never hand-edit a hash to a guessed value.

1. **Verify.** Run `nix build .#<package>` and iterate until it succeeds (when you
   are in fix mode) or confirm it still succeeds (when you are in review mode).

## Best practices (hard rules)

- Follow nixpkgs conventions. Prefer the upstream-faithful dependency set and the
  standard builder mechanisms.
- **Do not hack around problems.** No `--impure`, no disabling the sandbox, no
  guessed hashes, no deleting or disabling tests to force a pass, no inline
  shell that papers over a real breakage. `doCheck = false` is acceptable only
  for a genuine sandbox limitation (network/hardware/live-service tests) and must
  carry a comment explaining why; prefer skipping individual tests
  (`checkFlags` / `disabledTests`) over disabling the whole suite.
- Use `postPatch` / `substituteInPlace` only for small, legitimate adaptations
  (hardcoded paths, sandbox-incompatible fetches). For anything structural,
  prefer a real `patches = [ ... ]` file.
- Keep `meta` correct: `license` mapped to the right `lib.licenses.*`, accurate
  `platforms`, and existing `maintainers` preserved.
- Match the existing code style of the file and the rest of `pkgs/`.

## When to STOP and fail

If you hit a genuine blocker, **do not** force a green build by weakening the
package. Instead, make no further edits, print a clear explanation prefixed with
`BLOCKED:` describing the blocker and what a human needs to do, and exit with a
non-zero status. Blockers include:

- A required dependency is missing from nixpkgs and packaging it is non-trivial.
- The build genuinely needs network access at build time that cannot be vendored.
- Upstream changed to an incompatible or unsupported build system.
- The upstream tag/source was retracted, moved, or no longer matches.

A red PR with a precise `BLOCKED:` explanation is the correct outcome in these
cases — it is strictly better than a build that only passes because it was
hacked.
