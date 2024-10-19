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
      overlays =
        (import "${self}/overlays.nix" { inherit inputs' inputs; })
        ++ (self.lib.genOverlays [
          "self"
          "fenix"
          "nuenv"
          "agenix-rekey"
          "berberman"
        ]);
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
      ./rekey.nix
      ./spec.nix
      ../persist.nix
      ../secureboot.nix
      ./backup.nix
      # inputs.home-manager.nixosModules.default
      # ../../home
      ../sysctl.nix
      ../../age
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
