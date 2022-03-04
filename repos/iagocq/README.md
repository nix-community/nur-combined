# nix

Nix flake things, like templates for miscellaneous projects, an overlay, and NixOS modules.

## Templates usage

### Listing templates
`nix flake show github:iagocq/nix-templates`

### Using templates
`nix flake new -t github:iagocq/nix-templates .`

`nix flake new -t github:iagocq/nix-templates#generic .`

`nix flake new -t github:iagocq/nix-templates#zig .`
