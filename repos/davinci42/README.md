# NUR packages

Personal Nix packages and NixOS modules using the caller's `pkgs`.

| Package | NixOS module | Documentation |
| --- | --- | --- |
| `fluxdown-server` | `nixosModules.fluxdown` | [FluxDown Server](pkgs/fluxdown-server/README.md) |
| `spotify-spotx` | None | [Spotify with SpotX](pkgs/spotify-spotx/README.md) |

`default.nix` exports packages and module paths; modules also evaluate with
`pkgs = null`. Packages live in `pkgs/`, modules in `modules/`, and tests in
`tests/`. See [AGENTS.md](AGENTS.md) for maintenance conventions.

## Local maintenance

Run from the repository root with `<nixpkgs>` and `nix-command` enabled.
`nix-shell` provides the tools; upstream contract checks require authenticated `gh`.

```sh
nix-shell
just update fluxdown-server
just update-spotx
just check fluxdown-server
just contract fluxdown-server
NIXPKGS_ALLOW_UNFREE=1 just check-all
just --list
```

For a build without maintenance tools:

```sh
nix build -f . fluxdown-server --no-link
```

`just update <package> [version]` works in a temporary copy: it refreshes all
platform hashes, regenerates contracts, builds and tests on the current platform,
then copies back only declared files. Failures or concurrent edits prevent
writeback. Avoid editing during updates. Package READMEs document exceptions.

Contract changes require review, then `just update-reviewed <package> <version>`;
this does not bypass validation. `just check` builds, tests, and lints without
upstream contract queries; `just contract` checks upstream without writing files.
Foreign-platform hashes do not prove build compatibility. Run VM tests only when
requested. These commands do not commit, push, or activate services.

## Automated updates

`Package updates` wakes every four hours on the default branch. Each
`maintenance.toml` sets `checkIntervalHours`: FluxDown uses 4, SpotX 168; default 4.
A package is checked on the next run after its interval expires, not on a fixed
weekday. GitHub scheduling may add delays.

Successful checks, including no-update results, save timestamps under
`$HOME/.local/state/nur-updates/$GITHUB_REPOSITORY` on the persistent self-hosted
runner. Failures leave timestamps unchanged for retry; missing state triggers
an immediate check. Changing runners can cause extra checks. Manual dispatch
ignores intervals and does not update timestamps.

Updates use isolated worktrees. Releases run `just update`; snapshots run their
configured command followed by `just check`. Only validated, declared changes
are committed to a target-specific branch and proposed as a PR. Snapshot updates
abort if upstream moves during the update. Errors stop subsequent processing.
No auto-merges or Issues are created.

Existing PRs, including closed ones, are skipped. Manual `force` creates a fresh
branch without bypassing validation or force-pushing. Branch conflicts fail;
if pushing succeeds but PR creation fails, open the PR manually.

```sh
NIXPKGS_ALLOW_UNFREE=1 nix-shell --run 'just check-updates'
NIXPKGS_ALLOW_UNFREE=1 nix-shell --run 'just check-updates --update'
```

The first command is read-only; `--update` validates without publishing.
Snapshot updates in this mode modify working files in place, even on failure.
`--pr` requires a clean checkout, `GITHUB_REPOSITORY`, and `UPDATE_BASE`;
`--force` requires `--pr`. Local `act` runs validate without publishing.

### CI requirements

Both workflows use the existing self-hosted runner in `DaVinci42/nur-packages`
and have a 120-minute timeout. `Package checks` runs `just check-all` on main
pushes, same-repository PRs, and manual dispatch, without VMs. Fork PRs are skipped;
this is not a sandbox, so run only trusted code. Checkouts for checks do not
persist credentials.

Publishing needs `contents: write`, `pull-requests: write`, and permission for
Actions to create PRs. `GITHUB_TOKEN` PRs do not trigger further workflows;
validation runs before publication. Set `UPDATE_TOKEN` to an App token or scoped
PAT if PR-triggered CI is needed. Git identity comes from environment variables.

## Maintenance metadata

Each `pkgs/<name>/maintenance.toml` supports:

| Field | Purpose |
| --- | --- |
| `files` | Package-relative files updates may modify |
| `checkIntervalHours` | Positive integer hours between scheduled checks; default 4 |
| `rawSource` | File containing flat `fetchurl` hashes; must appear in `files` |
| `sync` / `contract` | Argument arrays to generate/check contracts |
| `tests` | Test command arrays, run from the repository root |
| `runtimePackageEnv` | Environment variable receiving the built package path |

Declare at most one upstream monitor; packages without one are skipped:

- `[release]`: GitHub `repository` and required `assets`, with optional `{version}`
  in filenames. Requires a newer stable `vX.Y.Z` or `X.Y.Z` and nonempty uploaded
  assets. Asset readiness is not checksum-manifest verification.
- `[snapshot]`: `repository`, `branch`, `attribute` exposing `src.rev`, update
  `command`, and `files` restricted to the package's declared files.

Changes to generated `*-schema.json` files, except the top-level version, require
review. Other contract formats need equivalent checks. Metadata commands are
trusted code, not a sandbox; contract checks do not cover all upstream behavior.

## Agent workflow and registration

The local [package-update skill](.agents/skills/nur-package-update/SKILL.md) uses
these commands; no global setup is needed. Its evaluation scenarios have not
completed an LLM behavior evaluation.

This repository is not registered in public NUR. Registration requires a separate
NUR-index PR adding its URL to `repos.json`, without a `file` field.
For older non-flake consumers, use `${input}/modules/fluxdown.nix` and update the
input lock and import path together.
