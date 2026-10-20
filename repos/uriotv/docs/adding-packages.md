# Adding and maintaining packages

## Directory contract

```text
pkgs/
  my-package/
    default.nix
    update.sh      # executable
    ...            # patches, auxiliary sources or version metadata
```

`pkgs/default.nix` is the registry. It discovers immediate directories containing
`default.nix`. It excludes files, symlinks and directories without a package
expression. Names must match `[A-Za-z0-9][A-Za-z0-9._+-]*`; `lib`, `modules` and
`overlays` and the compatibility alias `rimsort` are reserved. Use the directory name as the canonical attribute name,
even when `pname` differs. Compatibility aliases belong in `overlays/default.nix`,
not in the registry or CI.

The NUR entry point, flake, overlay, CI and updater all use this convention.
**Do not add a separate list or workflow case when adding a package.**

## Package expression

Use `callPackage` arguments and a version-linked source:

```nix
{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "my-package";
  version = "1.2.3";
  src = fetchFromGitHub {
    owner = "owner";
    repo = "project";
    tag = "v${finalAttrs.version}";
    hash = "sha256-..."; # actual hash, never leave a placeholder
  };
  # build/install inputs and phases...
  meta = {
    description = "A short description";
    homepage = "https://github.com/owner/project";
    license = lib.licenses.mit; # verify upstream; do not guess
    platforms = [ "x86_64-linux" ];
    mainProgram = "my-package";
  };
})
```

Always link the tag/revision to the version, or track both together in a custom
updater. A hardcoded old `src.rev` with a newer `version` can make `nix-update`
report success while still shipping old code. Branch-only upstreams can use
`nix-update --flake my-package --version=branch` instead.

Declare only supported `meta.platforms`. The flake exposes supported packages
and `checks`; automated compilation currently covers **x86_64-linux only**.
The pin does not support Intel macOS, so that system is not exported. A package
marked `meta.broken = true` or unsupported is explicitly listed as skipped in
the CI manifest/summary, not falsely reported as a successful build.

## Updater

For a conventional tagged upstream:

```bash
#!/usr/bin/env bash
set -euo pipefail
nix-update --flake my-package
```

```console
chmod +x pkgs/my-package/update.sh
```

The updater runs from the repository root with `nix-update`, Nix, curl, jq,
Python and standard runner utilities available. It must:

- change files **only within its own package directory**;
- update the version, source hash and secondary hashes (e.g. `vendorHash`)
  consistently; `nix-update` handles common fetchers automatically;
- finish without changes if already current;
- return nonzero if it cannot reliably check or update the package;
- never commit, push, install, activate a system or write secrets.

Use a custom script for unusual upstreams (NMSSaveEditor, RimSort release assets,
non-sortable bbport versions, StoryForge's coupled Cargo/Bun artifacts). A strict
wrapper may use `exec python3 -B "$script_dir/update.py" "$@"` with a real sibling
helper; preflight recognizes this delegation. Choose an explicit stable/prerelease policy.
Do not claim an asset exists merely because a release/tag exists.

The orchestrator preflights all packages, applies a 900-second timeout per
updater, and restores the whole package directory on failure. It continues
other packages. It writes `update_failures` and `successful_updates` counters to
`GITHUB_OUTPUT`; the workflow creates a PR for successful changes first and then
marks incomplete checks failed. The counters count updater executions, including
successful no-op checks, not the number of changed files.

Package updates never silently advance `flake.lock`. Use `nix flake update`
as a separate deliberate maintenance change and validate it before committing.

## Licenses and public cache

`lib/ci-policy.nix` separates **building** from **redistribution**:

- Every supported, non-broken package is built, even if unfree or
  `preferLocalBuild = true`.
- For each `meta.license` entry, an explicit `redistributable` boolean wins;
  otherwise `free == true` permits publication. Every entry must allow it.
- Empty/missing metadata, unknown strings, nonfree/nonredistributable entries
  fail closed: build yes, public cache no.
- `preferLocalBuild` is a scheduling preference, **not a licensing restriction**.
- All outputs of an eligible package are published, not only `out`.

Declare the real upstream license using nixpkgs license objects. Include all
applicable bundled-code restrictions. In particular, a free wrapper does not
make proprietary bundled contents redistributable. Metadata is the maintainer's
assertion of permission, not an automated legal audit; satisfy notices and
corresponding-source obligations where required. `cachix push` transfers runtime
closures, so dependencies also must be redistributable. Never mislabel a package
or dependency merely to make it upload. NMSSaveEditor currently stays unfree and
is built for validation but never explicitly sent to the public cache.

Publication is explicit and only from a successful `main` run, after offline
tests and all package builds pass. The helper cross-checks built outputs against
the manifest and verifies public narinfo `StorePath` values. PRs/updaters have no
Cachix write token. Public cache misses can still lead consumers to build locally;
Cachix retention/availability and differing consumer nixpkgs are not guaranteed.

## Validate before submitting

```console
# No network/builds: shell and Python regression tests with stubs.
./tests/run-tests.sh

# Nix CLI only, still no downloads or compilation.
python3 -B tests/registry-eval.py

# Evaluation with the locked nixpkgs; may fetch evaluation inputs, no compilation.
nix eval --json --no-write-lock-file .#ci.x86_64-linux.policyTests
nix eval --json --no-write-lock-file .#ci.x86_64-linux.manifest
nix flake check --no-build --no-write-lock-file

# Actual build (can be expensive; inspect the manifest first).
nix build --no-link --no-write-lock-file '.#packages.x86_64-linux.my-package^*'
```

New files must be Git-visible for a Git-backed flake (stage them deliberately,
or use `path:$PWD#...` for an evaluation-only working-tree check). The manifest
must include the new canonical name with the expected build/cache status.
`tests/registry-eval.py` tests adding an extra directory without editing a list;
`tests/package-policy.nix` tests free, unfree, redistributable, unknown, mixed,
broken, unsupported and `preferLocalBuild` cases.

For an end-to-end updater test, use a disposable checkout. The manual
`Update packages` workflow can select a single package; its eventual auto-merge
still waits for the complete required CI gate.
