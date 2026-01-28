# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/unstable-code/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Package | Description |
|---------|-------------|
| `wshowlyrics` | Wayland Lyrics Overlay inspired by LyricsX (stable) |
| `wshowlyrics-unstable` | Wayland Lyrics Overlay inspired by LyricsX (nightly) |

## Usage

### With Flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-unstable-code.url = "github:unstable-code/nur-packages";
  };

  outputs = { self, nixpkgs, nur-unstable-code, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            nur-unstable-code.packages.${pkgs.system}.wshowlyrics
          ];
        })
      ];
    };
  };
}
```

### With NUR (after registration)

```nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nur.repos.unstable-code.wshowlyrics
  ];
}
```
