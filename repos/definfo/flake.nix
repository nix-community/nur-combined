{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      pinnedPackages = [ "lyricer" ];
      updateArgsMap = {
        sjtu-canvas-helper-git = "--version-regex 'app-v.*'";
      };
      autoUpdatePackages = forAllSystems (
        system:
        builtins.filter (n: !builtins.elem n pinnedPackages) (builtins.attrNames self.packages.${system})
      );
      autoUpdateAttrs = forAllSystems (
        system:
        (
          builtins.listToAttrs (
            map (n: {
              name = n;
              value = "";
            }) autoUpdatePackages.${system}
          )
          // updateArgsMap
        )
      );
      # treefmt-nix assisted functions
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
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
      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          update-script = pkgs.writeShellScriptBin "auto-update" ''
            echo "Starting package updates..."

            PARALLEL_JOBS=4

            update_package() {
              local package=$1
              local args=$2
              echo "=== Updating $package ==="
              ${pkgs.nix-update}/bin/nix-update --build "$package" "$args"
              echo "✓ Successfully updated $package"
              echo
            }
            export -f update_package

            ${pkgs.jq}/bin/jq -r 'to_entries | .[] | .key + " " + .value' <<< '${
              builtins.toJSON autoUpdateAttrs.${system}
            }' | \
            ${pkgs.moreutils}/bin/parallel -j $PARALLEL_JOBS update_package

            echo "Update process completed!"
          '';
        in
        {
          auto-update = {
            type = "app";
            program = "${update-script}/bin/auto-update";
          };
        }
      );
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              nvfetcher
              nix-update
              treefmt
              jq
              moreutils
            ];
          };
        }
      );
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
