{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    daeuniverse.url = "github:daeuniverse/flake.nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    rules.url = "github:shirok1/rules.nix";
    rules.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    {
      self,
      nixpkgs,
      daeuniverse,
      llm-agents,
      home-manager,
      catppuccin,
      sops-nix,
      rules,
      flake-parts,
    }@inputs:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        imports = [
          # Optional: use external flake logic, e.g.
          inputs.flake-parts.flakeModules.easyOverlay
        ];
        flake =
          # Put your original flake attributes here.
          let
            inherit (inputs.flake-parts.lib) importApply;
            pkgsOverlays = {
              nixpkgs.overlays = [
                self.overlays.default
                inputs.llm-agents.overlays.default
                inputs.rules.overlays.default
              ];
            };
          in
          {
            nixosModules = import ./modules {
              inherit importApply withSystem;
              localFlake = self;
            };

            nixosConfigurations =
              let
                mkSystem =
                  machine: extraModules:
                  nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit inputs; };
                    modules = [
                      pkgsOverlays

                      (./. + "/nixos/machines/${machine}/configuration.nix")

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
                          inherit machine;
                        };
                      }

                      inputs.daeuniverse.nixosModules.dae
                      inputs.daeuniverse.nixosModules.daed

                      catppuccin.nixosModules.catppuccin
                      {
                        catppuccin.cache.enable = true;
                      }
                    ] ++ extraModules;
                  };
              in
              {
                nixo6n = mkSystem "o6n" [
                  sops-nix.nixosModules.sops
                  {
                    sops = {
                      environment = {
                        SOPS_AGE_SSH_PRIVATE_KEY_FILE = "/etc/ssh/ssh_host_ed25519_key";
                      };
                    };
                  }
                  self.nixosModules.qbittorrent-clientblocker
                  self.nixosModules.snell-server
                ];

                nixopi5 = mkSystem "opi5" [
                  self.nixosModules.msd-lite
                  self.nixosModules.qbittorrent-clientblocker
                  self.nixosModules.snell-server
                ];
              };
          };
        systems =
          # systems for which you want to build the `perSystem` attributes
          nixpkgs.lib.systems.flakeExposed;
        perSystem =
          {
            config,
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs = import self.inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

            overlayAttrs.shirok1 = config.packages;

            packages = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
              inherit (pkgs) callPackage;
              directory = ./pkgs;
            };

            # Expose tcp-brutal so users can manually build and test it against different kernels.
            # Not placed in pkgs/ to avoid it being automatically discovered and breaking CI checks.
            legacyPackages = {
              tcp-brutal = pkgs.linuxPackages.callPackage ./_pkgs/tcp-brutal.nix { };
              tcp-brutal-latest = pkgs.linuxPackages_latest.callPackage ./_pkgs/tcp-brutal.nix { };
            };
          };
      }
    );
}
