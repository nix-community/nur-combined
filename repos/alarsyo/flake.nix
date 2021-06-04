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
  };

  outputs = { self,
              nixpkgs,
              nixpkgs-unstable,
              emacs-overlay,
              home-manager }: {
    nixosConfigurations.poseidon = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./poseidon.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.alarsyo = import ./home;
          home-manager.verbose = true;
        }

        {
          nixpkgs.overlays = [
            (final: prev: {
              # packages accessible through pkgs.unstable.package
              unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
            })
          ];
        }
      ];
    };
    nixosConfigurations.boreal = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./boreal.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.alarsyo = import ./home;
          home-manager.verbose = true;
        }

        {
          nixpkgs.overlays = [
            emacs-overlay.overlay

            (self: super: {
              packages = import ./pkgs { pkgs = super; };

              unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };

              steam = self.unstable.steam;
            })

            # uncomment this to build everything from scratch, fun but takes a
            # while
            #
            # (self: super: {
            #   stdenv = super.impureUseNativeOptimizations super.stdenv;
            # })
          ];
        }
      ];
    };
  };
}
