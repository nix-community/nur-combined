# AGENTS.md

## Packaging

Follow nixpkgs' packaging conventions.

- As long as they they are supported by build system, enable `strictDeps` and `__structuredAttrs`, and define the derivation with `finalAttrs`.

## Verification

- Formatting: `nix develop -c nixfmt .`
- Full static check must pass before finishing: `nix develop -c bash -c 'nixfmt --check . && statix check .'` and `nix flake check --no-build`.
