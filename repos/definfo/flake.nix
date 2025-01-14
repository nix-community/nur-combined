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
      nvfetcherPackages = builtins.attrNames (
        import ./_sources/generated.nix {
          inherit (nixpkgs)
            fetchgit
            fetchurl
            fetchFromGitHub
            dockerTools
            ;
        }
      );
      pinnedPackages = [ "lyricer" ];
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
            config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
          };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      autoUpdatePackages = forAllSystems (
        system:
        builtins.filter (n: !builtins.elem n (nvfetcherPackages ++ pinnedPackages)) (
          builtins.attrNames self.packages.${system}
        )
      );
      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          update-script = pkgs.writeShellScriptBin "auto-update" ''
            echo "Starting package updates..."

            PARALLEL_JOBS=4

            ${pkgs.nix}/bin/nix eval --json .#autoUpdatePackages.${system} | \
            ${pkgs.jq}/bin/jq -r '.[]' | \
            ${pkgs.parallel}/bin/parallel -j $PARALLEL_JOBS \
              echo "=== Updating {} ===" \; \
              ${pkgs.nix-update}/bin/nix-update {} \; \
              echo "✓ Successfully updated {}" \; \
              echo

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

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
