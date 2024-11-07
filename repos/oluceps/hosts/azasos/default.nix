# JD cloud Mon  1 Apr 17:05:22 +08 2024
{
  withSystem,
  self,
  inputs,
  ...
}:
withSystem "x86_64-linux" (
  _ctx@{
    config,
    inputs',
    system,
    ...
  }:
  let
    inherit (self) lib;
  in
  lib.nixosSystem {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
      overlays = lib.hostOverlays { inherit inputs inputs'; };
    };
    specialArgs = {
      inherit
        lib
        self
        inputs
        inputs'
        ;
      inherit (config) packages;
      inherit (lib) data;
      user = "elen";
    };
    modules = lib.sharedModules ++ [
      inputs.disko.nixosModules.default
      ./hardware.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      ./caddy.nix
      (lib.iage "cloud")
      ../../packages.nix
      ../../misc.nix
      ../../users.nix
    ];
  }
)
