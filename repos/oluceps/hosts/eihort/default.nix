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
        permittedInsecurePackages = [
          "olm-3.2.16"
        ];
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

      ./hardware.nix
      ./network.nix
      ./backup.nix
      ./rekey.nix
      ./spec.nix
      ./caddy.nix
      ../sysctl-boost.nix
      ./bees.nix
      ../persist.nix
      ../secureboot.nix
      ../sysvars.nix
      ../dev.nix
      # ../perlless.nix
      (lib.iage "trust")
      ../../packages.nix
      ../../misc.nix
      ../../users.nix

      inputs.disko.nixosModules.default
      # inputs.nixos-facter-modules.nixosModules.facter
      inputs.tg-online-keeper.nixosModules.default
    ];
  }
)
