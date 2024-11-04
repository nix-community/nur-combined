/*
  Wed 20 Mar 23:41:49 +08 2024

  Azure korea nixos-anywhere apply success
*/
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
    };
    modules = [
      ./configuration.nix
      # ./UEFI
      ./BIOS
      inputs.disko.nixosModules.disko
      {
        nixpkgs = {
          hostPlatform = lib.mkDefault system;
          overlays = with inputs; [
            fenix.overlays.default
            self.overlays.default
          ];
        };
      }
    ];
  }
)
