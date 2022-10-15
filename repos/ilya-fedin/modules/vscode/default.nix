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
        description = ''
          Install Visual Studio Code with native extensions.
        '';
      };

      extensions = mkOption {
        type = types.listOf types.path;
        default = [];
        description = ''
          List of extensions to install.
        '';
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          User name for who to install the extensions.
        '';
      };

      homeDir = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          User home directory for who to install the extensions.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != "" && cfg.user != null;
        message = "User name is missing.";
      }
      {
        assertion = cfg.homeDir != "" && cfg.homeDir != null;
        message = "User home directory is missing.";
      }
    ];

    environment.systemPackages = [ pkgs.vscode ];

    system.activationScripts.fix-vscode-extensions = {
      text = ''
        EXT_DIR=${cfg.homeDir}/.vscode/extensions
        mkdir -p $EXT_DIR
        chown ${cfg.user}:users $EXT_DIR
        for x in ${concatMapStringsSep " " toString cfg.extensions}; do
            ln -sf $x/share/vscode/extensions/* $EXT_DIR/
        done
        chown -R ${cfg.user}:users $EXT_DIR
      '';
      deps = [];
    };
  };
}
