# nh on nix-darwin

Import `darwinModules.nh` directly or through `nurRepos.davinci42.darwinModules.nh`.
Module-only imports support `pkgs = null`.

## Usage

```nix
{
  imports = [ (import /path/to/nur-packages { pkgs = null; }).darwinModules.nh ];
  programs.nh.enable = true;
  programs.nh.flake = "/Users/alice/nix-config";
}
```

Optional `programs.nh.clean.enable` schedules `nh clean all` as root via launchd.
`clean.interval` uses `nix.gc.interval` calendar syntax (default: Sunday 03:15).
`clean.extraArgs` defaults to `--no-direnv`; overrides replace it and are trusted
shell input. Do not enable alongside `nix.gc.automatic`.

## Tests

Local evaluation tests run on Linux or macOS, targeting `aarch64-darwin` without
building or activating Darwin software. From the repository root, supply matching
nix-darwin sources:

```sh
nix-shell --run 'just check-nh-darwin /absolute/path/to/nix-darwin-source'
```
