---
name: nix
description: Write NixOS/home-manager modules with options, config, and tests. Use when creating or modifying NixOS/home-manager modules, defining custom options, or generating test.nix files.
---

## References

The Agent should be aware of the following Nix expression mappings:

- Nixpkgs Source: (builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs.outPath
- Home Manager Source: (builtins.getFlake (builtins.toString ./.)).inputs.home-manager.outPath
- NixOS Options: (builtins.getFlake (toString ./.)).nixosConfigurations.local.options
- Home Manager Options: (builtins.getFlake (builtins.toString ./.)).nixosConfigurations.local.options.home-manager.users.type.getSubOptions []
