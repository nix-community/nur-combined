{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = ".git/config";
        settings.excludes = [ "*_sources/*" ];
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rs;
          priority = 0;
        };
        programs.deadnix = {
          enable = true;
          priority = 1;
        };
        programs.nixf-diagnose = {
          enable = true;
          priority = 2;
        };
        programs.toml-sort = {
          enable = true;
          all = true;
        };
        programs.prettier.enable = true;
        programs.just.enable = true;
        programs.shfmt.enable = true;
        programs.shellcheck = {
          enable = true;
          external-sources = true;
          source-path = "SCRIPTDIR";
        };
        programs.keep-sorted.enable = true;
        programs.actionlint.enable = true;
      };
    };
}
