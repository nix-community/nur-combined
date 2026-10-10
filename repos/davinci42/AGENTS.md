# NUR package maintenance

## Style and scope

- Prefer concise code, guard clauses and existing workflows. Preserve correctness
  and security; do not split functions merely to reduce complexity metrics.
- Keep documentation short: usage, maintenance and test commands. Investigate
  errors from their messages when they occur; omit speculative troubleshooting.
- Write documentation in English; keep package notes in `pkgs/<name>/README.md`.
- Keep packages in `pkgs/`, modules in `modules/`, package tests in `tests/pkgs/`,
  and maintenance tests in `tests/`. Export through `default.nix`; module exports
  must evaluate with `pkgs = null` and use the caller's `pkgs`.
- Keep secrets outside the Nix store. Do not change consuming configurations or
  running services unless requested.

## Updates

Load `.agents/skills/nur-package-update/SKILL.md` for package updates and upstream
checks. Read package metadata and its README, verify the upstream release, and
review dependencies, license, platforms and configuration changes.

```sh
nix-shell --run 'just update <name>'
nix-shell --run 'just contract <name>'
nix-shell --run 'just check <name>'
```

Refresh all supported source hashes. Use upstream schemas/parsers to review
configuration semantics. Regenerate contracts through their tools, not by hand.
Adapt affected modules and tests before accepting reviewed changes with
`just update-reviewed <name> <version>`. Do not bypass failed checks.

## Validation

Validate packaging and this repository's own logic; do not run upstream unit
suites unless requested. Keep build, dependency and import checks.

```sh
NIXPKGS_ALLOW_UNFREE=1 nix-shell --run 'just check-all'
nix-shell --run 'just lint'
git diff --check
```

Python must pass basedpyright with zero errors and warnings. Review the complete
diff, including new files. Only the current platform is build-tested; run VM
tests only when requested and isolate runtime tests from existing services/data.
Report actual checks and untested scope briefly.

## Git

Load `.agents/skills/clean-main-workflow/SKILL.md` for commits, PRs and history
changes. Prefer one commit per PR and squash merges. Do not commit, push or
rewrite published history unless explicitly requested; use `--force-with-lease`
for authorized history rewrites.

Use `pkg-name: old-ver -> new-ver` for version updates and English Conventional
Commit titles for other changes. Keep titles under 72 characters. Put release
notes in PRs, not READMEs.
