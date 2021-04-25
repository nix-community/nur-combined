{
  description = "NixOS configuration with flakes";
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nur, home-manager, futils } @ inputs:
    let
      inherit (futils.lib) eachDefaultSystem;

      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib { inherit inputs; pkgs = nixpkgs; lib = self; };
      });

      defaultModules = [
        ({ ... }: {
          # Let 'nixos-version --json' know about the Git revision
          system.configurationRevision = self.rev or "dirty";
        })
        {
          nixpkgs.overlays = (lib.attrValues self.overlays) ++ [
            nur.overlay
          ];
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.users.ambroisie = import ./home;
          # Nix Flakes compatibility
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];

      buildHost = name: system: lib.nixosSystem {
        inherit system;
        modules = defaultModules ++ [
          (./. + "/${name}.nix")
        ];
        specialArgs = {
          # Use my extended lib in NixOS configuration
          inherit lib;
        };
      };
    in
    eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          apps = {
            diff-flake = futils.lib.mkApp { drv = packages.diff-flake; };
          };

          defaultApp = apps.diff-flake;

          devShell = pkgs.mkShell {
            name = "NixOS-config";
            buildInputs = with pkgs; [
              git-crypt
              gitAndTools.pre-commit
              gnupg
              nixpkgs-fmt
            ];
          };

          packages = import ./pkgs { inherit pkgs; };
        }) // {
      overlay = self.overlays.pkgs;

      overlays = {
        lib = final: prev: { inherit lib; };
        pkgs = final: prev: { ambroisie = import ./pkgs { pkgs = prev; }; };
      };

      nixosConfigurations = lib.mapAttrs buildHost {
        porthos = "x86_64-linux";
      };
    };
}
