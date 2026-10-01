---
name: nur-package-update
description: Update or check packages in this NUR repository through its existing just workflow. Use for version bumps, latest-release checks, source hash refreshes, configuration contract drift, and failed updates, including FluxDown updates. Not for deployment or consumer configuration changes.
---

# NUR package update

Use the existing updater, not a parallel implementation. Follow `AGENTS.md` for
repository rules and the root README for command behavior and prerequisites.
Run commands from the repository root, replacing placeholders with verified values.

## 1. Read and verify

- Check `git status --short`; preserve existing work. Resolve the requested name
  through `default.nix`, then read its package expression, `README.md`, and
  `maintenance.toml`. If metadata is missing, report that this flow is unsupported.
- Verify the target using upstream locations from those files; use `gh` for
  GitHub. Default to the latest stable release, not a prerelease or downgrade.
  Confirm release status and assets for every supported platform.
- If already at the target, report no update and stop without rewriting files or
  running the updater. Run checks only if requested; investigate reported hash
  or contract problems separately. Failed upstream access is not a no-update result.
- Review release notes and source changes per `AGENTS.md`, using the package
  README's configuration authorities. A matching schema does not prove unchanged
  startup, validation, or RPC behavior.

## 2. Update the reviewed version

Pin the target to avoid changing releases mid-review:

```sh
nix-shell --run 'just update <name> <version>'
```

Let the updater refresh all platform hashes and generate contracts. Do not edit
the working tree while it runs. Investigate unexpected same-version hash changes.

## 3. Handle a contract review gate

The rejected candidate has not replaced working files and may already be deleted.
Read the printed diff; use the package's candidate check or rerun the same target
if needed. Trace changed fields, bounds, source hashes, and protocol versions to
old and target upstream code, including validation and application semantics.

Adapt affected modules, helpers, regression tests, and package documentation;
fix generators rather than hand-editing their output. Test adaptations against
an isolated candidate when necessary. If no adaptation is needed, explain why
with source evidence. Only then accept the exact reviewed version:

```sh
nix-shell --run 'just update-reviewed <name> <version>'
```

This accepts review, not failed validation. Fix relevant failures and retry the
shared flow; do not weaken checks. Report external blockers and required remedies.

## 4. Validate and report

After the update and any follow-up edits:

```sh
nix-shell --run 'just contract <name>'
nix-shell --run 'just check <name>'
```

Use `just check-all` inside `nix-shell` for shared maintenance or multi-package
changes. Review `git diff --check`, `git diff`, and `git status --short`, including
new files. Report versions, compatibility decisions, actual checks and results,
and untested platforms or VM tests. Hash fetching is not foreign-platform testing.

When explicitly asked to commit a version update, use `pkg-name: old-ver -> new-ver`
without a Conventional Commit prefix, quotes, or angle brackets. Use the package
attribute and actual before/after versions, for example `fluxdown-server: 0.5.0 -> 0.5.1`.
Do not commit automatically; use the general commit style for non-version changes.
