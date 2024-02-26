{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

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
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    supportedSystems = ["x86_64-linux" "aarch64-linux"];

    pkgsForSystem = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-11.5.0"
            "electron-19.1.9"
            "openssl-1.1.1w"
            "python-2.7.18.7"
          ];
        };
      };
  in
    (flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = pkgsForSystem system;
      inherit (pkgs.callPackage ./helpers/is-buildable.nix {}) isBuildable;
      makeAppsShell = pkgs.callPackage ./helpers/make-apps-shell.nix {};
      outputsOf = p: map (o: p.${o}) p.outputs;

      commands = rec {
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

        garnix = ''
          nix eval --raw .#garnixConfig | ${pkgs.jq}/bin/jq > garnix.yaml
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

          cp ${./repos.json} repos.json
          rm -f repos.json.lock

          bin/nur update
          bin/nur eval "$FLAKEDIR"

          git clone --single-branch "https://github.com/nix-community/nur-combined.git"
          cp repos.json repos.json.lock nur-combined/
          bin/nur index nur-combined > index.json

          cd "$FLAKEDIR"
          rm -rf "$TMPDIR"
        '';

        readme = ''
          set -euo pipefail
          nix build .#_meta.readme
          cat result > README.md
          ${garnix}
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
          # ${py}/bin/python3 pkgs/nvidia-grid/update.py
          ${py}/bin/python3 pkgs/openj9-ibm-semeru/update.py
          ${py}/bin/python3 pkgs/openjdk-adoptium/update.py
          ${readme}
        '';
      };
    in rec {
      packages = import ./pkgs null {
        inherit inputs pkgs;
      };

      ciPackages = lib.filterAttrs (n: isBuildable) (import ./pkgs "ci" {
        inherit inputs pkgs;
      });
      ciOutputs = lib.mapAttrsToList (_: outputsOf) (lib.filterAttrs (_: isBuildable) ciPackages);

      formatter = pkgs.alejandra;

      readme = pkgs.callPackage helpers/readme.nix {
        inherit packages;
      };

      apps = lib.mapAttrs (n: v: flake-utils.lib.mkApp {drv = pkgs.writeShellScriptBin n v;}) commands;

      devShells.default = makeAppsShell apps;

      nixosConfigurations = nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          (builtins.attrValues self.nixosModules)
          ++ [
            {
              # Minimal config to make test configuration build
              boot.loader.grub.devices = ["/dev/vda"];
              fileSystems."/" = {
                device = "tmpfs";
                fsType = "tmpfs";
              };
            }
          ];
      };
    }))
    // {
      garnixConfig = builtins.toJSON {
        builds.include =
          (lib.naturalSort
            (lib.flatten
              (builtins.map
                (platform: (builtins.map (p: "packages.${platform}.${p}") (builtins.attrNames (self.ciPackages."${platform}"))))
                supportedSystems)))
          ++ ["nixosConfigurations.*"];
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
        kata-containers = import ./modules/kata-containers.nix;
        openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
        qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix;
      };
    };
}
