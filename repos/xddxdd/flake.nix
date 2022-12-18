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
    rec {
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
      overlay = overlays.default;
      overlays = rec {
        default = final: prev: import ./pkgs {
          pkgs = prev;
          inherit inputs;
        };
        custom = nvidia_x11: final: prev: import ./pkgs {
          pkgs = prev;
          inherit inputs nvidia_x11;
        };
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

              # Workaround https://github.com/NixOS/nix/issues/6572
              for i in {1..3}; do
                ${pkgs.nix-build-uncached}/bin/nix-build-uncached ci.nix -A $1 --show-trace && exit 0
              done

              exit 1
            '');
          };

          update = {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "update" ''
              nix flake update
              ${pkgs.nvfetcher}/bin/nvfetcher -c nvfetcher.toml -o _sources
              ${pkgs.python3}/bin/python3 pkgs/openj9-ibm-semeru/update.py
              ${pkgs.python3}/bin/python3 pkgs/openjdk-adoptium/update.py
            '');
          };
        });

      nixosModules = {
        setupOverlay = { config, ... }: {
          nixpkgs.overlays = [
            (self.overlays.custom
              config.boot.kernelPackages.nvidia_x11)
          ];
        };
        qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix {
          inherit overlays packages lib;
        };
      };
    };
}
