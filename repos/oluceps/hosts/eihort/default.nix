{
  withSystem,
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.eihort = withSystem "x86_64-linux" (
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
        {
          nixpkgs = {
            hostPlatform = system;
            config = {
              allowUnfree = true;
            };
            overlays =
              (import ../../overlays.nix inputs)
              ++ (lib.genOverlays [
                "self"
                "fenix"
                "nuenv"
                "agenix-rekey"
                "nixpkgs-wayland"
              ]);
          };
        }
        ./hardware.nix
        ./network.nix
        ./rekey.nix
        ./spec.nix
        ../../age.nix
        ../../packages.nix
        ../../misc.nix
        ../../users.nix

        inputs.disko.nixosModules.default
      ];
    }
  );
}
