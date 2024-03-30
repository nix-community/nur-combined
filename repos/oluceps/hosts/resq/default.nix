{ withSystem, self, inputs, ... }:
{
  flake.nixosConfigurations.resq = withSystem "x86_64-linux" (_ctx@{ config, inputs', system, ... }:
    let inherit (self) lib; in lib.nixosSystem
      {
        specialArgs = {
          inherit lib inputs;
          inherit (lib) data;
          user = "resq";
        };
        modules = [
          {
            nixpkgs = {
              hostPlatform = system;
              overlays = [ inputs.self.overlays.default ];
            };
          }
          # inputs.agenix-rekey.nixosModules.default
          # inputs.ragenix.nixosModules.default
          inputs.self.nixosModules.default
          ./additions.nix
          ./hastur-network-compatible.nix
        ];
      });
}
