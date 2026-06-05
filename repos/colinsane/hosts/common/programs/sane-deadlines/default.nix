{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.sane-deadlines;
in
{
  sane.programs.sane-deadlines = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.showOnLogin = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };
    packageUnwrapped = pkgs.sane-scripts.deadlines;

    sandbox.extraHomePaths = [ "knowledge/planner/deadlines.tsv" ];

    fs.".profile".symlink.text = lib.mkIf cfg.config.showOnLogin ''
      maybeShowDeadlines() {
        if [ -z "$SSH_CONNECTION" ]; then
          sane-deadlines
        fi
      }
      sessionCommands+=('maybeShowDeadlines')
    '';
  };
}
