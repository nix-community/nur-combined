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
      inherit lib inputs;
      inherit (lib) data;
      user = "nixos";
    };
    modules = [
      {
        nixpkgs = {
          hostPlatform = system;
        };
      }
      ./additions.nix
      "${self}/modules/sing-box.nix"
    ];
  }
)
