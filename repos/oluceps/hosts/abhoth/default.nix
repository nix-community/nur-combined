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
          "android-nixpkgs"
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
      ../sysvars.nix
      ./hardware.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      ../../age
      ./caddy.nix
      # ../../packages.nix
      ../../misc.nix
      ../../users.nix
    ];

  }
)
