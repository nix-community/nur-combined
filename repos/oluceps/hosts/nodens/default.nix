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
          "cinny-4.2.1"
          "cinny-unwrapped-4.2.1"
        ];
      };
      overlays =
        (import "${self}/overlays.nix" { inherit inputs' inputs; })
        ++ (self.lib.genOverlays [
          "self"
          "nuenv"
          "agenix-rekey"
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
      ./caddy.nix
      ../../age
      ../../packages.nix
      ../../misc.nix
      ../../users.nix

      inputs.factorio-manager.nixosModules.default
      inputs.tg-online-keeper.nixosModules.default
    ];
  }
)
