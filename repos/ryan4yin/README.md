# Ryan Yin's Nix User Repository

[![Build Status](https://github.com/ryan4yin/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)](https://github.com/ryan4yin/nur-packages)
[![Ryan Yin's Cachix Cache](https://img.shields.io/badge/cachix-ryan4yin-blue.svg)](https://ryan4yin.cachix.org)

**My personal [NUR](https://github.com/nix-community/NUR) repository**, use it at your own risk.

## How to use

> **NOTE**: To follow the following usage, you need to have [Nix](https://nixos.org/nix/) installed with `flakes` & `new-comands` enabled first.

Run packages directly from this repository(no cache):

```sh
nix run github:ryan4yin/nur-packages#some-pakcage
```

Use this repository in `flake.nix`:

```nix
# flake.nix
{
  # the nixConfig here only affects the flake itself, not the system configuration!
  # for more information, see:
  #     https://nixos-and-flakes.thiscute.world/nixos-with-flakes/add-custom-cache-servers
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [ "https://ryan4yin.cachix.org" ];
    extra-trusted-public-keys = [ "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur-ryan4yin, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = with pkgs; [
            # Add packages from this repo
            nur-ryan4yin.packages.${system}.some-package
          ];
        })
      ];
    };
  };
}
```

## Automated updates

Packages expose a passthru.updateScript; rime-data-flypy is a manually
vendored snapshot and intentionally has none. Two scheduled workflows keep the
repository fresh:

* **Update packages** (.github/workflows/update-packages.yml) runs daily (and
  on demand) and opens one pull request per outdated package.
* **Update flake inputs** (.github/workflows/update-flake-inputs.yml) runs
  weekly (and on demand), bumps every flake input in flake.lock and commits
  the result straight to main, without opening a pull request.

Run an updater locally from the repository root:

    nix run .#dsh.updateScript

Discovery treats any package exposing updateScript as updatable, so new
packages are picked up automatically.

Both workflows use the default GITHUB_TOKEN, so they need write access to the
repository contents: Settings -> Actions -> General -> Workflow permissions ->
"Read and write permissions". The package workflow additionally needs "Allow
GitHub Actions to create and approve pull requests".

Events triggered by GITHUB_TOKEN do not start other workflows, so the package
job builds each updated package before opening its PR, and the flake input job
evaluates the repository before pushing.

## Notes for myself

1. Add your packages to the [pkgs](./pkgs) directory and to
   [default.nix](./default.nix)
   * Remember to mark the broken packages as `broken = true;` in the `meta`
     attribute, or travis (and consequently caching) will fail!
   * Library functions, modules and overlays go in the respective directories
2. [Add yourself to NUR](https://github.com/nix-community/NUR#how-to-add-your-own-repository) if you want to share your packages.

## LICENSE

[MIT](./LICENSE)
