{ ... }:

{
  imports = [
    ./apps.nix
    ./checks.nix
    ./devshells.nix
    ./flake-modules.nix
    ./lib.nix
    ./nixos-modules.nix
    ./nixpkgs.nix
    ./overlays.nix
    ./packages.nix
    ./treefmt.nix
  ];
}
