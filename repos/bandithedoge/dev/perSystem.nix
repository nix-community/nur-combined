{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      system,
      ...
    }:
    {
      devShells = {
        build = pkgs.mkShell {
          packages = with pkgs.lixPackageSets.latest; [
            nix-eval-jobs
            nix-fast-build
          ];
        };

        update = pkgs.mkShell {
          packages = with pkgs; [
            inputs.mozilla-addons-to-nix.packages.${system}.default
            npins
            nushell
            nvfetcher
          ];
        };

        default = pkgs.mkShell {
          inputsFrom = with self'.devShells; [
            build
            update
          ];
        };
      };

      treefmt.config = {
        projectRootFile = "flake.nix";
        settings.excludes = [
          "*/_sources/*"
          "*/npins/*"
        ];
        programs = {
          clang-format.enable = true;
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
          };
          prettier = {
            enable = true;
            package = pkgs.prettier;
          };
          ruff-format.enable = true;
          shfmt.enable = true;
          taplo.enable = true;
          keep-sorted.enable = true;
        };
      };
    };
}
