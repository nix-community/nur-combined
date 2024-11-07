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
      ../home.nix
      ./hardware.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      ../persist.nix
      ../secureboot.nix
      ./backup.nix
      # inputs.home-manager.nixosModules.default
      # ../../home
      ../sysctl.nix
      (lib.iage "trust")
      ../../packages.nix
      ../../misc.nix
      ../../users.nix
      ../sysvars.nix
      inputs.niri.nixosModules.niri
      ../graphBase.nix
      ../dev.nix

      ./caddy.nix
      ../pam.nix
      ../virt.nix

      inputs.aagl.nixosModules.default
      inputs.disko.nixosModules.default
      inputs.tg-online-keeper.nixosModules.default
      # inputs.attic.nixosModules.atticd
      # inputs.factorio-manager.nixosModules.default
    ];
  }
)
