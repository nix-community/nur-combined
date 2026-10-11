# NUR package maintenance

## Style and scope

- Prefer concise code, early errors and existing workflows. Avoid speculative
  fallbacks, redundant checks and function splits made only to reduce complexity
  metrics. Preserve security and data-integrity checks.
- Keep English documentation focused on usage, maintenance and tests; put package
  notes in `pkgs/<name>/README.md`. Diagnose errors from their messages, not
  speculative troubleshooting.
- Keep packages in `pkgs/`, modules in `modules/`, package tests in `tests/pkgs/`
  and maintenance tests in `tests/`. Export through `default.nix`; module exports
  must evaluate with `pkgs = null` and use the caller's `pkgs`.
- Keep secrets outside the Nix store. Do not change consuming configurations or
  running services unless requested.

## Updates

Load `.agents/skills/nur-package-update/SKILL.md` for updates and upstream checks.
Read the package's `passthru.updateScript` and README; verify the release and
review dependencies, license, platforms and configuration changes.

```sh
nix-shell --run 'just update <name>'
nix-shell --run 'just contract fluxdown-server'
nix-shell --run 'just check <name>'
```

- Declare complete updates in `passthru.updateScript` (`nix-update-script` for
  simple updates) and checks in `passthru.tests`. Do not add maintenance metadata
  or implicit follow-up hooks. Custom scripts must complete all updates and honor
  `NUR_DETECT_VERSION=1` for read-only detection.
- Refresh hashes for every supported source. Review configuration semantics with
  upstream schemas/parsers and regenerate contracts with their tools, not by hand.
- Adapt affected modules and tests before accepting contract changes with
  `just update-reviewed <name> <version>`. Never bypass failed checks.

## Validation

Validate packaging and repository logic, including build, dependency and import
checks. Do not run upstream unit suites or VM tests unless requested; isolate
runtime tests from existing services and data.

```sh
NIXPKGS_ALLOW_UNFREE=1 nix-shell --run 'just check-all'
nix-shell --run 'just lint'
git diff --check
```

Require zero basedpyright errors and warnings. Review the full diff, including new
files. Report passed checks and untested scope; builds cover the current platform.

## Git

Load `.agents/skills/clean-main-workflow/SKILL.md` for commits, PRs and history
changes. Prefer one commit per PR and squash merges. Do not commit, push or rewrite
published history unless requested; use `--force-with-lease` for authorized rewrites.

Use `pkg-name: old-ver -> new-ver` for updates and English Conventional Commit
titles otherwise, under 72 characters. Keep release notes in PRs, not READMEs.
Use `.github/package-update-pr.md` for update PRs: upstream diff URL, passed-check
list, tested platform and CI log link when available.

After publishing changes to `main`, refresh the [NUR index](https://nur-update.nix-community.org/):

```sh
curl -X POST 'https://nur-update.nix-community.org/update?repo=davinci42'
```
