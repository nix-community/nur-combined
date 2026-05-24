Nix Flakes
==========

My collection of Nix flakes for third–party software

Developing
----------

To build a package, run:
```sh
nix build .#package # Using flakes.

nix-build --arg pkgs 'import <nixpkgs> {}' -A package # Without flakes.
```
