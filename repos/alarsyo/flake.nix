{
  description = "Nixos configuration with flakes";
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    nixpkgs-unstable-small = {
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
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "master";
    };

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
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
      nix-path = {
        nix.nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
        ];
      };
    };

    overlays = import ./overlays;

    nixosConfigurations =
      let
        system = "x86_64-linux";
        shared_overlays = [
          (self: super: {
            packages = import ./pkgs { pkgs = super; };

            # packages accessible through pkgs.unstable.package
            unstable = import inputs.nixpkgs-unstable-small {
              inherit system;
              config.allowUnfree = true;
            };
          })
        ] ++ builtins.attrValues self.overlays;
        sharedModules = [
          home-manager.nixosModule
          { nixpkgs.overlays = shared_overlays; }
        ] ++ (nixpkgs.lib.attrValues self.nixosModules);
      in {

        poseidon = nixpkgs.lib.nixosSystem rec {
          inherit system;
          modules = [
            ./poseidon.nix
          ] ++ sharedModules;
        };

        boreal = nixpkgs.lib.nixosSystem rec {
          inherit system;
          modules = [
            ./boreal.nix

            {
              nixpkgs.overlays = [
                inputs.emacs-overlay.overlay

                # uncomment this to build everything from scratch, fun but takes a
                # while
                #
                # (self: super: {
                #   stdenv = super.impureUseNativeOptimizations super.stdenv;
                # })
              ];
            }
          ] ++ sharedModules;
        };

        zephyrus = nixpkgs.lib.nixosSystem rec {
          inherit system;
          modules = [
            ./zephyrus.nix

            inputs.nixos-hardware.nixosModules.common-cpu-intel
            inputs.nixos-hardware.nixosModules.common-pc-laptop
            inputs.nixos-hardware.nixosModules.common-pc-ssd

            {
              nixpkgs.overlays = [
                inputs.emacs-overlay.overlay
              ];
            }
          ] ++ sharedModules;
        };

      };
  } // inputs.flake-utils.lib.eachDefaultSystem (system: {
    packages =
      (
        inputs.flake-utils.lib.flattenTree
        (import ./pkgs { pkgs = import nixpkgs { inherit system; }; })
      ) // {
        emacsPgtkGcc = (
          import nixpkgs {
            inherit system;
            overlays = [ inputs.emacs-overlay.overlay ];
          }
        ).emacsPgtkGcc;
      };
  });
}
