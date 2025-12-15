{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    daeuniverse.url = "github:daeuniverse/flake.nix";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };
  outputs =
    {
      self,
      nixpkgs,
      daeuniverse,
      nix-ai-tools,
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs {
            inherit system;
          };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );
      nixosModules = import ./modules;

      nixosConfigurations.nixo6n = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                shirok1 = import ./default.nix { pkgs = final; };
                nix-ai-tools = inputs.nix-ai-tools.packages.${final.system};
              })
            ];
          }

          ./nixos/o6n/configuration.nix

          inputs.daeuniverse.nixosModules.dae
          inputs.daeuniverse.nixosModules.daed

          self.nixosModules.qbittorrent-clientblocker
          self.nixosModules.snell-server
        ];
      };
    };
}
