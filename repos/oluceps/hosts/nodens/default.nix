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
      ./disk.nix
      ./hardware.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      ../perlless.nix
      (lib.iage "cloud")
      ./caddy.nix
      ../persist-base.nix
      # ../../packages.nix
      ../../misc.nix
      ../../users.nix

      inputs.disko.nixosModules.disko
    ];
  }
)
