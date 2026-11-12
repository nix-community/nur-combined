# Moraxyc's NUR Packages

![Build and populate cache](https://github.com/Moraxyc/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-moraxyc-blue.svg)](https://moraxyc.cachix.org)

## Updating packages

[fetchrix](https://github.com/Moraxyc/fetchrix) tracks sources in `fetchrix.toml`
and writes the lock file and extracted dependency files to `_sources/`. Its version
is pinned in `flake-modules/dev/flake.lock`.

`lib/fetchrix-lib.nix` is an unmodified copy of the pinned fetchrix
`nix/lib.nix` so restricted evaluation needs no network access to load it.
When updating the pin, also sync this copy.

```sh
nix develop -c update-packages                # Update all sources
nix develop -c update-packages hmcl-dev-bin   # Update one source
```

Set `GH_TOKEN` or `GITHUB_TOKEN` for GitHub authentication. `secrets.toml` is no
longer read.

# Thanks
 - [Lantian's NUR](https://github.com/xddxdd/nur-packages)
