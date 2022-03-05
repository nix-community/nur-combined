# nix

Templates, user packages, modules, available as a NUR repo and a flake.

## Templates usage

### Listing templates
`nix flake show github:iagocq/nix`

### Using templates
`nix flake new -t github:iagocq/nix .`

`nix flake new -t github:iagocq/nix#generic .`

`nix flake new -t github:iagocq/nix#zig .`
