{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    keycloak-lantian = {
      url = "git+https://git.lantian.pub/lantian/keycloak-lantian.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      lib = nixpkgs.lib;
      eachSystem = flake-utils.lib.eachSystemMap flake-utils.lib.allSystems;
    in
    {
      inherit eachSystem lib;

      packages = eachSystem (system: import ./pkgs {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        ci = false;
        inherit inputs;
      });

      ciPackages = eachSystem (system: import ./pkgs {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        ci = true;
        inherit inputs;
      });

      # Following line doesn't work for infinite recursion
      # overlay = self: super: packages."${super.system}";
      overlay = self: super: import ./pkgs {
        pkgs = import nixpkgs {
          inherit (super) system;
          config.allowUnfree = true;
        };
        inherit inputs;
      };

      apps = eachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          ci = {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "ci" ''
              if [ "$1" == "" ]; then
                echo "Usage: ci <system>";
                exit 1;
              fi

              ${pkgs.nix-build-uncached}/bin/nix-build-uncached ci.nix -A $1
            '');
          };

          nvfetcher = {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "nvfetcher" ''
              ${pkgs.nvfetcher}/bin/nvfetcher -c nvfetcher.toml -o _sources
            '');
          };
        });

      nixosModules = import ./modules;
    };
}
