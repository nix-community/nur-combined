{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "LICENSE";
        settings.global.excludes = [
          ".envrc"
          "_sources/**"
          "flake.lock"
        ];
        programs = {
          keep-sorted.enable = true;
          # nix
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rs;
          };
          # sh
          shellcheck.enable = true;
        };
      };
    };
}
