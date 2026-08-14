# python27

Vendored CPython 2.7.18 (ActiveState security fork) after nixpkgs dropped top-level `python27`.

## Upstream (nixpkgs)

Copied from nixpkgs commit [`55280fa56481cd71b53545171eb9ec5ab44c3795`](https://github.com/NixOS/nixpkgs/commit/55280fa56481cd71b53545171eb9ec5ab44c3795) (revision immediately before 2.7 was moved toward resholve and removed). Removal: [`e6871d9800ef`](https://github.com/NixOS/nixpkgs/commit/e6871d9800efed3395535a879e323b546d96feab) (PR #516241).

Upstream path: `pkgs/development/interpreters/python/cpython/2.7/` (`default.nix` plus patches). There was never a `python.nix` in that directory; a 404 HTML stub of that name used to sit here by mistake and broke `nix fmt`.

## Local layout

| File | Role |
| --- | --- |
| `package.nix` | NUR `callPackage` entry (version, hash, setup hook) |
| `default.nix` | Interpreter derivation (nixpkgs 2.7 builder) |
| `*.patch`, `setup-hook.sh`, `sitecustomize.py` | From that nixpkgs tree |

Nothing else in this repo depends on `python27`; it is offered as a standalone insecure interpreter (`permittedInsecurePackages` in the flake).
