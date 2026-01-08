{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    daeuniverse.url = "github:daeuniverse/flake.nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      daeuniverse,
      llm-agents,
      home-manager,
      catppuccin,
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      pkgsOverlays = {
        nixpkgs.overlays = [
          (final: prev: {
            shirok1 = import ./default.nix { pkgs = final; };
            llm-agents = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system};
          })
        ];
      };
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
          pkgsOverlays

          ./nixos/machines/o6n/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.shiroki = {
              imports = [
                ./home.nix
                catppuccin.homeModules.catppuccin
              ];
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = {
              machine = "o6n";
            };
          }

          inputs.daeuniverse.nixosModules.dae
          inputs.daeuniverse.nixosModules.daed

          catppuccin.nixosModules.catppuccin
          {
            catppuccin.cache.enable = true;
          }

          self.nixosModules.qbittorrent-clientblocker
          self.nixosModules.snell-server
        ];
      };

      nixosConfigurations.nixopi5 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          pkgsOverlays

          ./nixos/machines/opi5/configuration.nix

          inputs.daeuniverse.nixosModules.dae
          inputs.daeuniverse.nixosModules.daed

          self.nixosModules.qbittorrent-clientblocker
          self.nixosModules.snell-server
        ];
      };
    };
}
