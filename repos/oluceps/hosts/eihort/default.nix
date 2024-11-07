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
      config = { };
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
      ./rekey.nix
      ./spec.nix
      ./caddy.nix
      ./sysctl.nix
      ../persist.nix
      (lib.iage "trust")
      ../../packages.nix
      ../../misc.nix
      ../../users.nix

      inputs.disko.nixosModules.default
    ];
  }
)
