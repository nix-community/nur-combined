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
          overlays = lib.hostOverlays { inherit inputs inputs'; };
        };
      }

      ./disk.nix
      ./boot.nix
      ./caddy.nix
      # ./cluster.nix
      ../persist-base.nix
      ./network.nix
      ../sysctl.nix
      ../perlless.nix
      ./rekey.nix
      ./spec.nix
      (lib.iage "cloud")
      # ../../packages.nix
      ../../misc.nix
      ../../users.nix
    ];
  }
)
