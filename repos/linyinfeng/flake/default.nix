{ ... }:

{
  imports = [
    ./checks.nix
    ./devshells.nix
    ./flake-modules.nix
    ./lib.nix
    ./nixos-modules.nix
    ./overlays.nix
    ./packages.nix
    ./treefmt.nix
  ];
}
