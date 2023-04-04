{ self
, flake-parts
, futils
, ...
} @ inputs:
let
  inherit (self) lib;

  inherit (futils.lib) system;

  mySystems = [
    system.aarch64-darwin
    system.aarch64-linux
    system.x86_64-darwin
    system.x86_64-linux
  ];
in
flake-parts.lib.mkFlake { inherit inputs; } {
  systems = mySystems;

  imports = [
    ./apps.nix
    ./checks.nix
    ./dev-shells.nix
    ./home-manager.nix
    ./lib.nix
    ./nixos.nix
    ./overlays.nix
    ./packages.nix
    ./templates.nix
  ];
}
