{ self
, flake-parts
, futils
, ...
} @ inputs:
let
  inherit (self) lib;

  mySystems = futils.lib.defaultSystems;
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
