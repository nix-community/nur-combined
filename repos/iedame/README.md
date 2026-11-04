# Rafael Ieda's Nix User Repository

[![CI](https://github.com/iedame/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/iedame/nur-packages/actions/workflows/build.yml)
[![Cachix](https://img.shields.io/badge/cachix-iedame-blue.svg)](https://iedame.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository: packages
and NixOS modules I use on my own machines. Use them at your own risk.

## What's here

| Name | Kind | Platforms | What it is |
|---|---|---|---|
| `jagex-launcher` | package (unfree) | x86_64-linux | The Jagex Launcher for RuneScape and Old School RuneScape, from Jagex's Linux AppImage |
| `openrsc-launcher` | package | Linux, macOS | The Open RuneScape Classic launcher, for the classic (2001-2004) RuneScape servers; from NixOS/nixpkgs#460098 until that is merged |
| `runescape` | NixOS module | x86_64-linux | The launcher plus RuneLite, with the fix that makes "Play" start RuneLite on NixOS |

Unfree packages need `allowUnfree` (or an `allowUnfreePredicate` naming
them) in the configuration that uses them. They are left out of NUR's
package search, as NUR evaluates without allowing them, and never go to
the Cachix cache.

## Using it

### As a flake input (recommended)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-iedame.url = "github:iedame/nur-packages";
    nur-iedame.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then, in a NixOS configuration:

- a package: `inputs.nur-iedame.packages.${system}.jagex-launcher`, or add
  `inputs.nur-iedame.overlays.default` to `nixpkgs.overlays` and use
  `pkgs.jagex-launcher`;
- a module: add `inputs.nur-iedame.nixosModules.runescape` to `imports`.

The overlay and the modules build with your nixpkgs and your unfree
setting. `packages` builds with this repository's pinned nixpkgs (or
yours, with `follows`), with unfree allowed for its own packages.

### Through NUR

Once the repository is listed in NUR (nix-community/NUR#1266), and with
[NUR](https://github.com/nix-community/NUR#installation) set up: a package
as `pkgs.nur.repos.iedame.openrsc-launcher`, and the module as
`nur.repos.iedame.modules.nixos.runescape`.

### Without installing

```sh
nix run github:iedame/nur-packages#jagex-launcher
```

## Binary cache

CI pushes the free packages to [iedame.cachix.org](https://iedame.cachix.org)
from `main`:

```nix
nix.settings = {
  extra-substituters = [ "https://iedame.cachix.org" ];
  extra-trusted-public-keys = [ "iedame.cachix.org-1:ULOEEwdkoANx+gj1//8s4DhstfTSipDWNKISwt5GUec=" ];
};
```

## Adding a package

1. Put it in `pkgs/<name>/package.nix`, written for `callPackage`, and add
   it to `default.nix`. Set `meta.platforms`, `meta.license` (unfree
   ones are never cached) and `meta.broken` when it applies.
2. NixOS modules go in `modules/` and in `modules/default.nix`.
3. `nix fmt`, then `nix flake check --all-systems`.

CI (`.github/workflows/build.yml`) checks every pull request: the flake, the
formatting, the evaluation NUR does, and a build of every package on
x86_64-linux, aarch64-linux and aarch64-darwin.

`flake.lock` (nixpkgs) is updated weekly by a pull request from a bot
(`.github/workflows/flake-update.yml`), which that CI checks before it is
merged. NUR doesn't use the lock: it evaluates `default.nix` with its own
nixpkgs.

## License

[MIT](./LICENSE), for the Nix code here. The packages keep their own
licences.
