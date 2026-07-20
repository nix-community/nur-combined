---
description: Audit all exported packages for upstream updates
---

Batch-check exported packages for new upstream versions.

## Scope

- Read package attrs from `default.nix`.
- Ignore reserved attrs: `lib`, `modules`, `overlays`.
- Do not rely on a hard-coded package list in this file; the source of truth is always `default.nix`.

## Suggested workflow

1. Enumerate package attrs from `default.nix`.
2. Check upstream releases / tags / commits in parallel.
3. Produce a table of current version, latest version, and update status.
4. Ask for confirmation before editing many packages.
5. Update packages one by one with build verification.
6. **Test runtime dependencies**: for each updated package, run the built binary (`result/bin/<name> --help` or equivalent) to catch missing shared library errors. If it crashes on a missing `lib*.so`, add it to `runtimeDeps` / `buildInputs` / `propagatedBuildInputs`, rebuild, and re-test.
7. Refresh docs if package inventory or behavior changed.

## Repo-specific notes

- Some packages track releases (`LoveIwara`, `wechat-web-devtools-linux`).
- Some packages track commits or unstable revisions (`mihomo-smart`, `hyprland-mcp-server`).
- Some packages have extra lock/hash workflows (`LoveIwara`, Rust packages, npm packages).
- `preferLocalBuild = true` and license metadata affect CI/cache outcomes but not whether a package exists in `default.nix`.

## Example output

```text
| Package | Current | Latest | Status |
|---------|---------|--------|--------|
| LoveIwara | 0.5.0 | 0.5.0 | up to date |
| mihomo-smart | 166a207 | 166a207 | up to date |
| JMComic-qt | 1.3.0 | 1.3.0 | up to date |
```

## Useful evaluation helper

```bash
nix-instantiate --eval --strict --json --expr 'let repo = import ./. {}; in builtins.removeAttrs repo ["lib" "modules" "overlays"]'
```
