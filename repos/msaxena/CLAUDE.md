# nurpkgs

Mayur Saxena's personal [NUR](https://github.com/nix-community/NUR) repository: Nix packages and NixOS modules for self-hosted apps that aren't (yet) in nixpkgs proper. See [README.md](README.md) for the user-facing package/module list and usage examples.

## Layout

- `pkgs/<name>/default.nix` — the package derivation.
- `nixos-modules/<name>.nix` — the `services.<name>` NixOS module that runs it (systemd units, options). Registered in `nixos-modules/default.nix`.
- `default.nix` / `flake.nix` — expose everything as `legacyPackages`/`packages`/`nixosModules`/`formatter` per system.

A package and its module are a pair: the package builds the software (and states in `meta.longDescription` what it deliberately does *not* do, e.g. "no bundled reverse proxy"); the module is what actually makes it runnable and secure on NixOS. Don't assume upstream's own Docker image reflects what the module should do — check upstream's actual Dockerfile/compose file/nginx config when in doubt, since that's usually the more complete spec of "what a working deployment needs" than the bare application source.

## Package conventions

- `fetchFromGitHub` with `tag = "v${version}"` (or whatever upstream's actual tag scheme is) — this is what `nix-update` needs to find and bump versions automatically; see "Automated updates" below.
- Every package has `passthru.tests` using `testers.nixosTest`, importing its own module and exercising the *running service*, not just checking the build succeeds. See "Testing" below for what "exercising" needs to mean.
- Credential-shaped settings (API keys, secrets, passwords) are never plain Nix string options — those land verbatim, world-readable, in `/nix/store` unit files. They go through an `environmentFiles`/`environmentFile` option (systemd `EnvironmentFile=`), documented per-package with the exact supported keys. This composes directly with sops-nix.
- `meta.license`: read the upstream `LICENSE` file's actual text before picking a license attribute, don't infer from a README badge or assume "-or-later" — e.g. an AGPLv3 file with no "or any later version" grant is `agpl3Only`, not `agpl3Plus`.
- systemd hardening: existing modules (see `nixos-modules/yamtrack.nix`'s `hardening`/`baseServiceConfig`) apply a dense, deliberate hardening set (`ProtectSystem = "strict"`, `RestrictAddressFamilies`, `SystemCallFilter`, etc.) to the main app service. Match that density for a new stateful service; a stateless helper (a co-located proxy, say) warrants less — use judgment, and say why in a comment when you deviate.
- `systemd.services.<name> = { ... };` written as separate top-level statements (one per service) rather than nested under one `systemd.services = { ... };` block is the deliberate house style here for modules with several services — see `statix.toml`.

## Testing

The single biggest failure mode found in this repo's history: **a systemd unit reporting "active (running)" proves nothing about whether the service actually works.** A NixOS VM test that only checks `wait_for_unit` + a bare `curl -sf` (status code only) can pass while the app is silently returning empty or broken responses underneath — this happened for real with `yamtrack`'s reverse proxy (see git log around the Caddy proxy addition): every unit was healthy, `curl -sf` was satisfied by an HTTP 200 with a *zero-byte body*, and the actual bug (a CSRF/Host-header mismatch) only surfaced once a test checked real response content end-to-end. Write VM tests that verify actual behavior — fetch real content and check it, exercise the real user-facing flow (a login, a registration POST, whatever's load-bearing), not just "did the port open."

When debugging a failing VM test, **don't iterate by re-running the full VM test.** It's slow (NixOS boot + service startup each time, worse under CPU-emulated `nix build` on a non-native builder) and each cycle only gives you one data point. Instead: build the package for your own host platform directly (`nix build .#<pkg>` — most of these build cross-platform, e.g. `aarch64-darwin`, even though the *module* is Linux-only) and run the actual binaries by hand with matching env vars. That gets you a working repro in seconds, lets you iterate on the actual fix in seconds, and you only need the full VM test once at the end to confirm. Reserve the VM test cycle for final confirmation, not exploration.

Run a package's tests directly with e.g. `nix build .#packages.x86_64-linux.<pkg>.tests.<testname> -L`.

## Formatting & linting

- **`nix fmt`** ([nixfmt](https://github.com/NixOS/nixfmt), the Nix Foundation's official formatter) formats the whole tree. Run it before committing; CI checks it (`nixfmt --check`) and will fail if anything's unformatted.
- **statix** and **deadnix** lint for anti-patterns and dead code respectively; also CI-enforced. `statix.toml` at the repo root disables the `repeated_keys` lint deliberately — see the comment there for why (it fights the intentional multi-service module style above).
- All three are enforced in `.github/workflows/lint.yml` on every push to `main` and every PR. There's no local git hook — nothing blocks a local commit; the CI check is the gate.

## Automated updates

`.github/workflows/update-packages.yml` runs daily (and via manual `workflow_dispatch`): for each package, it runs `nix-update`, and — only if that finds a newer version — lints the tree and builds the package and runs its full `passthru.tests` suite against the new version before opening a PR.

**Only patch-level bumps merge themselves**, and only with every check green. The bump is classified in the update step by comparing the `version` attribute evaluated off the derivation before and after `nix-update` runs; `patch` means both versions are plain three-component versions, they differ, and major and minor are unchanged. Everything else — a major or minor bump, a prerelease suffix, a version that couldn't be evaluated, or a hash change with *no* version change (a retagged upstream release, which deserves a human every time) — is classified `other` and waits for manual review. The conservative default is deliberate: keep new cases falling into `other` rather than widening what merges unattended.

Note what "patch" means for a 0.x package like `yamtrack`: `0.26.1 → 0.26.3` auto-merges, `0.26.x → 0.27.0` does not. That matches the convention that 0.x upstreams put breaking changes in the minor slot, but it is a weaker guarantee than the same rule post-1.0.

Auto-merge uses a merge commit (matching how PRs #1 and #2 were merged by hand) and then pings NUR's re-sync endpoint *inline*. That `curl` is not redundant with `nur-notify.yml` — see the `GITHUB_TOKEN` consequences below.

Two consequences of PRs being opened with the default `GITHUB_TOKEN`, both non-obvious and both already worked around — don't "simplify" either back out:

- **Update PRs get no checks of their own.** GitHub deliberately doesn't start workflow runs for events caused by `GITHUB_TOKEN`, so `lint.yml`'s `pull_request` trigger never fires on an update PR — the run is recorded as `action_required` with zero jobs and the PR sits with no checks at all. That's why the lint gate (`nixfmt --check`, `statix`, `deadnix`) is duplicated *inside* `update-packages.yml`'s verify step, against the working tree that is byte-for-byte what the PR will contain. A `schedule:` trigger on `lint.yml` would not fix this — scheduled runs only ever run on the default branch. Getting real PR checks instead would require creating the PR with a PAT or GitHub App token.
- **A merge pushed by the workflow does not trigger `nur-notify.yml`** for the same reason, which is why the auto-merge step pings the NUR endpoint itself. Delete that `curl` as a duplicate and auto-merged updates silently stop reaching NUR consumers until NUR's own poll catches up.

Relatedly, **GitHub sends no notification when a PR branch is force-pushed** — which is how two fully-verified PRs sat unnoticed for a fortnight. The workflow therefore posts an `@`-mention comment when (and only when) `create-pull-request` reports the PR was `created` or `updated`; a mention is the one native signal that reaches the notification inbox, and so GitHub Mobile push, regardless of repo watch settings. A run that finds no new version stays silent.

`nix-update`'s `--use-github-releases` path calls the GitHub REST API, which unauthenticated shares a 60-request/hour per-IP budget that runners routinely exhaust — this failed the update step outright (`HTTP Error 403: rate limit exceeded`) on 2026-08-31 and 2026-09-02, silently skipping those days. The step now passes `GITHUB_TOKEN` in `env:`, which `nix-update` picks up on its own and sends as a bearer token for the 5000/hour limit. Only the `--use-github-releases` packages need it; `scrobblex`'s tag detection reads the atom feed and never touches the API.

Each package needs the *correct* `nix-update` release-detection flag — get this wrong and you'll get a silently-wrong proposed version, not an error:

- `yamtrack`, `trek`: pass `--use-github-releases` (uses the GitHub REST API, which has a real `prerelease` flag). Without it, `trek`'s default tag-based detection would propose an actual pre-release tag (`v4.0.0-pre.1`) as if it were stable.
- `scrobblex`: do **not** pass `--use-github-releases` — upstream stopped publishing GitHub Releases after `v1.4.3` but kept tagging real versions past it, so the Releases API is stale there and `--use-github-releases` would propose a *downgrade*. Plain tag detection (the default) tracks it correctly.

If a 4th package is ever added here, check both modes against its actual GitHub Releases vs. tags before picking one blindly — don't assume either is universally correct.

`.github/workflows/nur-notify.yml` pings NUR's re-sync endpoint (`https://nur-update.nix-community.org/update?repo=msaxena`) on every push to `main` touching `pkgs/`, `nixos-modules/`, or the root `default.nix`/`flake.nix` — NUR otherwise only polls registered repos on its own schedule, so without this, a merged update wouldn't show up for consumers immediately.

One non-obvious repo setting these workflows depend on: **Settings → Actions → General → Workflow permissions** needs "Read and write permissions" + "Allow GitHub Actions to create and approve pull requests" checked, or PR creation in `update-packages.yml` fails with "GitHub Actions is not permitted to create or approve pull requests" even though the workflow's own `permissions:` block looks correct — this is a separate, additional repo-level gate. Already enabled as of 2026-08-21.
