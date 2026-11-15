{
  description = "Merrkry's NUR repository";

  nixConfig = {
    extra-substituters = [ "https://niks3.tsubasa.moe" ];
    extra-trusted-public-keys = [
      "niks3.tsubasa.moe-1:tPUzYtlqW1bgA/9otIZA9LLmwESVaEmHCrEl6pbCxOY="
    ];
  };

  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems =
        f:
        lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      legacyPackages = forAllSystems (pkgs: import ./default.nix { inherit pkgs; });

      packages = forAllSystems (
        pkgs:
        let
          nurLib = import ./lib { inherit pkgs; };
          repository = self.legacyPackages.${pkgs.stdenv.hostPlatform.system};
          formatNix = pkgs.writeShellApplication {
            name = "format-nix";
            runtimeInputs = [
              pkgs.findutils
              pkgs.nixfmt-rs
              pkgs.ripgrep
            ];
            text = ''
              rg --files -g '*.nix' -0 | xargs -0 nixfmt "$@"
            '';
          };
        in
        lib.filterAttrs (_: nurLib.isBuildable) (nurLib.getPackages repository)
        // {
          format-nix = formatNix;
          check-nix = pkgs.writeShellApplication {
            name = "check-nix";
            runtimeInputs = [
              formatNix
              pkgs.statix
            ];
            text = ''
              format-nix --check
              statix check .
              nix flake check . --all-systems --no-build
            '';
          };
          test-nix-hash = pkgs.callPackage ./pkgs/nix-hash/test.nix { };
          update-nur = pkgs.writeShellApplication {
            name = "update-nur";
            runtimeInputs = [
              pkgs.nix
              pkgs.nix-update
              pkgs.python3
            ];
            text = ''
              export NIX_PATH="nixpkgs=${pkgs.path}"
              exec python3 ${./update.py} "$@"
            '';
          };
        }
      );

      buildJobs = forAllSystems (pkgs: import ./build-jobs.nix { inherit pkgs; });

      checks = forAllSystems (pkgs: {
        github-release-updater = pkgs.callPackage ./lib/github-release-updater.nix { };
      });

      # Upstream Nix requires the conventional argument names.
      overlays.default = final: prev: import ./overlay.nix final prev;

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rs);
    };
}
