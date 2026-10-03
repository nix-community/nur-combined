# NUR package maintenance

## Priority 0: simplicity

- Concise code and low cyclomatic complexity are the highest design priority.
- Prefer early errors, guard clauses, and a short, linear execution path.
- Reuse existing workflows; remove redundant checks, branches, and abstractions.
- Keep functions focused, but do not split code solely to game complexity metrics.
- Preserve correctness, security, and required validation when simplifying.
- Review the entire diff, including new files, against these rules before finishing.

- Keep packages in `pkgs/<name>/`, NixOS modules in `modules/`, and tests in
  `tests/`. Export packages and module paths from `default.nix`.
- Keep module exports evaluable with `pkgs = null`; use the caller's `pkgs`.
- Write documentation in English. Put package-specific usage and maintenance
  notes in `pkgs/<name>/README.md`, not in this file.
- Do not modify consuming configurations or running services unless requested.
  Keep secrets outside the Nix store.

## Commit style

For commits, PRs, merges, and history recovery, load
`.agents/skills/clean-main-workflow/SKILL.md`. Prefer one commit per PR and squash
merging so each PR adds one non-merge commit to main. Keep release-specific notes
in the PR rather than appending them to READMEs.

For package version updates, use `pkg-name: old-ver -> new-ver`, with the package
attribute and actual versions, without a Conventional Commit prefix.
For other changes, use English Conventional Commit titles: `feat:`, `fix:`,
`docs:`, `refactor:`, `test:`, or `chore:`.
Keep titles under 72 characters and describe the outcome.
Use `feat` for new capabilities and `fix` for corrections. Explain non-obvious
reasoning in the body. Do not commit, push, or rewrite published history unless
explicitly requested; use `--force-with-lease` for authorized history rewrites.

## Updates

For package updates and upstream checks, load
`.agents/skills/nur-package-update/SKILL.md` before proceeding. It guides review
and validation through the existing commands; package READMEs retain exceptions.

Use `nix-shell --run 'just update <name>'` and the package's `maintenance.toml`.
Read the package README for exceptions. Review contract changes before using
`just update-reviewed <name> <version>`; never bypass a failed check merely to
finish an update. Only the current platform is build-tested.

1. Verify the upstream release and review changes since the packaged version.
2. Update the version and all supported source hashes together. Check archive
   layout, dependencies, license, and platform support.
3. Use upstream schemas or parsers at that release as configuration authorities.
   Compare keys, types, defaults, bounds, and application semantics; update
   affected modules and regression tests. Do not claim unimplemented coverage.
4. If generated contracts exist, regenerate and check them; never edit their
   output by hand. Documentation alone does not detect upstream drift.

## Validation

Run `nix-shell --run 'just check <name>'` for a package or `just check-all` for
all maintenance targets and updater tests. CI uses the same entry point.
Python changes must pass basedpyright with zero errors and warnings; `just lint`
runs it for every Python file using the shell's interpreter and dependencies.
`just contract <name>` checks the pinned upstream contract without rewriting it.

Run VM tests only when requested. Isolate runtime tests from existing services
and data. Report what was verified and what remains untested.
