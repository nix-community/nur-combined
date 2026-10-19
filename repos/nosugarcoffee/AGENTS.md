# AGENTS.md

Guidance for AI coding agents. `CLAUDE.md` is a symlink to this file. See `README.md` for what
the repo is, its packages, and how updates work.

## Layout

- `default.nix` is the NUR entry point and the single place packages are collected; `flake.nix`
  builds every output from it. Adding a package is adding `pkgs/<name>/package.nix` — no list to
  update anywhere except the README table.
- `pkgs/<name>/pin.json` + `lib/release-pin.nix` hold a release download's version, URL template
  and per-system hashes. `scripts/release_pins.py` bumps them; never hand-edit hashes for a new
  version, run the script (`python3 scripts/release_pins.py`) instead.
- `packages.<system>` is filtered by `meta.platforms`; `legacyPackages.<system>` is everything.

## Constraints

- **Stay NUR-compatible.** `default.nix` must evaluate as `import ./. { pkgs = ...; }` with
  `restrict-eval`: no import-from-derivation, no flake-only inputs, no network access at eval
  time.
- **Systems follow nixpkgs-unstable**: aarch64-darwin, x86_64-linux, aarch64-linux. Keep the
  x86_64-darwin entries in pins; they still serve the overlay on nixpkgs 26.05.
- **`git add` new files before `nix build`/`nix eval`** — the flake only sees tracked files.
- **Keep the README package table in sync with `pkgs/`** — `tests/test_readme.py` fails otherwise.

## Checks

```sh
python3 -m unittest discover -s tests -t tests
nix flake check --all-systems --no-build
nix run nixpkgs#nixfmt -- --check $(git ls-files '*.nix')
nix run nixpkgs#statix -- check . && nix run nixpkgs#deadnix -- --fail .
```

## Workflow

Commits and PRs only on explicit request. Feature branch → PR → squash-merge. No secrets or
work-internal identities in commits; this repo is public.
