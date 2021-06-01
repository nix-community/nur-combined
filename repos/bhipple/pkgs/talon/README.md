# Talon Beta Nix User Package

This NixPkgs User Repository contains an expression for building `talonvoice`.

## Quick Start
1. `git clone https://github.com/bhipple/nur-packages && cd nur-packages`

2. (Optional) Run `./pkgs/talon/talon-src <url>` to fetch the beta version. This
   requires a Patreon subscription. The `<url>` is the pinned link on the beta
   slack channel.

3. Build with `nix-build -E '(import <nixpkgs> {}).callPackage ./pkgs/talon {}'`

From here you can start talon with `./result/bin/talon`

## Systemd Unit
This provides a basic `systemd --user` service file for running `talon` with
reduced privileges.

## Contributions
Pull requests improving the nix expressions are welcome!
