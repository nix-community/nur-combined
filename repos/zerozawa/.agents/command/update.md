---
description: Update one exported package to a new upstream version
---

Update a single package exported from `default.nix`.

## Workflow

1. Find the package attr in `default.nix`.
2. Open the corresponding file under `pkgs/`.
3. Update version / rev / hash inputs.
4. Rebuild the package with `nix-build -A <package-name>`.
5. If needed, update repo docs when package inventory, naming, or behavior changed.

## Hash update methods

### Fake hash workflow

```nix
hash = lib.fakeHash;
```

Build once, copy the real hash from the failure output, then rebuild.

### Prefetch helpers

```bash
nix-prefetch-url --unpack "https://github.com/<owner>/<repo>/archive/refs/tags/v<version>.tar.gz"
nix-prefetch-github <owner> <repo> --rev v<version>
```

## Repo-specific reminders

- Rust packages may need `Cargo.lock` handling (`waybar-vd`).
- Flutter packages may need lock/hash refresh and CI sync validation (`Fladder`).
- Python GUI apps may need wrapper/runtime checks (`JMComic-qt`, `picacg-qt`).
- npm packages may need `npmDepsHash` refresh (`hyprland-mcp-server`).
- bun-built packages may need dependency/output hash refresh (`mcp-cli`).

## Examples

- `nix-build -A mihomo-smart`
- `nix-build -A Fladder`
- `nix-build -A hyprland-mcp-server`
