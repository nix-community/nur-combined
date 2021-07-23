{
  description = "Nixos configuration with flakes";
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-21.05";
    };

    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable-small";
    };

    emacs-overlay = {
      type = "github";
      owner = "nix-community";
      repo = "emacs-overlay";
      ref = "master";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "master";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @inputs: {
    nixosModules = {
      home = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.alarsyo = import ./home;
        home-manager.verbose = true;
      };
    };

    nixosConfigurations =
      let
        system = "x86_64-linux";
        shared_overlays = [
          (self: super: {
            packages = import ./pkgs { pkgs = super; };

            # packages accessible through pkgs.unstable.package
            unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          })
        ];
      in {

        poseidon = nixpkgs.lib.nixosSystem rec {
          inherit system;
          modules = [
            ./poseidon.nix

            home-manager.nixosModule
            self.nixosModules.home

            {
              nixpkgs.overlays = [
                (self: super: {
                  fastPython3 = self.python3.override {
                    enableOptimizations = true;
                    reproducibleBuild = false;
                    self = self.fastPython3;
                    pythonAttr = "fastPython3";
                  };

                  matrix-synapse = super.matrix-synapse.override {
                    python3 = self.fastPython3;
                  };
                })
              ] ++ shared_overlays;
            }
          ];
        };

        boreal = nixpkgs.lib.nixosSystem rec {
          inherit system;
          modules = [
            ./boreal.nix

            home-manager.nixosModule
            self.nixosModules.home

            {
              nixpkgs.overlays = [
                inputs.emacs-overlay.overlay

                (self: super: {
                  steam = self.unstable.steam;
                })

                # uncomment this to build everything from scratch, fun but takes a
                # while
                #
                # (self: super: {
                #   stdenv = super.impureUseNativeOptimizations super.stdenv;
                # })
              ] ++ shared_overlays;
            }
          ];
        };

        zephyrus = nixpkgs.lib.nixosSystem rec {
          inherit system;
          modules = [
            ./zephyrus.nix

            home-manager.nixosModule
            self.nixosModules.home

            {
              nixpkgs.overlays = [
                inputs.emacs-overlay.overlay

                (self: super: {
                  steam = self.unstable.steam;
                })
              ] ++ shared_overlays;
            }
          ];
        };

      };
  } // inputs.flake-utils.lib.eachDefaultSystem (system: {
    packages =
      inputs.flake-utils.lib.flattenTree
        (import ./pkgs { pkgs = import nixpkgs { inherit system; }; });
  });
}
