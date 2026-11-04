# nur-packages

**phos-org's [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/phos-org/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Package | Description |
|---|---|
| [`hyprkbm`](pkgs/hyprkbm/default.nix) | [hyprKBM](https://github.com/phos-org/hyprKBM), a keyboard-first keybind manager for Hyprland's Lua config |

## Usage

With NUR set up (see [its README](https://github.com/nix-community/NUR#installation)):

```nix
environment.systemPackages = [ pkgs.nur.repos.phos-org.hyprkbm ];
```

Or straight from this repository:

```sh
nix profile install github:phos-org/nur-packages#hyprkbm
```
