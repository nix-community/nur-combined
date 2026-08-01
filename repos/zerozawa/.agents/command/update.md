---
description: Update one exported package to a new upstream version
---

Update a single package exported from `default.nix`.

## Workflow

1. Find the package attr in `default.nix`.
2. Open the corresponding file under `pkgs/`.
3. Update version / rev / hash inputs.
4. **Check `meta.description`**: it must match the upstream project's own one-line pitch. Do NOT write it yourself — open the upstream repo (GitHub/GitLab/other) README and copy the most concise tagline or slogan verbatim from the first line(s). Update the `description` if it drifted or is stale.
5. Rebuild the package with `nix-build -A <package-name>`.
6. **Test runtime dependencies**: run the built binary (`result/bin/<name> --help` or equivalent) to catch missing shared library errors (e.g. `libICE.so.6`). If it crashes on a missing `lib*.so`, add it to `runtimeDeps` / `buildInputs` / `propagatedBuildInputs`, rebuild, and re-test.
7. If needed, update repo docs when package inventory, naming, or behavior changed.

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
- Flutter packages may need pub-lock refresh and native-asset validation (`LoveIwara`).
- Python GUI apps may need wrapper/runtime checks (`JMComic-qt`, `picacg-qt`).
- npm packages may need `npmDepsHash` refresh (`codegraph`).
- bun-built packages may need dependency/output hash refresh (`mcp-cli`).
- **`oh-my-pi`**: after updating hashes, run the full ELF verification from
  `pkgs/oh-my-pi/AGENTS.md` step 4. Restart omp and check `~/.omp/logs/` for
  `libonnxruntime`, `libstdc++`, or `VERS_` errors (step 5).

## Examples

- `nix-build -A mihomo-smart`
- `nix-build -A LoveIwara`
- `nix-build -A deskbrid`
