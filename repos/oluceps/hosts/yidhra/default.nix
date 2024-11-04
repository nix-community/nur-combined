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
      inputs.disko.nixosModules.disko
      {
        nixpkgs = {
          hostPlatform = system;
          config = {
            # contentAddressedByDefault = true;
            allowUnfree = true;
          };
          overlays =
            (import ../../overlays.nix { inherit inputs inputs'; })
            ++ (lib.genOverlays [
              "self"
              "fenix"
              "nuenv"

            ]);
        };
      }

      ./disk.nix
      ./caddy.nix
      ../persist-base.nix
      ./boot.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      (lib.iage "cloud")
      ../../packages.nix
      ../../misc.nix
      ../../users.nix
    ];
  }
)
