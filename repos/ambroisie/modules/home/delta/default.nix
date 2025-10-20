{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.delta;
in
{
  options.my.home.delta = with lib; {
    enable = my.mkDisableOption "delta configuration";

    package = mkPackageOption pkgs "delta" { };

    git = {
      enable = my.mkDisableOption "git integration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.delta = {
      enable = true;

      inherit (cfg) package;

      enableGitIntegration = cfg.git.enable;

      options = {
        features = "diff-highlight decorations";

        # Less jarring style for `diff-highlight` emulation
        diff-highlight = {
          minus-style = "red";
          minus-non-emph-style = "red";
          minus-emph-style = "bold red 52";

          plus-style = "green";
          plus-non-emph-style = "green";
          plus-emph-style = "bold green 22";

          whitespace-error-style = "reverse red";
        };

        # Personal preference for easier reading
        decorations = {
          commit-style = "raw"; # Do not recolor meta information
          keep-plus-minus-markers = true;
          paging = "always";
        };
      };
    };
  };
}
