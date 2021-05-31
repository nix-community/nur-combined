# Talon Beta Nix User Package

This NixPkgs User Repository contains an expression for building `talonvoice`.

## Quick Start
From a git clone of this repo:

1. (Optional) Run `./pkgs/talon/talon-src <url>` to fetch the beta version. This
   requires a Patreon subscription. The `<url>` is the pinned link on the beta
   slack channel.

2. Run `nix-build -E '(import <nixpkgs> {}).callPackage ./pkgs/talon {}'`

3. Run `./result/bin/talon`

## Systemd Unit
This provides a basic `systemd --user` service file for running `talon` with
reduced privileges.

## Contributions
Pull requests improving the nix expressions are welcome!

## TODO Items
- The latest non-beta src does not work (QT plugin error). I only use the beta
  version, though, and at some point latest will likely use the same QT, so just
  wait it out.
