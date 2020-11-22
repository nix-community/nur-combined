{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.vscode;
in {
  options = {
    programs.vscode = {
      enable = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Install Visual Studio Code with native extenrsions.
        '';
      };

      extensions = mkOption {
        default = [];
      };

      user = mkOption {};
      homeDir = mkOption {};
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.vscode ];

    system.activationScripts.fix-vscode-extensions = {
      text = ''
        EXT_DIR=${cfg.homeDir}/.vscode/extensions
        mkdir -p $EXT_DIR
        chown ${cfg.user}:users $EXT_DIR
        for x in ${concatMapStringsSep " " toString cfg.extensions}; do
            ln -sf $x/* $EXT_DIR/
        done
        chown -R ${cfg.user}:users $EXT_DIR
      '';
      deps = [];
    };
  };
}