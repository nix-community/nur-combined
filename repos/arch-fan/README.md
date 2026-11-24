# nur-packages

Personal [NUR](https://github.com/nix-community/NUR) package set (flake, `x86_64-linux`).

## Packages

| Package | Description |
| --- | --- |
| `limusic` | [Limusic](https://github.com/SimoHypers/limusic): native desktop YouTube Music client (Tauri, ad-free playback via libmpv), from the upstream `.deb` linked against nixpkgs libraries |
| `rpcs3-bin` | [RPCS3](https://rpcs3.net/) PlayStation 3 emulator, wrapped from the upstream nightly AppImage |

## Use

```console
nix run github:arch-fan/nur-packages#limusic
```

Through NUR (`nur.repos.arch-fan.limusic`) or as a flake input (NixOS example):

```nix
environment.systemPackages = [
  inputs.nur-packages.packages.x86_64-linux.limusic
  inputs.nur-packages.packages.x86_64-linux.rpcs3-bin
];
```

## Layout

`pkgs/<name>/package.nix` is picked up automatically as the package `<name>`
(`lib.packagesFromDirectoryRecursive`, the nixpkgs `by-name` convention). Write
packages in the `finalAttrs` style and keep fetch URLs interpolating the version,
so a bump is a two-line diff.

`nix fmt` formats everything (nixfmt); `nix flake check` builds every package and
runs the checks below.

### AppImage library check

NUR builds these packages against its users' nixpkgs, not this flake's lock, and
nixpkgs occasionally drops libraries from `appimageTools`' default FHS env. The
wrapper still builds, but the app dies at launch with
`error while loading shared libraries: libfoo.so: cannot open shared object file`.

`checks/appimage-libs.nix` catches that at build time. For every package that has
`contents` and `fhsenv` (i.e. built with `appimageTools.wrapType2` or
`wrapAppImage`), it fails if any bundled ELF needs a library that neither the
AppImage nor the FHS env provides. Fix a failure by adding the providing package
to `extraPkgs`. The check is wired up automatically; new AppImage packages need
nothing extra.

## Updates

A weekly workflow (`.github/workflows/update.yaml`, Mondays 00:00 UTC, also
manually dispatchable):

1. `nix flake update`: tracks nixos-unstable, so nixpkgs breakage surfaces here
   before NUR users hit it;
2. `nix run .#update`: runs `nix-update --flake --use-github-releases -u` on every
   package in `pkgs/`;
3. `nix flake check`: builds everything and runs the library check;

then opens a single auto-merged PR (`updates/packages`). Any failure stops the run
before the PR, and GitHub emails the failure.

`nix run .#update` works the same locally (set `GITHUB_TOKEN` to avoid the GitHub
API rate limit). Notes:

- nix-update comes from its upstream flake (the `nix-update` input), not nixpkgs,
  so fixes for new Nix releases arrive without waiting for nixos-unstable.
- Versions come from the GitHub releases API rather than the `releases.atom`
  feed, which also lists bare tags that may not have their assets yet; GitHub
  pre-releases are skipped.
- **Normal packages** need nothing special: nix-update rewrites `version` + `hash`.
- **Custom logic** goes in the derivation as `passthru.updateScript`, which `-u`
  runs instead; see `pkgs/rpcs3-bin` (nightly AppImage whose URL embeds a commit).
