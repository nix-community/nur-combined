# crimsonvariable NUR packages

Nix package expressions maintained by Dominic Tscholl, writing as
crimsonvariable.

The repository is the Nix User Repository boundary for public FF00 applications.
Application source, release history, and project-specific documentation remain
in each application's own repository.

## Packages

| Attribute | Project | Status |
| --- | --- | --- |
| `ff00-vwm` | [FF00 Video Wallpaper Manager](https://crimsonvariable.com/projects/ff00-vwm/) | `0.1.0-alpha.1` |

## Local validation

```sh
nix build .#ff00-vwm
nix flake check
```

The package set is also consumable using the non-flake interface expected by
NUR:

```sh
nix-build -A ff00-vwm
```

## Installation after NUR registration

```nix
environment.systemPackages = [
  pkgs.nur.repos.crimsonvariable.ff00-vwm
];
```

NUR indexes community repositories but does not perform the package review or
provide the support guarantees of nixpkgs. Consumers should review expressions
before installation.

## Licensing

This repository and FF00 VWM are distributed under `AGPL-3.0-or-later`. The
package expression also identifies the upstream application's license for Nix
consumers. Copyright and contribution terms are published through
[crimsonvariable.com](https://crimsonvariable.com/).
