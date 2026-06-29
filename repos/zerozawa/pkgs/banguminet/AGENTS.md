# BangumiNet — Nix Packaging Guide

## Architecture

```
pkgs/banguminet/
├── default.nix    # buildDotnetModule definition
├── deps.json      # Pre-computed NuGet dependency hashes
└── AGENTS.md      # ← this file
```

Avalonia (.NET) desktop client for Bangumi. Built with `buildDotnetModule` using
`dotnet-sdk_10_0`.

## Updating

### Version bump

1. Change `version` and `src.hash` in `default.nix`.
2. Regenerate `deps.json` (see below).
3. Build: `nix-build -A banguminet`

### Regenerating deps.json

`buildDotnetModule` requires `nugetDeps = ./deps.json` (a file path, not a
hash string — `cargoHash`-style doesn't work here).

To regenerate:

```bash
# 1. Download source
cd /tmp && rm -rf bangumi-nuget && mkdir bangumi-nuget && cd bangumi-nuget
curl -sL "https://github.com/ajtn123/BangumiNet/archive/refs/tags/v1.1.3.tar.gz" \
  | tar xz --strip=1

# 2. Restore NuGet packages (uses system nixpkgs dotnet SDK)
nix shell nixpkgs#dotnet-sdk_10 --command dotnet restore BangumiNet/BangumiNet.csproj \
  --packages /tmp/bangumi-nuget/packages

# 3. Generate deps.json
cd /tmp/bangumi-nuget/packages
python3 << 'PYEOF'
import os, json, hashlib, base64
from pathlib import Path

results = []
for pkg_dir in sorted(Path("/tmp/bangumi-nuget/packages").iterdir()):
    if not pkg_dir.is_dir():
        continue
    pname = pkg_dir.name
    for ver_dir in sorted(pkg_dir.iterdir()):
        if not ver_dir.is_dir():
            continue
        version = ver_dir.name
        nupkg = ver_dir / f"{pname}.{version}.nupkg"
        if not nupkg.exists():
            nupkg = ver_dir / f"{pname}.{version}.tar.gz"
        if not nupkg.exists():
            continue
        sha256 = hashlib.sha256()
        with open(nupkg, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)
        results.append({
            "pname": pname,
            "version": version,
            "hash": "sha256-" + base64.b64encode(sha256.digest()).decode()
        })

with open("/path/to/nur/pkgs/banguminet/deps.json", "w") as f:
    json.dump(results, f, indent=2)
PYEOF
```

Then `nix-build -A banguminet` to verify.

## Hazards

- `deps.json` lists every NuGet dependency with its hash. Version bumps often
  change package versions (e.g., `Avalonia 12.0.4 → 12.0.5`) — regeneration
  is required.
- The `dotnet-sdk` version (`sdk_10_0`) must match what the project targets.
  Check `BangumiNet.csproj` for the target framework.
- `buildDotnetModule` handles native library patching (SkiaSharp,
  HarfBuzzSharp) automatically via `autoPatchelfHook`.
- `executables = [ "BangumiNet" ]` + `postInstall` symlink creates
  `bin/banguminet` as the user-facing command.
