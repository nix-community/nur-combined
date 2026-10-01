# NUR packages

Personal Nix packages and NixOS modules, structured for the Nix User Repository.

## Layout

- `default.nix`: package and module exports, compatible with NUR.
- `pkgs/<name>/`: package expressions, documentation, and maintenance metadata.
- `modules/`: NixOS modules, exported as paths under `nixosModules`.
- `tests/`: lightweight and optional integration tests.
- `justfile`: shared local and CI entry points.
- `shell.nix`: maintenance tools from the caller's `<nixpkgs>`.
- `tools/maintain.py`: isolated update orchestration.
- `AGENTS.md`: maintenance and commit conventions.

## Packages

| Package | NixOS module | Documentation |
| --- | --- | --- |
| `fluxdown-server` | `nixosModules.fluxdown` | [FluxDown Server](pkgs/fluxdown-server/README.md) |

Dependencies come from the caller's `pkgs`; module exports also work with
`pkgs = null`.

## Update and validate

Enter `nix-shell` from the repository root, then use:

```sh
just update fluxdown-server
just update fluxdown-server 0.5.1
just check fluxdown-server
just contract fluxdown-server
just check-all
```

Or run a single command with `nix-shell --run 'just update fluxdown-server'`.
Nix needs `nix-command` and `<nixpkgs>`. Upstream contract checks use `gh`
authentication. `just --list` shows all commands.

The update flow runs in a temporary copy of the current working files:

1. Select a target version once with `nix-update`.
2. Refresh source hashes for every declared platform, including the first one.
3. Regenerate and check the package's upstream configuration contract, if present.
4. Print the diff. Contract changes stop the update for review.
5. Build on the current platform, run package tests and lint, then copy only
   declared update files back. Validation failures leave working files unchanged.

After reviewing a contract diff, explicitly accept a specific version:

```sh
just update-reviewed fluxdown-server 0.5.1
```

This still runs all validation. It does not prove upstream behavior is compatible;
review the release notes and any changed types, defaults, validation, and protocol.
Updates never commit, push, or activate services. Concurrent working-file changes
are detected before writeback. Avoid editing the repository during updates.

`just check` builds and tests without network contract queries; `just contract`
checks upstream without modifying files. CI uses `just check-all`, without VMs.
Only the current platform is build-tested. For flat binary archives, hashes for
other platforms are fetched on the local machine without foreign builders.
Generic source/dependency updates use `nix-update` and may need other builders.

To build without the maintenance tools:

```sh
nix build -f . fluxdown-server --no-link
nix build -f . --no-link
```

## Scheduled package updates

`Package updates` runs at 00:00, 06:00, 12:00, and 18:00 UTC, or by manual
dispatch on the default branch. It uses `self-hosted` in `DaVinci42/nur-packages` with Nix,
`nix-command`, `<nixpkgs>`, and GitHub access. Schedules may be delayed and must
be enabled on the default branch. Keep this runner isolated from untrusted PRs.

Each `pkgs/*/maintenance.toml` declares `[release]` with a GitHub `repository`
(`owner/repository`) and required `assets` (filenames with optional `{version}`).
The latest stable `vX.Y.Z` or `X.Y.Z` must be newer than the packaged version and
have all required assets uploaded and nonempty. Otherwise the job skips it.
Errors stop immediately; contract changes require manual review.

Each update uses an isolated worktree and the existing `just update` validation.
Only declared package files are committed and pushed to a version-specific branch.
The PR title is `package: old-version -> new-version`; its body lists actual
checks and untested platforms. Existing PRs, including closed ones, are not
recreated. Branch conflicts fail without force-pushing; a pushed branch whose PR
creation failed can be opened manually. Packages never share update commits. No Issues are created or PRs auto-merged.

`GITHUB_TOKEN` needs `contents: write`, `pull-requests: write`, and the repository
setting allowing Actions to create pull requests. Its PRs do not trigger further
workflows; checks already run before publication. Set optional `UPDATE_TOKEN`
(a GitHub App or scoped PAT) if PR-triggered CI is required. Git identity comes
from environment variables, not Git configuration.

```sh
nix-shell --run 'just check-updates'          # Read-only asset readiness
nix-shell --run 'just check-updates --update' # Update and validate, no commit
```

The workflow uses `--pr` to publish; it requires a clean checkout,
`GITHUB_REPOSITORY`, and `UPDATE_BASE`. Local `act` runs use `--update`, never
commit, push, or open PRs. `just check-all` includes monitor regression tests.
Readiness does not separately download archives or verify an upstream checksum
manifest; source fetching and hash validation belong to the shared updater.

## LLM-assisted maintenance

The project skill [nur-package-update](.agents/skills/nur-package-update/SKILL.md)
guides release review, contract-change handling, validation, and reporting. Ask
an agent to update a package or check its upstream release. Crush discovers the
skill under `.agents/skills/`; `AGENTS.md` also points agents to it explicitly.
No global skill installation or additional Crush configuration is required.

The skill calls the existing `just` commands rather than replacing them. Keep
package-specific exceptions in package READMEs and executable maintenance rules
in `maintenance.toml` and the updater. Its
[evaluation scenarios](.agents/skills/nur-package-update/evals/evals.json) cover
an already-current package, a compatible update, and a contract review gate.
These scenarios have not yet completed an LLM behavior evaluation.

## Adding maintenance support

Add `pkgs/<name>/maintenance.toml`:

- `files`: package-relative files the updater may modify.
- `rawSource` (optional): file holding unique source hashes for a flat `fetchurl`
  package. Uses local prefetching for each architecture; omit for source packages.
- `sync` / `contract` (optional): argument arrays for generating/checking contracts.
- `tests` (optional): arrays of test commands, executed from the repository root.
- `runtimePackageEnv` (optional): environment variable receiving the built package
  path for isolated runtime tests.

JSON files ending in `-schema.json` are compared before and after generation;
changes other than their top-level version require explicit review. Other contract
formats need a corresponding comparison before claiming equivalent protection.
Metadata commands are trusted repository code, not a security sandbox.

## Registration

This repository is not registered in public NUR. Submit a separate PR to the
NUR index adding the repository URL to `repos.json`; no `file` field is needed.

## Migration

Consumers using a non-flake input must now import `${input}/modules/fluxdown.nix`.
Update the input lock and import path together after this change is published.
Configurations pinned to older commits continue to use their old paths.
