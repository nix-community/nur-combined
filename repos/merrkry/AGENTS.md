# AGENTS.md

## Packaging

Follow nixpkgs' packaging conventions.

- When supported by the build system, enable `strictDeps` and `__structuredAttrs`, and define the derivation with `finalAttrs`.
- Keep this directory usable as a standalone NUR repository. Its Nix expressions must use the supplied `pkgs` and files within this directory.
