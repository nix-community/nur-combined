{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-utils-plus,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
  in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;
      channels.nixpkgs = {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-11.5.0"
            "electron-19.1.9"
            "openssl-1.1.1w"
            "python-2.7.18.7"
          ];
        };
        input = inputs.nixpkgs;
      };

      outputsBuilder = channels: let
        pkgs = channels.nixpkgs;
        inherit (pkgs) system;
        inherit (pkgs.callPackage ./helpers/flatten-pkgs.nix {}) flattenPkgs;

        isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
        outputsOf = p: map (o: p.${o}) p.outputs;

        commands =
          lib.mapAttrs
          (n: v: pkgs.writeShellScriptBin n v)
          rec {
            ci = ''
              set -euo pipefail
              if [ "$1" == "" ]; then
                echo "Usage: ci <system>";
                exit 1;
              fi

              # Workaround https://github.com/NixOS/nix/issues/6572
              for i in {1..3}; do
                ${pkgs.nix-build-uncached}/bin/nix-build-uncached ci.nix -A $1 --show-trace && exit 0
              done

              exit 1
            '';

            nvfetcher = ''
              set -euo pipefail
              KEY_FLAG=""
              [ -f "$HOME/Secrets/nvfetcher.toml" ] && KEY_FLAG="$KEY_FLAG -k $HOME/Secrets/nvfetcher.toml"
              [ -f "secrets.toml" ] && KEY_FLAG="$KEY_FLAG -k secrets.toml"
              export PATH=${pkgs.nix-prefetch-scripts}/bin:$PATH
              ${inputs.nvfetcher.packages."${system}".default}/bin/nvfetcher $KEY_FLAG -c nvfetcher.toml -o _sources "$@"
              ${readme}
            '';

            nur-check = ''
              set -euo pipefail
              TMPDIR=$(mktemp -d)
              FLAKEDIR=$(pwd)

              git clone --depth=1 https://github.com/nix-community/NUR.git "$TMPDIR"
              cd "$TMPDIR"
              bin/nur eval "$FLAKEDIR"
              cd "$FLAKEDIR"
              rm -rf "$TMPDIR"
            '';

            readme = ''
              set -euo pipefail
              nix build .#_meta.readme
              cat result > README.md
            '';

            trace = ''
              rm -rf trace.txt*
              strace -ff --trace=%file -o trace.txt "$@"
            '';

            update = let
              py = pkgs.python3.withPackages (p: with p; [requests]);
            in ''
              set -euo pipefail
              nix flake update
              ${nvfetcher}
              ${py}/bin/python3 pkgs/asterisk-digium-codecs/update.py
              ${py}/bin/python3 pkgs/nvidia-grid/update.py
              ${py}/bin/python3 pkgs/openj9-ibm-semeru/update.py
              ${py}/bin/python3 pkgs/openjdk-adoptium/update.py
              ${readme}
            '';
          };
      in rec {
        packages = import ./pkgs null {
          inherit inputs pkgs;
        };
        packageNames = lib.mapAttrsToList (k: v: k) (flattenPkgs packages);

        ciPackages =
          flattenPkgs
          (import ./pkgs "ci" {
            inherit inputs pkgs;
          });
        ciPackageNames = lib.mapAttrsToList (k: v: k) ciPackages;
        ciOutputs = lib.mapAttrsToList (_: outputsOf) (lib.filterAttrs (_: isBuildable) ciPackages);

        formatter = pkgs.alejandra;

        apps = lib.mapAttrs (n: v: flake-utils.lib.mkApp {drv = v;}) commands;
      };

      overlay = self.overlays.default;
      overlays = {
        default = final: prev:
          import ./pkgs null {
            pkgs = prev;
            inherit inputs;
          };
      };

      nixosModules = {
        setupOverlay = {config, ...}: {
          nixpkgs.overlays = [
            self.overlays.default
          ];
        };
        openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
      };
    };
}
