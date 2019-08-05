{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.lorri;
in {
  options.services.lorri = {
    enable = mkEnableOption "lorri";

    useNix = mkOption {
      type = types.bool;
      default = true;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.lorri;
      defaultText = "pkgs.lorri";
    };
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = mkDefault true;
      stdlib = ''
        use_lorri() {
          local LORRI_SERVICE LORRI_EVAL
          LORRI_SERVICE=lorri@$(${pkgs.systemd}/bin/systemd-escape "$(pwd)")
          eval "$(${pkgs.lorri}/bin/lorri direnv)"
          if ! ${pkgs.systemd}/bin/systemctl --user --quiet is-active $LORRI_SERVICE; then
            ${pkgs.systemd}/bin/systemctl --user import-environment LOCALE_ARCHIVE TZDIR ''${TZ+TZ}
            ${pkgs.systemd}/bin/systemctl --user start $LORRI_SERVICE
            echo "[lorri] build status: journalctl --user -fu '$LORRI_SERVICE'" >&2
          fi
        }
      '' + optionalString cfg.useNix ''
        use_nix() {
          use_lorri "$@"
        }
      '';
    };

    systemd.user.services."lorri@" = {
      Unit = {
        Description = "lorri watch";
        ConditionPathExists = "%I";
        ConditionUser = "!@system";
      };
      Service = {
        #Type = "exec";
        Restart = "on-failure";
        WorkingDirectory = "%I";
        PrivateTmp = true;
        ProtectSystem = "full";
        ExecStart = "${cfg.package}/bin/lorri watch";
      };
    };
  };
}
