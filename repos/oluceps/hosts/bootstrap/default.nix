{ withSystem, self, inputs, ... }: {
  flake.nixosConfigurations.bootstrap = withSystem "x86_64-linux" (_ctx@{ config, inputs', system, ... }:
    let inherit (self) lib; in lib.nixosSystem
      {
        specialArgs = {
          inherit lib self inputs inputs';
          inherit (config) packages;
          inherit (lib) data;
          user = "elen";
        };
        modules = [
          ./configuration.nix
          ./disk-config.nix
          inputs.disko.nixosModules.disko
          {
            nixpkgs = {
              hostPlatform = lib.mkDefault system;
              overlays = with inputs;[
                agenix-rekey.overlays.default
                fenix.overlays.default
                self.overlays.default
              ];
            };
          }
        ];
      });
}
